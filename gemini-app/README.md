# Crew Stash: Interactive Physics Money Vault

**Crew Stash** transforms abstract digital account numbers into dynamic, physical 2D play money. Designed specifically for kids (ages 7–9), it bridges the gap between invisible debit card balances and physical money awareness through cash sorting, realistic physics motion, and simulated "What-If" spending tests.

---

## Concept Implementation Summary
This app implements **Concept 1: Crew Stash Sandbox (Tactile Physics Engine)** from the design specification:
- **Integer Cents Engine**: All monetary values are processed, stored, and calculated strictly as integer cents (`int`), avoiding floating-point precision issues.
- **2D Physics Canvas**: Play bills ($20, $10, $5, $1) and coins (25¢, 10¢, 5¢, 1¢) bounce, drag, stack, and flick across a textured vault floor with realistic aerodynamic drag and coin elasticity.
- **Tidy & Scatter Actions**: Magnetic spring alignment stacks money by denomination; central explosive impulse scatters cash into interactive piles.
- **"What-If" Purchase Simulator**: A dedicated overlay drawer allows kids to drag cash into a purchase tray to test item costs against remaining funds. Features a mandatory high-contrast banner: `PRETEND PLAY ONLY — REAL CARD BALANCE UNCHANGED`.
- **Parent Control Panel**: Protected behind a 4-digit PIN stored securely as a SHA-256 hash. Allows setting balances, modifying kid profiles, and viewing honest provenance metadata (`Set by Dad (Brian) on Oct 24, 4:15 PM`).
- **Plaid Sync Architecture**: Implements a clean `BalanceRepository` abstraction. UI components consume `Stream<List<KidProfile>>`, enabling seamless read-only Plaid API integration in future builds without changing UI components.
- **Graceful Asset Fallbacks**: If custom PNG image assets are missing at runtime, procedural vector fallback widgets render colorful play bills with obligatory disclaimers (`CREW PLAY CASH • NOT LEGAL TENDER`).

---

## Android Setup & Permissions
- Android target SDK target standard configuration.
- Storage and preferences use local Android `SharedPreferences` (no external storage permissions required).
- No active internet permission required for this local sandbox build.

---

## Running Unit Tests
Run the included money breakdown and math tests:
```bash
flutter test
```
