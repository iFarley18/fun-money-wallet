Below is your own design document for the app, followed by the list of image assets that were generated from your asset list (they will be placed at `assets/images/<filename>` in the project). Now write the complete Flutter app that implements YOUR chosen concept as faithfully as possible.

Requirements:
- A complete, compilable Flutter project for Android: `pubspec.yaml` (name `gemini_fun_money`, Dart SDK `>=3.4.0 <4.0.0`, declare `assets/images/`), everything under `lib/`, and a small `test/` with unit tests for the money math.
- Do NOT include the `android/` folder; it will be generated with `flutter create --platforms=android --org com.ifarley .` and your files layered on top. If you need Android permissions or manifest changes, list them in README.md instead.
- Use only well-known pub.dev packages that work on current stable Flutter (for example shared_preferences, google_fonts, flutter_animate, crypto). Keep dependencies minimal.
- Integer cents everywhere. Parent PIN stored hashed, never in plain text. Local storage only. No networking in this build; leave a clearly marked interface where a read-only Plaid balance source would plug in later.
- Reference the generated images by their exact filenames. If an image is missing at runtime, fall back gracefully (e.g. drawn widgets) rather than crash.
- Include a README.md describing the app, how it maps to your design, and anything you deliberately left out.

Return ONLY JSON matching the schema: a list of files, each with a relative `path` and full `content`. No placeholders like "// rest of code here" — every file must be complete.
