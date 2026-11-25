# Crew Stash: Product & Design Specification

---

## 1. Three Distinct App Concepts

### Concept 1: **Crew Stash Sandbox (Tactile Physics Engine)**
* **Pitch:** A 2D physics-driven interactive tray where a kid's card balance is rendered as custom, chunky play bills and heavy metallic coins. Kids can flick, toss, stack, count, and drag cash across a textured vault floor, bridging the gap between invisible bank digits and real physical volume.
* **Core Interaction Loop:** Kid opens the vault → cash erupts onto the floor with physical mass and gravity → kid drags, sorts, and stacks bills into custom piles → kid drags a "Wishlist Target" (e.g., a $15 item) onto the floor to physically separate and test how much cash remains.
* **7-Year-Old Value:** Sensory delight of flicking cash, hearing metallic coin collisions, seeing a huge physical pile of bills when balance goes up, and scattering money around without real-world mess.
* **9-Year-Old Value:** Tactical sorting into explicit $1, $5, $10, and $20 stacks; running "what-if" purchase tests to budget for target toys without risking real card funds.
* **Main Risk:** Physics engine performance (handling rigid-body collisions of 40+ bill/coin sprites simultaneously on screen without dropping frame rates below 120fps).

### Concept 2: **Loot Locker (Arcade Till & Receipt Printer)**
* **Pitch:** A comic-book-styled arcade cash register where kids spring open heavy cash drawers, sort money into dedicated till slots, and feed bills into a interactive scanner that prints physical-style "What-If Thermal Receipts."
* **Core Interaction Loop:** Kid swipes down to pop open the register till → slides bills out of color-coded slots → punches numbers into a tactile mechanical key pad → prints a rolling paper receipt showing "Starting Cash / Purchase / Cash Remaining."
* **7-Year-Old Value:** Tactile thrill of spring-loaded drawer snaps, mechanical button clicks, and watching the thermal receipt roll out with custom sticker icons.
* **9-Year-Old Value:** Arithmetic engagement; learning cash register mechanics, visual subtraction, and keeping track of pretend itemized receipts.
* **Main Risk:** Rigid compartment structure feels less like freeform physical cash and more like a structured accounting tool.

### Concept 3: **Stash Fortress (Isomeric Brick Builder)**
* **Pitch:** Transforms every dollar of a child's balance into snap-together isometric golden bricks and silver coins, allowing kids to construct dynamic visual fortresses and towers out of their actual net worth.
* **Core Interaction Loop:** Kid views their monetary fortress → taps to view individual bill denominations stored inside the foundation → snaps off blocks into visual "Goal Buckets" (e.g., Lego Set, Skateboard) to physically build towers representing visual sub-goals.
* **7-Year-Old Value:** Tower height provides instant, spatial spatial awareness ("My tower grew 3 blocks taller today!").
* **9-Year-Old Value:** Allocating physical brick piles toward specific long-term savings visualizers.
* **Main Risk:** Abstracting dollars into "building blocks" strays from teaching physical play bill/coin recognition and cash handling.

---

## 2. Concept Selection & Justification

### Winner: **Concept 1 — Crew Stash Sandbox**

#### Why this concept wins:
The fundamental problem identified by Brian and Christine is that **card balance numbers are abstract**. A number like "$43.50" on a smartphone screen conveys no tactile magnitude to a 7-year-old and minimal emotional weight to a 9-year-old. 

* **Direct Problem Fit:** Physics sandbox recreation gives money visual volume, weight, and spatial presence. $43.50 isn't just a string of text; it's two $20 bills, three $1 bills, two quarters, total physical items covering the screen surface that take effort to stack.
* **Energy Match:** Captures the kinetic, chaotic, slapstick kinetic energy inspired by high-octane family animation—bills bounce off walls, coins spin with high-frequency haptic buzzes, and visual effects celebrate money saved.
* **Immediate Comprehension:** It avoids unnecessary abstraction (like turning dollars into fantasy crystals or bricks). It uses **play currency** that directly maps to real money math while remaining safe, isolated, and non-financial.

---

## 3. Detailed Specification: Crew Stash

### A. Screens & User Flows

