# Gemini-designed Android Fun Money app

Brian asked for Gemini's own models to come up with the idea and design. This folder holds only the prompts and the plumbing.

- `prompt1_ideation.md`: neutral brief (family, Crew/Bangor, visual-only, Plaid or parent PIN, Flutter/Android). Gemini proposes 3 concepts, picks one, writes the spec and its own image prompts.
- `prompt2_assets_extract.md`: turns Gemini's own asset list into JSON (no new content).
- `prompt3_code.md`: Gemini writes the Flutter app for its chosen concept.
- `run_gemini.py`: calls the Gemini API. Key comes only from the `GEMINI_API_KEY` repo secret and is never printed.
- `out/`: Gemini's raw output, committed verbatim. Any fix we make to Gemini's code is a separate, labeled commit.

Run: edit `STAGES` (e.g. `models ideate images code`) on branch `gemini-designed-android` and push.
