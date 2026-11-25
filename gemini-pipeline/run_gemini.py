#!/usr/bin/env python3
"""Runs Brian's Gemini design pipeline. Reads GEMINI_API_KEY from env; never prints it.
Stages (from gemini-pipeline/STAGES, space separated): models ideate images code
Outputs go to gemini-pipeline/out/ (raw Gemini responses kept verbatim) and gemini-app/.
"""
import base64, json, os, re, sys, time, urllib.request, urllib.error, pathlib

KEY = os.environ.get("GEMINI_API_KEY", "")
if not KEY:
    print("GEMINI_API_KEY secret is not set in this repo; nothing to do."); sys.exit(0)
BASE = "https://generativelanguage.googleapis.com/v1beta"
ROOT = pathlib.Path(__file__).resolve().parent
OUT = ROOT / "out"; OUT.mkdir(exist_ok=True)
APP = ROOT.parent / "gemini-app"
STAGES = (ROOT / "STAGES").read_text().split()
TEXT_PREF = ["gemini-4-carbon", "gemini-4-neon", "gemini-4-hydrogen", "gemini-3.1-pro-preview", "gemini-3-pro-preview", "gemini-2.5-pro"]
IMG_PREF = ["gemini-3-pro-image", "gemini-nano-banana-2.1", "gemini-3.1-flash-image", "gemini-2.5-flash-image"]
# $ per 1M tokens: (input, text/thinking output, image output)
PRICE = {"gemini-4-carbon": (2, 10, 0), "gemini-4-neon": (3, 15, 0), "gemini-4-hydrogen": (1.5, 7.5, 0),
         "gemini-3.1-pro-preview": (2, 12, 0), "gemini-3-pro-preview": (2, 12, 0), "gemini-2.5-pro": (1.25, 10, 0),
         "gemini-3-pro-image": (2, 12, 120), "gemini-nano-banana-2.1": (1.5, 7.5, 30),
         "gemini-3.1-flash-image": (0.5, 3, 60), "gemini-2.5-flash-image": (0.3, 2.5, 30)}
usage_path = OUT / "usage.json"
usage = json.loads(usage_path.read_text()) if usage_path.exists() else {"calls": [], "est_usd": 0.0}