```
                          ┌────────────────────────┐
                          │   App Launch Screen    │
                          └───────────┬────────────┘
                                      │
                         ┌────────────┴────────────┐
                         ▼                         ▼
            ┌────────────────────────┐ ┌────────────────────────┐
            │   Kid Vault Dashboard  │ │   First-Run Setup      │
            │   (Physics Sandbox)    │ │   (Create PIN/Kids)    │
            └────────────┬───────────┘ └────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Kid Switcher │ │ "What-If"    │ │ Parent Gate  │
│ Tray         │ │ Scanner Drawer│ │ (PIN Entry)  │
└──────────────┘ └──────────────┘ └───────┬──────┘
                                          │
                                          ▼
                                ┌──────────────────┐
                                │ Parent Control   │
                                │ Panel Dashboard  │
                                └──────────────────┘
```

#### 1. Kid Vault Dashboard (Main Sandbox Screen)
* **Purpose:** Primary interface for both boys. Pure play sandbox displaying their total card balance converted into dynamic physical cash.
* **Layout:**
  * **Top Bar (Pinned HUD):**
    * *Left:* Active Kid Avatar Pill (Icon + Name, e.g., "Leo's Stash"). Tapping slides down the **Kid Switcher Tray**.
    * *Center:* Total Balance Badge in bold typography (`$43.50`). Tapping toggles between dollar sum view and item count view (`2 Bills • 4 Coins`).
    * *Right:* Disguised Parent Access Icon (a stylized vault gear; holding for 2 seconds opens the Parent PIN Gate).
  * **Center Stage (Physics Canvas):** Full-bleed interactive surface rendering custom play bills and coins with dynamic 2D physics (gravity, drag, friction, wall bouncing).
  * **Bottom Control Dock (Floating Action Strip):**
    * *Tidy Button (Left):* Triggers a fast magnetic snap animation, organizing all loose cash into organized stacks grouped by denomination.
    * *Explode/Scatter Button (Center):* Applies a central radial physics impulse, scattering bill stacks into a chaotic pile across the screen.
    * *What-If Scanner Tab (Right):* Pulls up the purchase simulator overlay.

#### 2. "What-If" Purchase Simulator (Bottom Drawer Overlay)
* **Purpose:** Allows kids to test spending scenarios without touching their actual balance.
* **Layout:** 
  * A semi-transparent bottom sheet slides up covering the lower half of the sandbox.
  * Includes a custom number pad or price slider (e.g., `$14.00`).
  * **Interaction:** When a price is set, a glowing green "Purchase Tray" drops onto the sandbox screen. Kids drag bills into the tray. As bills enter the tray, a live counter shows remaining balance vs. price cost.
  * **Non-negotiable Safety Banner:** A persistent, high-contrast badge displays: `PRETEND PLAY ONLY — REAL CARD BALANCE UNCHANGED`.

#### 3. Parent PIN Gate Overlay
* **Purpose:** Restricts balance editing, profile management, and settings behind a 4-digit PIN.
* **Layout:** Playful yet secure geometric number pad dialog.
* **First-Run State:** Prompts parent to set a new 4-digit PIN and configure a security recovery question (e.g., "Mom's favorite city?").

#### 4. Parent Control Panel (Admin Center)
* **Purpose:** Manual balance updates, child profile creation, and sync management.
* **Layout:**
  * **Kid Balance Cards:** List showing each boy with an editable balance field (accepts formatted dollar inputs, stored internally as integer cents).
  * **Honest Provenance Subtitle:** Underneath each boy's balance field, exact metadata is displayed:
    * *Current Build (Manual Fallback):* `Set by Dad (Brian) on Oct 24, 4:15 PM`
    * *Future Build (Plaid Active):* `Live Read-Only Sync • Bangor Savings Bank via Crew`
  * **Kid Profile Editor:** Add child, edit display name, change theme color accent, select avatar emblem.
  * **PIN & System Controls:** Change PIN, reset security question, toggle high-contrast mode, toggle sound effects.

---

### B. Gestures, Motion, Haptics & Audio

