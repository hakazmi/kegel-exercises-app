# Decisions log

One line per decision the product spec does not cover. Format: `YYYY-MM-DD — Decision.`

2026-11-12 — Safety rules: keep all 9 (spec heading says eight; numbered list plus never-diagnoses paragraph).
2026-11-12 — Build steps: use the owner's Prompt 0–13 pack in docs/progress.md, not the M1–M5 mapping.
2026-11-13 — Android and iOS are both first-class from now on; every step is tested on both platforms.
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
2026-11-13 — Session haptics use the `vibration` package (custom patterns with HapticFeedback fallback). Allowed dependency for Prompt 5.
2026-11-13 — Haptics go through HapticsService: Android keeps `vibration` patterns; iOS uses HapticFeedback (heavy/medium/vibrate). TTS on iOS uses ambient + mixWithOthers so the audio session does not block haptics.
2026-11-13 — S3 phase countdown: bare seconds under 60; `m:ss` (unpadded minutes) at 60+. Elapsed clock stays zero-padded `mm:ss`. Last-block next label is "Finish".
2026-11-13 — Android main manifest declares VIBRATE only; debug/profile also merge INTERNET; flutter_local_notifications merges POST_NOTIFICATIONS (for Prompt 9). Portrait-only via Flutter + AndroidManifest + Info.plist. S2/S3 use PopScope so system back matches Exit confirm. Edge-to-edge uses AppSystemUi light/dark (and S1 dark-header/light-body) for status + nav icons.
2026-11-13 — H1 level card title is "Level N · Name" (relaxation-first: "Relaxation · Weeks 1 to 2"); progress row is "D of T days" with the bar (no duplicate Day line). T for strengthening is the level dayStart/dayEnd span (Level 5 uses the 7-day unlock window); relaxation-first T is 14 days (spec: 2 weeks).
2026-11-13 — H2 on relaxation-first: current card is the relaxation plan (Days 1–14) with progress; Level 1 is not Current and shows the clinician-start note; subtitle uses the relaxation line; strengthening levels stay listed below with Premium locks unchanged.
2026-11-13 — isPremiumProvider stubs false until RevenueCat (Prompt 10); /dev/data can override. Locked Levels 2–5 open paywall with ?source=locked_content.
2026-11-13 — MainShell PopScope: Android back on Progress/Learn goes to Today; on Today calls SystemNavigator.pop. Tab stacks stay independent via StatefulShellRoute.
2026-11-13 — H1 catheter "Update my answer" opens Settings → Safety answers (re-runs SafetyRouting); it does not clear the catheter flag directly. Debug day tools use debugDayOffsetProvider → OffsetClock so PlanService/streak see the shifted "today".
2026-11-13 — compileSdk 37 and desugaring are required by flutter_local_notifications.
2026-11-13 — G2 check-in stores normalised scores 1 = worst … 5 = best. On-screen option order: bladder keeps Never at the top but maps Never = 5 / Every day = 1; other goals top = worst. Approved wording — surgery: "In the last week, how well have you controlled your urine?" (No control → Full control); general: "In the last week, how comfortable has your pelvic area felt?" (Very uncomfortable → Very comfortable). Bladder / erection / ejaculation questions unchanged. Comparison lines show "Week N: S of 5 · label".
2026-11-13 — G2 doctor hint fires when the latest normalised score is still 1 after ≥8 weeks from baseline. Bladder "Never" (normalised 5) never triggers the hint.
2026-11-13 — Check-in history UI is premium: free users see the baseline row only; all scores still store locally in Drift and never reach AnalyticsService.
2026-11-13 — package_info_plus approved for Settings version line.
2026-11-13 — flutter_timezone approved to read the device IANA time zone for reminder scheduling. ReminderService uses flutter_local_notifications with AndroidScheduleMode.inexactAllowWhileIdle (no exact-alarm permission). Android channel name "Daily reminder"; boot receivers in the app manifest. Permission requested only on O5 "Remind me" or Settings reminder on.
2026-11-13 — Level unlock never advances silently. Offer shows on Today and S4 when the level span is complete and ≥5 of the last 7 days are done. Start Level 2–5 for free users opens paywall (?source=locked_content); premium advances level + levelStartedOn. Stay snoozes until the next completed session. Relaxation-first never unlocks; return path is Settings → Safety answers (clear pain → SafetyRouting restores the goal track at Level 1).
2026-11-13 — Learn articles: 8 Markdown drafts under assets/content/articles with "DRAFT: content pending review"; index in articles.json (title, minutes, image, sources). Featured card is "Finding the right muscles" and opens tutorial replay; other seven list with thumbnails. SimpleMarkdown renderer (no flutter_markdown). Spec section 9 lists 8 titles; all are present (1 featured + 7 list). Learn thumbnails use a fixed 56×56 BoxFit.contain slot.
2026-11-13 — H1 relaxation-first card title is "Weeks 1 to 2" (eyebrow already says the track). G1 fourth tile on that track: label "Relaxation plan", value "Day D of 14".
2026-11-13 — Settings safety answers re-use O3 routing via SafetyRouting (pain → relaxation-first; catheter blocks Today; Learn stays available). Delete-all clears Drift + prefs, cancels ReminderService, resets onboarding draft, goes to Welcome.
