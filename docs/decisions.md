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
2026-11-12 — Drift codegen helpers allowed: `drift_dev`, `build_runner`, `path`, `path_provider`, `sqlite3_flutter_libs` (dev deps where appropriate).
2026-11-12 — Sessions table includes `kind` (strengthening|breathing|relaxation) in addition to the spec column list so the daily strengthening cap can be enforced.
2026-11-12 — Weekly rest day defaults to Sunday via `UserProfile.restWeekday` (ISO 7), changeable later in Settings. Spec does not name the day.
2026-11-12 — Rest day never applies until the user has completed at least one session, so install-on-rest-weekday still gets a normal Level 1 Day 1.
2026-11-12 — O3 catheter path: save profile with catheter flag, skip O4–O6, set onboardingDone, go to H1 (blocked state in Prompt 6).
2026-11-12 — O6 relaxation-first plan: distinct card (child.svg, "Relaxation · Weeks 1 to 2", daily breathing/stretches meta from PlanService minutes) and its own What-to-expect copy; other tracks keep Level 1 card with real track names (General and bladder, etc.).
2026-11-12 — O3 safety messages sit in a pinned live-region panel between the options list and Next (max 40% height); surgery confirm label is "I understand".
2026-11-12 — O3 catheter overrides other safety messages (panel shows catheter only; Continue to Today enabled); surgery "I understand" is a fixed row above Next; list keeps ≥3 option rows on 360×640 by shrinking the panel.
2026-11-12 — Anatomy diagram labels are Flutter Text overlays on anatomy_side.svg (flutter_svg skips text); T1 replay via ?replay=1 does not set tutorialDone; S1 takes ?itemId= for the plan item.
2026-11-13 — ProgressHeader uses content horizontal padding (xl); step label is intrinsic-width and right-aligned on that edge.
2026-11-13 — S1 eyebrow for relaxation-first is "Relaxation · Day N" (no "Level"); block rows show exercises.json one-line descriptions (Reverse Kegel copy also in ARB).
2026-11-13 — Dark session chrome (T1 practice, S1 header, S2–S4 placeholders) uses AnnotatedRegion light status-bar icons.
2026-11-13 — Anatomy Tailbone label is right-aligned at x=246 (mirrors Pubic bone inset) so "Tailbone" stays inside the 260-wide viewBox.
2026-11-13 — T1 card 3 title is "Do and don't"; grey body under the title removed (it duplicated the checklist).
2026-11-13 — O6 "about N min" is the ceil of summed TodayPlan item durations for a typical day (Level 1 strength length from levels.json via SessionDefinitionBuilder).