#### Gestures
* **Single Finger Touch & Drag:** Pick up any bill or coin, moving it around with momentum. Releasing throws the bill across the canvas.
* **Flick / Swipe Impulse:** Rapid swipe on a bill/coin imparts directional velocity vector, letting kids slide coins across the felt surface.
* **Two-Finger Pinch Spread:** Spreads out a tightly organized stack of bills into an overlapped hand layout.
* **Long-Press on Stack:** Holds a stack together to move the entire bundle as one physical mass.

#### Motion & Physics Spec
* Built using a custom 2D canvas particle-and-body solver (`forge2d` / Flutter `CustomPainter`).
* **Rigid Body Properties:**
  * *Bills:* Higher air resistance (drag factor 0.8), slight angular rotation on release (simulating paper aerodynamics), low restitution (bounciness 0.1).
  * *Coins:* Low friction, high mass density, crisp elastic restitution (bounciness 0.45) for metallic clinks against edges.
* **Stack Snap Animation:** Spring damping curves (`Curves.elasticOut`, duration 450ms) smoothly align loose cash into neat offset columns when pressing "Tidy".

#### Haptic Feedback Strategy (Device-optimized for Samsung Galaxy S26 Ultra)
* **Coin Pick-Up / Edge Bump:** Short sharp click (`HapticFeedback.lightImpact`).
* **Bill Drag / Slide:** Continuous subtle micro-vibration pulses during dynamic drag (`HapticFeedback.selectionClick`).
* **Stack Snap / Lock:** Strong, crisp thud (`HapticFeedback.heavyImpact`).
* **Incorrect PIN Entry:** Double heavy vibrate pattern (`HapticFeedback.vibrate`).

#### Audio Cues (Optional sound toggle in settings)
* **Coin Collisions:** Multi-sampled metallic *clink-clink* pitched dynamically by coin velocity.
* **Bill Flick:** Crisp paper *swish*.
* **Tidy Snap:** Snappy arcade chime.

---

### C. Visual Design System

#### Color Palette
```
┌──────────────────────────────────────────────────────────────┐
│  PRIMARY BASE & VAULT FLOOR                                   │
│  [#0F172A] Deep Vault Slate   [#1E293B] Canvas Surface Teal   │
├──────────────────────────────────────────────────────────────┤
│  KID ACCENTS                                                 │
│  [#FF6B00] Neon Citrus (Kid 1) [#00E5FF] Cyber Cyan (Kid 2)  │
├──────────────────────────────────────────────────────────────┤
│  PLAY MONEY PALETTE (Strictly Distinct from US Currency)     │
│  $1  [#2DD4BF] Mint Cyan / Dark Cyan Trim                    │
│  $5  [#3B82F6] Electric Cobalt / Navy Trim                   │
│  $10 [#F97316] Sunset Amber / Rust Trim                      │
│  $20 [#A855F7] Cosmic Violet / Deep Purple Trim              │
│  Coins: [#F59E0B] Brass Gold (25¢) / [#94A3B8] Silver (10¢/5¢)│
└──────────────────────────────────────────────────────────────┘
```

#### Typography
* **Display & Headers:** `GoogleFonts.fredoka` (Weight: 700 / Bold). Chunky, rounded, punchy comic energy.
* **Monetary Values & Counts:** `GoogleFonts.jetBrainsMono` (Weight: 800 / Extra Bold). Ultra-legible, mechanical precision.
* **Body Text & Labels:** `GoogleFonts.plusJakartaSans` (Weight: 600 / Semi-Bold). Modern, clean Android legibility.

#### Play Money Art Rules
1. **Zero US Currency Similarity:** Bills use vibrant neon tinting, diagonal stripe geometric patterns, comic iconography, and rounded corners.
2. **Mandatory Disclaimer:** Every play bill features explicit front-and-center lettering: `CREW PLAY CASH • NOT LEGAL TENDER`.
3. **Custom Center Crests:** Rocket ships, star shields, robot heads, and energetic lightning bolts replace presidential portraits.

#### Kid Personalization
* **Profile Avatars:** 8 distinct vector icon badges (Cosmic Rocket, Ninja Shield, Laser Dino, Arcade Controller, Cyber Shark, Skate Deck, Comet, Mech Suit).
* **Vault Themes:** Choice of floor background textures (Deep Felt Teal, Neon Arcade Grid, Comic Stash Purple, Solar Gold).

