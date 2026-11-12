# Decisions log

One line per decision the product spec does not cover. Format: `YYYY-MM-DD — Decision.`

2026-11-12 — Safety rules: keep all 9 (spec heading says eight; numbered list plus never-diagnoses paragraph).
2026-11-12 — Build steps: use the owner's Prompt 0–13 pack in docs/progress.md, not the M1–M5 mapping.
2026-11-12 — One Flutter codebase for Android and iOS; first store release is Android; keep code iOS-ready (no Android-only API without a platform check); iOS submission after Prompt 13.
2026-11-12 — "Mild discomfort" twice in a row only suggests stepping down a level; never step down automatically.
2026-11-12 — Check-in baseline offered once after the third completed session overall, then every 4 weeks.
2026-11-12 — Do not hard-code prices or trial length; they come from store products via RevenueCat.
2026-11-12 — Temporary display name: "Kegel Exercises", kept in one place so it is easy to change.
2026-11-12 — `material_ui` is a required dependency because this Flutter SDK moved Material out of the framework (`package:flutter/material.dart` is deprecated; use `package:material_ui/material_ui.dart`).
2026-11-12 — Primary CTA fill is ink `#0E1412` (matches screenshots); brand/primary green remains `#0B7A4B`. Squeeze/hold ring accent is `#1AAE68`.
2026-11-12 — Light scaffold background set to `#F5F7F6` and borders to `#DCE3E0` from screenshots (pending token approval in docs/design/tokens.md).
2026-11-12 — Remove firebase_core / firebase_analytics / firebase_crashlytics until Prompt 11 (unused; heavy iOS firebase-ios-sdk). Keep purchases_flutter.
2026-11-12 — Contrast AA: textSecondary `#66706B` kept. Disabled controls and decorative ring track are WCAG-exempt: buttonDisabled `#CBD2D0`, textDisabledLabel `#6F7974`, textDisabled `#9AA39F` (icons), sessionRingTrack `#2A3430`.
