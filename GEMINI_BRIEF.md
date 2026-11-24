# Fun Money Wallet: product and design brief

Build a phone web app (later wrapped in an Android app) that shows a child how much money is on their real debit card as a stack of **play money** they can see, touch and count. Do your best version of this concept. This brief covers everything needed, so you shouldn't need any other context.

---

## 1. Purpose

- The app is a **read-only picture** of each kid's real card balance (the family uses the **Crew** kids' banking app). It **never adds, spends or moves real money.**
- **For now, a parent types each balance in by hand** (see section 7). Later the app will read the real balance when it opens, through a bank-data service such as Plaid, using a tiny backend that returns only the balance. Don't build that sync yet, and **don't show anything that pretends to sync**: no "Synced with Crew", no "Matches your card", no sync spinners. Label the number plainly, for example "By parent · updated today", and mention that Crew sync is coming later.
- The goal is to make money feel real and countable: "I have $57.38" becomes a wad of bills and a few coins the kid can thumb through.
- The two "what if" previews (section 5) are pretend only. Nothing in them is ever saved, so a real purchase is never counted twice.

## 2. Users

| User | Age | Level | What they do |
|---|---|---|---|
| Everest | 7 | **Level 1** | Picks **bills only**. The "cashier" handles any coins automatically. |
| His older brother | 9 | **Level 2** | Picks **bills and coins**, and must **guess the change** before it's shown. |
| Parent | adult | n/a | Sets balances, names, levels, themes and the PIN behind a 4-digit PIN. |

- Each kid has a tab at the top with their name.
- Each kid has a theme: a calm "deep sea" look for the younger one and a "dojo" (ninja/dragon) look for the older one. Themes are **subtle accents** (background color, small marks on the bills), not cartoon art.
- Kids like SpongeBob, Ninjago, Teen Titans, TMNT and Bluey, but **don't use any show's characters or logos.**

## 3. Money model (must be exact)

- Store everything as **integer cents**. Never use floating-point dollars.
- Denominations: bills $100, $50, $20, $10, $5, $1; coins 25¢, 10¢, 5¢, 1¢.
- On every open, re-count the balance into the **fewest pieces** (greedy breakdown works for this set). $57.38 = $50 + $5 + $1 + $1 + 25¢ + 10¢ + 1¢ + 1¢ + 1¢.
- **Natural tender** (what a person would hand the cashier): use the fewest pieces that cover the price, and break ties by the least overpay, so a single bill that covers the price always wins ("hand over the $10"). Level 1 searches bills only. If the bills can't cover the price, hand over all the bills plus the fewest coins.
- Change = amount handed − price, broken down into fewest pieces.
- Conservation: (wallet − handed + change) must always equal (balance − price), with no negative counts.
- Format money as `$1,234.56`. Whole dollars may show as `$50`. Amounts under $1 may show as `38¢`.

## 4. Core views

A toggle at the top switches between **Wad** and **Counter**. Show the kid's name and the big balance at the top on both.

### 4a. Wad view: count it like a cashier
- The bills form a **folded wad**, a stack folded across the middle, seen from slightly above. Largest bills are on top.
- The kid **swipes up** (or taps) to peel the top bill up and **over toward the viewer**, the way a cashier counts money back. The bill bends: the lower half leads, it shows its **back** past 90°, then lands face-down on a "counted" pile above.
- A big count at the top **climbs** with each bill ("$50… $55… $56… $57"). While a bill is mid-flip, the count shows the tentative total in gold. At the end it shows "That's all! $57.38" with "bills + 38¢ in coins."
- Swiping down un-counts the last bill. A small slow drag or an interrupted gesture must **never** count a bill. A quick flick does.
- Each peel makes a soft paper "riffle" sound (generated in code) and a tiny vibration, if supported.
- Coins sit as a small pile beside the wad with a "+38¢" label.
- **Empty state** ($0): show a calm, intentional message such as "$0.00 right now. When money comes in, the bills show up here." Hide the count readout.

### 4b. Counter view: everything laid out flat
- A wooden counter top with each kind of bill laid flat in its own row, overlapping slightly with a little natural rotation, plus a "×2 · $2" label per row.
- Coins are grouped below with labels like "3 × 1¢". Labels must be **large and readable** (at least 15 px, row counts about 24 px).
- **What changed:** when the balance differs from the last saved one, open on the counter. Play the difference: spent bills **fly off**, new bills **land** with a soft glow, the big number counts from old to new, and a banner reads "$8 spent since Saturday" or "$25 came in since Saturday", with a **Replay** button. Compare against the previous balance a parent typed in, and use its date.