---

### D. Money Model & Denomination Splitting Engine

#### Data Integrity Architecture
* **Strict Constraint:** Monetary balances are **always** passed, stored, and calculated as `int` (representing integer cents). Floating-point `double` is strictly forbidden to eliminate rounding errors.
* **Range:** `0` cents ($0.00) to `9999999` cents ($99,999.99).

```dart
/// Core Money Model Definition
class MoneyBalance {
  final int totalCents;

  const MoneyBalance(this.totalCents) : assert(totalCents >= 0);

  double toDollars() => totalCents / 100.0;
  String toFormattedString() => '\$${(totalCents / 100).toStringAsFixed(2)}';
}
```

#### Breakdown Algorithm
When given an integer balance in cents, the breakdown engine computes the optimal physical visual count while keeping object count under a performance threshold (maximum 45 active physics sprites).

```dart
class DenominationBreakdown {
  final int twenties;
  final int tens;
  final int fives;
  final int ones;
  final int quarters;
  final int dimes;
  final int nickels;
  final int pennies;

  DenominationBreakdown({
    required this.twenties,
    required this.tens,
    required this.fives,
    required this.ones,
    required this.quarters,
    required this.dimes,
    required this.nickels,
    required this.pennies,
  });

  factory DenominationBreakdown.fromCents(int cents) {
    int rem = cents;

    // Standard greedy breakdown
    int w20 = rem ~/ 2000; rem %= 2000;
    int w10 = rem ~/ 1000; rem %= 1000;
    int w5  = rem ~/ 500;  rem %= 500;
    int w1  = rem ~/ 100;  rem %= 100;
    int c25 = rem ~/ 25;   rem %= 25;
    int c10 = rem ~/ 10;   rem %= 10;
    int c5  = rem ~/ 5;    rem %= 5;
    int c1  = rem;

    // Performance Cap Rule: If total sprites > 40, consolidate excess into $20s
    int totalSprites = w20 + w10 + w5 + w1 + c25 + c10 + c5 + c1;
    if (totalSprites > 40) {
      // Clamped optimization logic handles high-balance display
      return DenominationBreakdown._clampedBreakdown(cents);
    }

    return DenominationBreakdown(
      twenties: w20, tens: w10, fives: w5, ones: w1,
      quarters: c25, dimes: c10, nickels: c5, pennies: c1,
    );
  }

  static DenominationBreakdown _clampedBreakdown(int cents) {
    // Keeps physics engine smooth while maintaining exact mathematical sum
    int rem = cents;
    int w20 = rem ~/ 2000; rem %= 2000;
    // Compress lower denominations into primary bills...
    int w10 = rem ~/ 1000; rem %= 1000;
    int w5  = rem ~/ 500;  rem %= 500;
    int w1  = rem ~/ 100;  rem %= 100;
    int c25 = rem ~/ 25;   rem %= 25;
    return DenominationBreakdown(
      twenties: w20, tens: w10, fives: w5, ones: w1,
      quarters: c25, dimes: 0, nickels: 0, pennies: rem % 25,
    );
  }
}
```

#### Empty & Zero-Balance States
* If `totalCents == 0`, the sandbox displays a shiny, clean empty vault floor with a single comical golden piggy bank sleeping soundly in the center. Tapping the piggy bank makes it pop out a tiny speech bubble: `"Empty vault! Time for some chores!"`

---

### E. Accessibility & Ergonomics

* **Large Target Dimensions:** Target size for touch elements exceeds Android Material 3 minimums (minimum touch target 56x56dp; physical play bills are rendered at a minimum touchable surface of 110x55dp on the Galaxy S26 Ultra screen).
* **High-Contrast Text Mode:** Toggleable setting forces stark black backings behind yellow/white balance digits for outdoor visibility.
* **TalkBack / Screen Reader Support:** Every object rendered on the physics canvas emits detailed dynamic semantics:
  * `Semantics(label: "Five dollar play bill. Drag to move, or double tap to group.")`
  * `Semantics(label: "Total balance: 43 dollars and 50 cents. Consists of 5 bills and 6 coins.")`
