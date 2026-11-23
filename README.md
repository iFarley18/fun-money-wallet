# Fun Money Wallet (web prototype)

A visual of each kid's real Crew card balance, shown as play money. This app never adds, spends or moves real money.

**Try it:** https://ifarley18.github.io/fun-money-wallet/ (open it in Chrome on your phone)

## What's in it
- **Wad view:** a folded wad of bills. Swipe up (or tap) to peel each bill over toward you, like a cashier counting it back. The count climbs as you go. Swipe down to un-count one.
- **Counter view:** every bill and coin laid flat on a wooden counter, grouped by kind.
- **What changed:** when the app opens, it shows what changed since last time (for example, "$8 left since Saturday") and those bills fly off the counter. Tap Replay to watch it again.
- **"Someone's sending money":** preview what the wallet looks like with money from Grandma and others. Nothing is saved.
- **"I want something":** the kid hands bills to the cashier until the price is covered, then sees the change come back and what would be left. Nothing is saved.
  - Level 1 (about age 7): bills only. The cashier handles the coins.
  - Level 2 (about age 9): bills and coins, and guesses the change before it's shown.
  - "Show me" appears after 2 extra picks or a long pause.
- **Parent settings** (lock icon): type each kid's Crew balance, name, level and bill theme. **Prototype PIN: 1234** (change it inside).

## Notes
- The bills are original play money ("iFARLEY'S BANK", not legal tender). They don't copy U.S. currency or any show's characters.
- Data is saved only in this browser (localStorage). Clearing Chrome's site data resets it.
- Built as one self-contained `index.html` with no build step.