## 5. "What if" previews (never saved)

Two big buttons sit at the bottom: **"Someone's sending money"** and **"I want something."** While a preview is active, a striped banner makes clear it's pretend, and a **"Back to real money"** button restores the real wallet. Editing the balance is disabled during previews.

### 5a. Someone's sending money
- Pick a sender (Grandma, Grandpa, Birthday, Chores, Tooth Fairy, Aunt & Uncle) and an amount ($5, $10, $20, $25, $50, or a custom amount on a keypad).
- The new bills land on the counter, and the top shows "$57.38 → $82.38".

### 5b. I want something (the cashier game)
- Pick an item with a price, e.g. **Headphones $34.99**. Allow a custom item and price.
- The kid **taps bills (and coins at Level 2) on the counter** to move them to a "Handing to the cashier" tray. The tray shows "$6.00 of $34.99" and "Need $28.99 more". Tapping a piece in the tray takes it back.
- **Pay stays disabled until the price is covered.** Then it reads "Pay $50.00".
- **"Show me"** appears after **2 wrong or unneeded picks** or about **15–20 seconds** without progress. It animates the natural tender.
- After Pay, the cashier hands back the **change**, which animates onto the counter. The banner shows "$50.00 − $34.99 = $15.01 back" and "You'd have $22.39 left."
- **Level 2:** before the change is revealed, the kid types their guess on a keypad. Show a "Nailed it!" or gentle correction.
- If they can't afford it, say so kindly ("Not yet! You have $X, it costs $Y. Save $Z more").

## 6. Visual bar: grown-up, realistic, original play money

The bills must look like **real engraved banknotes**, not toy money or clip art. They must also be **clearly original play money, not U.S. currency.**

- **Legal:** follow 31 CFR 411.1 and 18 USC 504 (rules on likenesses of U.S. currency).
  - No real portraits, seals or Treasury text.
  - No "United States", "Federal Reserve" or real signatures.
  - No real serial-number formats and no copying a real bill's layout.
  - Use an invented issuer name (the original used "iFARLEY'S BANK").
  - Print **"NOT LEGAL TENDER · FOR PRACTICE ONLY"** and "FUN MONEY".
- **Paper:** off-white/cream with a subtle fiber-noise texture, faint mottling, a few colored fibers, slightly darker worn edges, and soft fold creases (center vertical and horizontal) so stacks look like real paper.
- **Engraving:**
  - Fine **guilloche** made in code: woven rosettes, sine-strand border bands and a faint wavy underprint.
  - A double-line border with tiny repeating **microprint** text.
  - Corner numerals inside small rosettes.
- **Picture (front):** a single-color, line-engraved oval vignette that's different for each value, so values can be told apart without color. Examples: $1 lighthouse, $5 sailing ship, $10 mountain peaks, $20 oak tree, $50 compass rose, $100 sunrise over the sea.
- **Back:** a central rosette with the same vignette, big numerals at both ends, and the kid's name ("EVEREST'S FUN MONEY").
- **Color:** a **muted** tint per value (slate blue, plum, sage, rust, teal, olive-bronze) on cream. Keep values distinguishable for color-blind users through **big numerals + distinct pictures**, not color alone.
- **Type on bills:** a classic **serif** (Roman capitals) for the bank name, the value word ("TWENTY") and large serif numerals. Embed the font so it renders the same on the phone. **No bubbly or rounded kid fonts on the bills.** The app's own buttons may stay friendly, but don't let them clash.
- **Serial numbers:** in a muted red-brown, using an invented format such as `FM 20 · 986 202`.
- **Coins:** realistic silver and copper with ridged edges on the 25¢ and 10¢, a raised rim, a dotted ring, raised serif numerals with "CENTS", and the issuer name around the rim. No cartoon shine.
- **Theme accents:** deep sea gets a small anchor mark and a wave-line underprint. Dojo gets a small four-point star mark, a Japanese wave-scale (seigaiha) underprint and zigzag border strands.
- **Performance:** draw each bill face once (SVG to canvas) into a cached image per value and theme, so the wad and counter only move flat images. Avoid per-frame SVG filters.

## 7. Parent area (PIN protected)