* **Motor Assistance Mode:** An optional "Tap-to-Sort" toggle in parent settings disables freeform dragging physics for kids with fine motor challenges, substituting tap-based stacking into neat columns.

---

### F. Plaid Read-Only Architecture (Future-Proof Strategy)

To support read-only banking synchronization without altering the UI, the app implements a clean **Repository Pattern**.

```
┌───────────────────────────────────────────────────────────┐
│                    Kid Vault UI Layer                     │
└─────────────────────────────┬─────────────────────────────┘
                              │ Taps into Stream<MoneyBalance>
                              ▼
┌───────────────────────────────────────────────────────────┐
│                 BalanceRepository (Abstract)              │
└──────────────┬─────────────────────────────┬──────────────┘
               │                             │
               ▼                             ▼
┌──────────────────────────────┐ ┌──────────────────────────┐
│ LocalBalanceRepository       │ │ PlaidBalanceRepository   │
│ (First Build: Hive / Local)  │ │ (V2: Read-Only Proxy API)│
└──────────────────────────────┘ └──────────────────────────┘
```

#### UI Slotting Strategy
The **Total Balance Badge** at the top of the main screen contains a dynamic metadata subtitle.
* **First Build (Manual Fallback):** Displays `Set by Dad • 2h ago`
* **V2 Build (Plaid Active):** Displays `Live Sync • Bangor Savings Bank`

Because the UI strictly consumes `Stream<MoneyBalance>`, enabling Plaid in V2 requires swapping the underlying data provider in service locator configuration—**zero screen redesign or layout changes required**.

---

## 4. Asset Generation Spec & Prompts

Below is the complete list of 10 graphics required for build completion. All assets are designed to be generated via standard high-resolution diffusion image models.

---

### Asset 1: `app_icon.png`
* **Purpose:** Android application launch icon.
* **Dimensions:** 1024 × 1024 pixels.
* **Background:** Transparent.
* **Prompt:**
  > A bold, vibrant 3D app icon featuring a chunky cartoon safe vault door painted in electric teal and cyan, slightly open, with glowing golden play coins and vibrant purple and green toy cash bursting out with energetic motion lines. Ultra-clean graphic design, stylized thick outer lines, modern 3D cartoon render, highly detailed, vibrant colors, isolated on pure black background for easy transparency cutting, zero text, zero realistic money, mobile app icon style, 8k resolution, raytraced lighting.

---

### Asset 2: `hero_mockup.png`
* **Purpose:** High-impact hero marketing presentation mockup of the main app experience.
* **Dimensions:** 3840 × 2160 pixels (16:9 4K resolution).
* **Background:** Opaque dark stylized studio background.
* **Prompt:**
  > A sleek modern smartphone screen floating in a clean dark studio setup. On the phone screen, a vibrant Flutter app titled "Crew Stash" is running, showing a dark teal textured vault surface covered with interactive toy play money—bright violet $20 play bills with comic rockets, turquoise $1 play bills, and polished brass coins piled dynamically with 2D physics. Dynamic floating lighting, rich high-contrast colors, vivid UI elements, clean modern Android layout, high-end promo graphic showcase, photorealistic phone hardware mockup, sharp focus.

---

### Asset 3: `play_bill_1.png`
* **Purpose:** Textural overlay graphics for the $1 Play Cash bill.
* **Dimensions:** 1200 × 600 pixels (2:1 aspect ratio).
* **Background:** Transparent.
* **Prompt:**
  > A flat 2D graphic design of a toy play money bill worth 1 dollar. Color scheme is bright mint cyan and dark green. Features a cartoon cosmic rocket ship emblem in the center oval. The text explicitly reads "CREW PLAY CASH" at the top and "NOT LEGAL TENDER" at the bottom. Large chunky number "1" in all four corners. Stylized geometric border patterns, thick clean comic vector illustration style, vibrant play currency, transparent background, isolated, vector quality, crisp edges.

---