def req(method, path, body=None, timeout=900):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(BASE + path, data=data, method=method,
                               headers={"x-goog-api-key": KEY, "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(r, timeout=timeout) as resp:
            return 200, json.loads(resp.read())
    except urllib.error.HTTPError as e:
        return e.code, {"error": e.read().decode(errors="replace")[:2000]}

def gen(model, body, label):
    for attempt in range(12):
        code, res = req("POST", f"/models/{model}:generateContent", body)
        if code == 200: break
        print(f"[{label}] HTTP {code}: {res['error'][:500]}")
        if code == 400 and "thinkingConfig" in body.get("generationConfig", {}):
            body["generationConfig"].pop("thinkingConfig"); continue
        if code == 400 and "imageConfig" in body.get("generationConfig", {}):
            body["generationConfig"].pop("imageConfig"); continue
        if code == 429 and "free_tier" in res["error"]: raise SystemExit(f"{label}: model not on free tier")
        time.sleep(30)
    else:
        raise SystemExit(f"{label} failed")
    um = res.get("usageMetadata", {})
    pi, po, pimg = PRICE.get(model, (3, 15, 120))
    out_tok = um.get("candidatesTokenCount", 0) + um.get("thoughtsTokenCount", 0)
    img_tok = sum(d.get("tokenCount", 0) for d in um.get("candidatesTokensDetails", []) if d.get("modality") == "IMAGE")
    cost = um.get("promptTokenCount", 0) * pi / 1e6 + (out_tok - img_tok) * po / 1e6 + img_tok * pimg / 1e6
    usage["calls"].append({"label": label, "model": model, "usage": um, "est_usd": round(cost, 4)})
    usage["est_usd"] = round(sum(c["est_usd"] for c in usage["calls"]), 4)
    usage_path.write_text(json.dumps(usage, indent=2))
    print(f"[{label}] {model} ok, est ${cost:.3f}, running total ${usage['est_usd']:.3f}")
    return res

def text_of(res):
    return "".join(p.get("text", "") for c in res.get("candidates", []) for p in c.get("content", {}).get("parts", []) if not p.get("thought"))

def pick_models():
    p = OUT / "models.json"
    if p.exists(): return json.loads(p.read_text())
    names, tok = [], ""
    while True:
        code, res = req("GET", "/models?pageSize=1000" + (f"&pageToken={tok}" if tok else ""))
        if code != 200: raise SystemExit(f"models list failed {code}: {res}")
        names += [m["name"].split("/", 1)[1] for m in res.get("models", [])]
        tok = res.get("nextPageToken")
        if not tok: break
    (OUT / "models_available.txt").write_text("\n".join(sorted(names)))
    text = next((m for m in TEXT_PREF if m in names), None)
    img = next((m for m in IMG_PREF if m in names), None)
    chosen = {"text": text, "image": img}
    p.write_text(json.dumps(chosen, indent=2)); print("chosen models:", chosen)
    return chosen

M = pick_models()
if os.environ.get("TEXT_MODEL"): M["text"] = os.environ["TEXT_MODEL"]
THINK = {"thinkingConfig": {"thinkingLevel": "high"}}

if "ideate" in STAGES:
    prompt = (ROOT / "prompt1_ideation.md").read_text()
    res = gen(M["text"], {"contents": [{"role": "user", "parts": [{"text": prompt}]}],
                          "generationConfig": {"maxOutputTokens": 32768, **THINK}}, "ideate")
    (OUT / "ideation_raw.json").write_text(json.dumps(res, indent=2))
    (OUT / "CONCEPT.md").write_text(text_of(res))
    schema = {"type": "OBJECT", "properties": {"assets": {"type": "ARRAY", "items": {"type": "OBJECT", "properties": {
        "filename": {"type": "STRING"}, "purpose": {"type": "STRING"}, "aspect_ratio": {"type": "STRING"},
        "transparent": {"type": "BOOLEAN"}, "prompt": {"type": "STRING"}},
        "required": ["filename", "purpose", "aspect_ratio", "prompt"]}}}, "required": ["assets"]}
    res2 = gen(M["text"], {"contents": [{"role": "user", "parts": [{"text": (ROOT / "prompt2_assets_extract.md").read_text() + "\n\n---\n\n" + text_of(res)}]}],
                           "generationConfig": {"responseMimeType": "application/json", "responseSchema": schema, "maxOutputTokens": 16384}}, "assets-extract")
    (OUT / "assets.json").write_text(json.dumps(json.loads(text_of(res2)), indent=2))

ALLOWED_AR = {"1:1", "2:3", "3:2", "3:4", "4:3", "4:5", "5:4", "9:16", "16:9", "21:9"}
def norm_ar(s):
    m = re.search(r"(\d+)\s*[:x×]\s*(\d+)", s or "")
    if not m: return "1:1"
    a, b = int(m.group(1)), int(m.group(2))
    if f"{a}:{b}" in ALLOWED_AR: return f"{a}:{b}"
    r = a / b
    return min(ALLOWED_AR, key=lambda k: abs(int(k.split(':')[0]) / int(k.split(':')[1]) - r))

if "images" in STAGES:
    imgdir = OUT / "images"; imgdir.mkdir(exist_ok=True)
    assets = json.loads((OUT / "assets.json").read_text())["assets"][:10]
    for a in assets:
        fn = re.sub(r"[^a-z0-9_.-]", "_", a["filename"].lower())
        if not fn.endswith(".png"): fn += ".png"
        if (imgdir / fn).exists(): continue
        p = a["prompt"] + ("\n\nTransparent background." if a.get("transparent") else "")
        body = {"contents": [{"role": "user", "parts": [{"text": p}]}],
                "generationConfig": {"responseModalities": ["TEXT", "IMAGE"], "imageConfig": {"aspectRatio": norm_ar(a.get("aspect_ratio")), "imageSize": "1K"}}}
        try:
            res = gen(M["image"], body, f"image:{fn}")
        except SystemExit as e:
            print(e); continue
        for c in res.get("candidates", []):
            for part in c.get("content", {}).get("parts", []):
                d = part.get("inlineData") or part.get("inline_data")
                if d and d.get("data"):
                    (imgdir / fn).write_bytes(base64.b64decode(d["data"]))
        if not (imgdir / fn).exists(): print(f"no image returned for {fn}: {text_of(res)[:300]}")

if "code" in STAGES:
    concept = (OUT / "CONCEPT.md").read_text()
    imgdir = OUT / "images"
    have = sorted(p.name for p in imgdir.glob("*.png")) if imgdir.exists() else []
    assets = json.loads((OUT / "assets.json").read_text())["assets"]
    listing = "\n".join(f"- {a['filename']}: {a['purpose']} ({'generated' if re.sub(r'[^a-z0-9_.-]', '_', a['filename'].lower()) in have else 'NOT generated'})" for a in assets)
    schema = {"type": "OBJECT", "properties": {"files": {"type": "ARRAY", "items": {"type": "OBJECT", "properties": {
        "path": {"type": "STRING"}, "content": {"type": "STRING"}}, "required": ["path", "content"]}}}, "required": ["files"]}
    prompt = (ROOT / "prompt3_code.md").read_text() + "\n\n---\n\n# Your design document\n\n" + concept + "\n\n---\n\n# Generated assets\n\n" + listing
    files = None
    for model, cap in [(M["text"], 32768), ("gemini-4-neon", 65536)]:
        res = gen(model, {"contents": [{"role": "user", "parts": [{"text": prompt}]}],
                          "generationConfig": {"responseMimeType": "application/json", "responseSchema": schema, "maxOutputTokens": cap, **THINK}}, f"code:{model}")
        (OUT / f"code_raw_{model}.json").write_text(json.dumps(res, indent=2))
        try:
            files = json.loads(text_of(res))["files"]; (OUT / "code_model.txt").write_text(model); break
        except Exception as e:
            print(f"code output from {model} not parseable ({e}); finishReason={[c.get('finishReason') for c in res.get('candidates', [])]}")
    if files is None: raise SystemExit("code stage failed")
    for f in files:
        rel = pathlib.PurePosixPath(f["path"].lstrip("/"))
        if ".." in rel.parts or (rel.parts and rel.parts[0] == "android"): continue
        dest = APP / rel; dest.parent.mkdir(parents=True, exist_ok=True); dest.write_text(f["content"])
    (APP / "assets/images").mkdir(parents=True, exist_ok=True)
    for p in have: (APP / "assets/images" / p).write_bytes((imgdir / p).read_bytes())
    print(f"wrote {len(files)} files to gemini-app/")
print("total est USD:", usage["est_usd"])