- **Set balance (first-class):** tapping the big balance (or a visible "✎ Set" pill next to it) asks for the **4-digit parent PIN** (prototype default 1234). It then opens a big keypad:
  - Keys 1–9, ".", 0, ⌫, at least 56 px tall.
  - Dollars and cents with at most 2 decimals and a sensible max of $9,999.99. **$0 is allowed** (a "Set to $0" button).
  - Show "Was $57.38 · updated Saturday", with Save and Cancel.
- **Saving** records the new balance and the date, re-counts it into the fewest bills with the fly-off/land animation, and updates the "since …" banner. If nothing changed, just say so.
- **Settings sheet** (lock icon), for each kid: name, balance (text field with `inputmode="decimal"`), level (1 or 2) and theme. Also a sound toggle, a PIN change and a demo reset.
- The balance field must accept `0`, `7.05`, `.50`, `12,34` (comma keyboards), and `$1,234.5`. It must reject letters and amounts over the max with a red outline.
- Wrong PIN: shake and buzz, then clear.

## 8. Android constraints

- It runs in Chrome on Android and later inside an Android WebView (Galaxy S26 Ultra, Android 16).
- Save state to `localStorage`. The WebView must enable DOM storage. Clearing app data wipes the wallets, so show a warning banner if saving fails.
- Keep every control **out of the bottom gesture-navigation zone**, at least about 52 px above the bottom edge, and respect `env(safe-area-inset-*)`.
- Make tap targets ≥ 48 px. Use `touch-action` correctly so swiping the wad never scrolls the page. Handle `pointercancel` (Android stealing the gesture) by settling back without counting.
- **Haptics** use `navigator.vibrate` only after the first user tap. In the wrapped app, a native bridge can replace it.
- Sound uses WebAudio, starts only after a user gesture, and can be muted.
- **60 fps** while flipping. Use transforms only, and pre-rendered bill images.
- Honor `prefers-reduced-motion`.

## 9. Deliverable format

- **A single self-contained `index.html`** containing all CSS, JS, SVG art and the embedded font, with no build step and no external dependencies except optional web fonts for the app's own buttons.
- It must work from GitHub Pages and from a local file.
- Expose a small `window.__FM` test hook for the money functions and key state, so it can be tested automatically.

## 10. Acceptance criteria

1. Opening with a new balance plays the counter "what changed" animation, and the banner names the difference and the date of the previous entry.
2. Wad: swiping up counts one bill per peel, and the count reaches the exact balance. A tiny drag or an interrupted gesture never counts a bill. Swiping down un-counts.
3. Counter: every piece is shown, grouped, and the labels are readable.
4. Sending money: the preview shows the new total. "Back to real money" restores the real balance, and nothing is saved.
5. Headphones $34.99 from $57.38:
   - Pay is disabled at $6.00 and enabled once covered.
   - Natural tender is the $50.
   - Change is $15.01, and "You'd have $22.39 left."
   - Level 2's guess of 15.01 shows "Nailed it!"
6. Set balance: tap the balance → PIN 1234 → type 12.34 → Save. The balance shows $12.34, the wad holds $10 + $1 + $1 + 34¢, and it persists after reload with "updated today".
7. Set balance to $0: the counter and wad show an intentional empty state, with no stray "$0 of $0" readouts.
8. No text anywhere implies live bank syncing.
9. The bills look like engraved paper currency, are clearly original, and carry the not-legal-tender text.
10. No console errors. No control sits in the bottom 52 px.

## 11. Test checklist

- [ ] Money fuzz: ~20,000 random balances and prices at both levels. Check the breakdown total, that tender covers the price, that nothing exceeds the wallet, that change is correct, conservation, the single-bill-wins rule and the Level-1 coin rule. Then run an exhaustive check of all balances ≤ $30.
- [ ] Wad gesture probes at 20°, 40°, 60°, 80°, 100° and past 140°. Release to commit; small slow drag gives no commit; touchcancel gives no commit; taps count through to "That's all".
- [ ] Preview send $25 → amount shows "$57.38 → $82.38" → back → the saved balance is unchanged.
- [ ] Picker gating, wrong-pick counter, take-back, Show me, change, Level 2 guess.
- [ ] Set-balance flow ($12.34, $0, Cancel), plus the settings field inputs listed in section 7.
- [ ] Geometry on a 412×860 and a 412×740 viewport: the action bar sits ≥ 52 px above the bottom.
- [ ] Frame timing during flips at 4× CPU throttle: about 16.7 ms per frame.
- [ ] Visual close-ups of every denomination front and back, the coins, and both themes.