### Asset 4: `play_bill_5.png`
* **Purpose:** Textural overlay graphics for the $5 Play Cash bill.
* **Dimensions:** 1200 × 600 pixels (2:1 aspect ratio).
* **Background:** Transparent.
* **Prompt:**
  > A flat 2D graphic design of a novelty play money bill worth 5 dollars. Color scheme is vivid electric cobalt blue with deep navy accents. Features a stylized cartoon lightning bolt badge in the central medallion. The text reads "CREW PLAY CASH" across the top and "NOT LEGAL TENDER" along the bottom margin. Large bold number "5" in each corner. Futuristic comic border graphics, isolated on transparent background, clean vector artwork, vibrant toy cash design.

---

### Asset 5: `play_bill_10.png`
* **Purpose:** Textural overlay graphics for the $10 Play Cash bill.
* **Dimensions:** 1200 × 600 pixels (2:1 aspect ratio).
* **Background:** Transparent.
* **Prompt:**
  > A flat 2D graphic design of a stylized novelty toy bill worth 10 dollars. Color palette is bright sunset orange and rust brown trim. Features a playful cartoon solar shield emblem in the center circle. Contains explicit text reading "CREW PLAY CASH" at the top and "NOT LEGAL TENDER" below. Prominent bold number "10" on all corners. Dynamic graphic arts style, clean vector line art, transparent background, crisp isolated graphics.

---

### Asset 6: `play_bill_20.png`
* **Purpose:** Textural overlay graphics for the $20 Play Cash bill.
* **Dimensions:** 1200 × 600 pixels (2:1 aspect ratio).
* **Background:** Transparent.
* **Prompt:**
  > A flat 2D graphic design of a toy play bill worth 20 dollars. Color theme is vibrant cosmic neon violet and deep purple trim. Features a cool mechanical robot mask icon inside the central ring. Features clear wording "CREW PLAY CASH" and "NOT LEGAL TENDER". Large chunky "20" digits in every corner. Energetic arcade style, bold outline stroke, clean graphic vector render, transparent background.

---

### Asset 7: `play_coin_25.png`
* **Purpose:** Graphic asset for the 25-cent (Quarter) play coin.
* **Dimensions:** 512 × 512 pixels (1:1 square ratio).
* **Background:** Transparent.
* **Prompt:**
  > A flat 2D cartoon gold brass coin, top-down view, circular shape. Features an embossed graphic of a stylized cyber shark head in the center, surrounded by a micro-notched metallic edge. Big readable text "25¢" stamped clearly on the coin face. Metallic gold highlights, warm dynamic shading, isolated on transparent background, video game item icon style, clean vector artwork.

---

### Asset 8: `play_coin_10.png`
* **Purpose:** Graphic asset for the 10-cent (Dime) play coin.
* **Dimensions:** 400 × 400 pixels (1:1 square ratio).
* **Background:** Transparent.
* **Prompt:**
  > A top-down 2D vector art illustration of a shiny nickel-silver play coin, circular format. Stamped with a central emblem of a cartoon star-burst and the clear bold text "10¢". Bright silver metallic reflections, crisp clean rim design, isolated on transparent background, arcade game style, high quality UI asset.

---

### Asset 9: `vault_background_felt.png`
* **Purpose:** Background texture canvas for the main Sandbox Vault screen.
* **Dimensions:** 1440 × 3120 pixels (9:19.5 aspect ratio for modern phone displays).
* **Background:** Opaque.
* **Prompt:**
  > A high-resolution top-down game background texture of a dark slate-teal gaming vault table surface. Made of soft matte felt fabric with subtle micro-textures, framed by soft ambient vignetting along the edges. Minimalist background design, non-distracting pattern, clean dark aesthetic, 4k texture quality, perfect for rendering floating UI components on top.

---

### Asset 10: `wishlist_tray_icon.png`
* **Purpose:** Drawer pull handle icon for triggering the "What-If" Purchase Simulator.
* **Dimensions:** 512 × 512 pixels (1:1 square ratio).
* **Background:** Transparent.
* **Prompt:**
  > A 3D cartoon style icon of a futuristic barcode price scanner combined with a golden price tag. Electric citrus orange color theme with glowing cyan accents. Dynamic angled perspective, thick rounded cartoon edges, clean stylized shading, isolated on transparent background, mobile app action button graphic.