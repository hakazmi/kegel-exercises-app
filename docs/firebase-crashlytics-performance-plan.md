# Firebase Crashlytics + Performance — integration plan

**Status:** implemented (Prompt 11). Keep this doc as the source of truth for what we measure.  
**Product step:** Prompt 11 in `docs/progress.md` (Analytics, Crashlytics, Performance, privacy).

This plan tells **how** to wire Firebase the way PoseCoach (`E:\pose_correction`) and FocusFlow (`E:\Screen-time_android_app`) already do, adapted to this Flutter Kegel app, its clinical privacy rules, and the existing `AnalyticsService` stub.

---

## 0. Ground rules (read first)

1. **No implementation in this doc.** Packages, Gradle plugins, and code land only when Prompt 11 is executed.
2. **Ask before adding packages** (project rule). Prompt 11 already names: `firebase_core`, `firebase_analytics`, `firebase_crashlytics`. Add **`firebase_performance`** in the same Prompt so one Firebase bootstrap covers all three.
3. **Privacy hard rules (never leave the phone → Crashlytics, Performance, Analytics, or logs):**
   - Safety answers (`pain`, `painSexual`, `recentSurgery`, `catheter`)
   - Session **feel** (`fine` / `mildDiscomfort` / `pain`)
   - Check-in **scores** and free-text clinical content
   - Email, display name, Supabase `user_id`, auth tokens
   - Full URLs with query tokens, file paths, raw SQL, stack traces that embed PII
4. **Allowed on diagnostics:** anonymous install id, app version/build, build type, coarse plan labels (level number, track id, screen name), counts, durations, booleans (e.g. `signed_in`, `voice_on`), non-PII error codes.
5. **Analytics ≠ Crashlytics.** Spec section 14 events stay product metrics. Crashlytics is for crashes/non-fatals + breadcrumbs. Performance is for latency traces. Do not dump section-14 events into Crashlytics logs.
6. **Collection can be toggled** (FocusFlow pattern): honor a Settings/debug flag and disable both Crashlytics and Performance together when off; delete unsent reports when disabling.
7. **Debug vs release:** allow Firebase in debug for verification (FocusFlow), but mark `build_type` / version suffix so console noise is filterable. Prefer not forcing fatal test crashes in production builds.
8. **Do not sync on hot paths.** Session player ticks, haptics, video frames, and countdown must not start/stop Performance traces per frame. Session-scoped traces only (PoseCoach rule).
9. **Separate Firebase project for this app** (same idea as separate Supabase projects). Do not reuse FocusFlow or PoseCoach Firebase projects or `google-services.json`.
10. **`google-services.json` / `GoogleService-Info.plist` stay out of git** (FocusFlow `apk_setup.md`). Document placement in a local setup note.

---

## 1. What PoseCoach and FocusFlow already do (patterns to copy)

### Shared pattern

| Piece | PoseCoach | FocusFlow | Copy for Kegel? |
|-------|-----------|-----------|-----------------|
| Thin diagnostics facade | `CrashlyticsDiagnostics` | `Diagnostics` | **Yes** — Flutter ports |
| Anonymous `installation_id` | Yes | Yes | **Yes** |
| Custom keys: app version, build, device (Pose) / build_type (Focus) | Yes | Yes | **Yes** (device model optional; Crashlytics already attaches device) |
| Breadcrumbs via `.log(...)` capped length | 300 chars | 300 chars | **Yes** |
| `recordException` for caught failures | Yes | Yes | **Yes** |
| Reset install id after wipe / delete account | Yes | Yes | **Yes** |
| `FIREBASE_ENABLED` / graceful no-config | — | Yes | **Yes** (Flutter: missing options → no-op) |
| Collection enable toggle | — | Yes | **Yes** |
| Performance wrapper `start` / `stop` / `abandon` / attributes / metrics | `PerformanceTraces` | `PerfTraces` | **Yes** |
| Abandon failed traces (don’t call `stop`) so averages stay clean | Yes | Yes | **Yes** |
| Session-scoped pose traces, **never per frame** | Yes | Yes | N/A (no camera); apply same rule to **session / video** |
| Google Analytics | Used elsewhere as product analytics | **Off** in their Firebase project | Kegel: **Analytics on** for Prompt 11 section-14 events only |
| Fatal / non-fatal test hooks | Yes | Yes | Debug / Data Debug only |

### FocusFlow Performance traces (relevant analogues)

| Trace | Meaning | Kegel analogue |
|-------|---------|----------------|
| `app_hydrate` | Load prefs / repository at start | `app_hydrate` — Drift open + prefs + content preload |
| `sync_push` / `sync_pull` | Cloud upload / download | Same names for Supabase sync |
| `account_action` | Reset / delete account | Same |
| `lock_show_latency` / `monitor_session` | App-specific | Skip |
| `pose_*` | Camera | Skip; use session/video traces instead |

### PoseCoach Performance traces (relevant analogues)

| Trace | Meaning | Kegel analogue |
|-------|---------|----------------|
| `pose_model_loading` / `camera_initialization` | Heavy init | `session_engine_build`, `video_init` |
| `pose_inference` / `frame_processing` | Session metrics | `session_play` with metrics (duration, blocks, optional jank) |
| `progress_tab_open` | UI open | Optional `screen_open` for heavy tabs |

---

## 2. Current Kegel state (baseline)

| Area | Today |
|------|--------|
| Firebase packages | **Not in** `pubspec.yaml` (removed until Prompt 11 — `docs/decisions.md`) |
| Analytics | `lib/core/services/analytics_service.dart` → `ConsoleAnalyticsService` only |
| Events already called | `onboarding_step` / `onboarding_done`, tutorial, `session_start` / `session_done` / `session_exit`, `level_up` (see controllers) |
| Spec events still to wire fully | `paywall_view`, `trial_start` / `purchase`, `reminder_change` — when paywall/RevenueCat is live |
| Crashlytics / Performance | None |
| Sync | Supabase present; flush paths are the right place for `sync_*` traces |
| Known fragile areas | Exercise video decode (Xiaomi/Redmi), session complete navigation, large media, TTS + video audio focus |

---

## 3. Target architecture (Flutter)

Mirror the native facades; keep screens free of Firebase imports.

```
lib/core/diagnostics/
  installation_id.dart      # prefs-backed UUID; reset on wipe/delete account
  crash_reporting.dart      # Crashlytics facade (no-op if Firebase off)
  performance_traces.dart   # Perf facade + abandon
  diagnostics_bootstrap.dart # init after Firebase.initializeApp

lib/core/services/
  analytics_service.dart    # keep interface; add FirebaseAnalyticsService impl
```

**Providers**

- `crashReportingProvider` / `performanceTracesProvider` (or static facades like FocusFlow if preferred)
- `analyticsServiceProvider` → Firebase impl in release/profile when configured; console in tests
- Override all three in widget tests with no-ops

**Bootstrap (`main.dart`)**

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp()` inside `runCatching` / try — if config missing, leave diagnostics as no-ops
3. `CrashReporting.initialize(...)` — install id, version, build_type, breadcrumb `App started`
4. Then existing app wiring (prefs, Supabase, Riverpod)

**Platform**

- Android: Google Services plugin + Crashlytics Gradle plugin + Performance plugin (FocusFlow `build.gradle.kts` pattern; apply only when `google-services.json` exists)
- iOS: `GoogleService-Info.plist`, enable Crashlytics/Performance in Firebase console; watch binary size (reason Firebase was deferred)

---

## 4. Crashlytics — what to trace (important)

### 4.1 Custom keys (set at start; update on change)

| Key | Source | Notes |
|-----|--------|-------|
| `installation_id` | Local UUID | Never Supabase uid |
| `app_version` | `package_info_plus` | `name (buildNumber)` |
| `build_type` | `kDebugMode` / flavor | `debug` / `profile` / `release` |
| `signed_in` | Auth state | Boolean only |
| `cloud_sync_enabled` | Config flag | Boolean |
| `onboarding_done` | Profile | Boolean |
| `tutorial_done` | Profile | Boolean |
| `track` | `TrackId` content id | Coarse label only |
| `level` | Profile level 1–5 | Int |
| `screen` | go_router location name | Update on route changes (FocusFlow `screen` key) |
| `session_kind` | While in S2–S4 | `strengthening` / `breathing` / … clear when leaving |
| `voice_on` / `vibration_on` | Settings | Booleans useful for crash clusters |

**Never set:** goal free text beyond track id if sensitive; feel; safety flags; email; check-in score.

### 4.2 Breadcrumbs (`log`, ≤300 chars)

Fire at coarse lifecycle points (not every timer tick):

- App / session started  
- Auth: signed in / signed out / Google start / fail (error code only)  
- Onboarding step route  
- Tutorial start / done  
- Session: before → countdown → player start → pause/resume → done / exit  
- Level unlock: offered / start next / stay  
- Sync: push/pull start / success / fail (status only)  
- Video: init start / ready / error / fallback to poster  
- Reminder schedule success / fail  
- Data reset / account delete  

### 4.3 Non-fatal `recordException`

Catch and record (after local handling) for:

- Drift open / migration failures  
- Session engine unexpected state  
- Video controller init / playback failures  
- TTS init failures  
- Sync coordinator batch failures  
- Notification plugin schedule failures  
- JSON content parse failures  

Do **not** record expected user cancels or “item already done” UI toasts.

### 4.4 Test hooks (debug / Data Debug only)

Same as FocusFlow/PoseCoach:

- “Send test non-fatal”  
- “Force test fatal crash” (debug only; never in store builds)

---

## 5. Performance — what to measure (important)

Automatic **App start** from Firebase Performance is enough for cold start overview. Add **custom traces** only where they answer product/engineering questions.

### 5.1 Must-have traces

| Trace name | Start | Stop | Attributes / metrics |
|------------|-------|------|----------------------|
| `app_hydrate` | After Firebase init, before first frame of real UI | Prefs + DB + content providers ready | `signed_in`, duration; abandon on fatal init fail |
| `session_engine_build` | Building S3 timeline / definition | Engine ready | `level`, `kind`, `block_count` |
| `session_play` | S3 play starts | S3 done or exit | `level`, `kind`; metrics: `elapsed_sec`, `completed` (0/1), optional `pause_count` |
| `video_init` | `VideoPlayerController` create | `initialize` success or fail | `asset` basename only; metric `ok` 0/1; **abandon** on cancel/dispose mid-init |
| `sync_push` | Sync upload batch starts | Batch finishes | `row_count`; abandon on cancel |
| `sync_pull` | Sync download starts | Finishes | same |
| `account_action` | Reset data / delete account tapped | Action finished | `action=reset\|delete` |

### 5.2 Nice-to-have traces (second pass)

| Trace | Why |
|-------|-----|
| `today_plan_build` | PlanService + content resolve latency |
| `levels_screen_open` | Heavy H2 with many cards / images |
| `progress_screen_open` | Calendar + stats |
| `learn_article_open` | Media carousel / large images |
| `reminder_reschedule` | Notification plugin cost |

### 5.3 Explicitly out of scope for Performance

- Per-rep / per-tick session ring updates  
- Per-video-frame or ExoPlayer buffer callbacks as traces  
- Tracing every Riverpod rebuild  
- Pose/camera traces (this app has no live pose pipeline)

### 5.4 Network

Firebase Performance HTTP instrumentation (release, or debug flag like FocusFlow `PERF_INSTRUMENT_DEBUG`) will show Supabase calls. Do not put tokens in URL query strings.

---

## 6. Analytics (Prompt 11) — keep aligned

Implement `FirebaseAnalyticsService` behind the existing interface. Spec section 14 only:

| Event | Properties allowed |
|-------|-------------------|
| `onboarding_step` | `step` |
| `onboarding_done` | `sessions_per_day`, `reminder_on` |
| `tutorial_done` | `felt_lift` (`yes` / `not_sure` only) |
| `session_start` | `level`, `session_number_today` |
| `session_done` | `level`, `seconds` |
| `session_exit` | `level`, `phase` |
| `paywall_view` | `source` |
| `trial_start`, `purchase` | `plan` (product id / period — no price hardcoding) |
| `level_up` | `level` |
| `reminder_change` | `on` / `off` |

**Funnel to watch (spec):** install → onboarding done → first session done → day-2 return → day-7 return → trial/purchase → day-30 return.

Verify with a debug logger or Analytics DebugView that **feel**, safety, and check-in scores never appear.

---

## 7. Privacy, consent, and store listing

1. Update **Privacy Policy** for Crashlytics, Performance, and Analytics (device data, crash stacks, performance metrics).  
2. Play **Data safety** / Apple privacy nutrition labels — crash logs, diagnostics, analytics.  
3. Optional Settings row: “Share crash & performance data” (FocusFlow preference sync pattern). Default **on** for v1 unless legal says otherwise.  
4. On **Reset data** / **Delete account**: call `resetInstallationId()` so future reports are not joined to the wiped identity.  
5. Confirm Crashlytics console **PII scrubbing** / disable automatic collection of unnecessary breadcrumbs if any plugin adds them.

---

## 8. Implementation phases (when Prompt 11 starts)

### Phase A — Firebase project + platform wiring

1. Create Firebase project for Kegel (Analytics **on**; enable Crashlytics + Performance).  
2. Register Android + iOS apps; download config files (gitignored).  
3. Add FlutterFire packages; Android/iOS Gradle/plist wiring with “config missing → build still works” guard (FocusFlow).  
4. Bootstrap `Firebase.initializeApp` + no-op fallbacks.  
5. Verify empty Crashlytics “waiting for data” then test non-fatal.

### Phase B — Diagnostics facade + keys

1. Port `InstallationId`, `CrashReporting`, `PerformanceTraces`.  
2. Init keys + app-start breadcrumb.  
3. Route observer → `screen` key + breadcrumb.  
4. Wire reset/delete to install-id reset.  
5. Data Debug: test non-fatal / fatal (debug only).

### Phase C — Wire failure sites

1. Wrap known `catch` paths (video, sync, drift, TTS, notifications).  
2. Session lifecycle breadcrumbs (start / done / exit) without feel.  
3. Auth breadcrumbs (no email).

### Phase D — Performance traces

1. `app_hydrate`, `session_engine_build`, `session_play`, `video_init`.  
2. `sync_push` / `sync_pull`, `account_action`.  
3. Confirm abandon-on-failure behavior.  
4. Optional second-pass UI traces.

### Phase E — Analytics swap

1. `FirebaseAnalyticsService` implementing existing interface.  
2. Audit every `logEvent` call site against section 14.  
3. Add missing paywall/reminder/purchase events when those features ship.  
4. Test that G2 check-in still never logs analytics (`progress_test` already expects empty).

### Phase F — Verify + docs

1. Checklist below on a real phone (include Redmi/Xiaomi if possible — video).  
2. Update `docs/progress.md` Prompt 11 tick.  
3. Short `docs/firebase-setup.md` for local `google-services.json` placement (like FocusFlow `apk_setup.md` §3).  
4. Decision log line: Performance included with Prompt 11.

---

## 9. Verification checklist (device)

| # | Step | Expected |
|---|------|----------|
| 1 | Build with config present | App starts; hydrate completes |
| 2 | Data Debug → test non-fatal | Event in Crashlytics after next launch / short delay |
| 3 | Debug build → force test crash → relaunch | Fatal in Crashlytics; keys show install id + version |
| 4 | Complete a strengthening session | Breadcrumbs for session; `session_play` + `session_engine_build` in Performance |
| 5 | Open exercise video until ready | `video_init` with `ok=1` |
| 6 | Force video failure (bad asset in debug) | Non-fatal + `video_init` abandoned or `ok=0` |
| 7 | Sign in / sync once | `sync_pull` / `sync_push`; no email in Crashlytics |
| 8 | Reset data | New `installation_id` on next reports |
| 9 | Analytics DebugView | Section-14 events only; no feel/safety/check-in |
| 10 | Build **without** config file | App runs; diagnostics no-op; no crash on init |

---

## 10. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| iOS IPA size jump from Firebase | Enable only needed products; measure before/after; defer extra Firebase kits |
| Performance plugin slows debug builds | FocusFlow note: Perf bytecode rewrite is heavy — keep debug usable; full Perf verification on profile/release |
| Over-instrumentation noise | Cap breadcrumbs; session-scoped traces only; abandon failures |
| Accidental PII | Code review checklist + unit test that analytics params deny-list sensitive keys |
| Duplicate Firebase projects / wrong `google-services.json` | Document package name; never commit secrets |

---

## 11. Out of scope (this plan)

- RevenueCat / paywall implementation (Prompt 10) — only reserve analytics event names  
- Remote Config / A/B Testing / Cloud Messaging  
- Sharing Firebase project with PoseCoach or FocusFlow  
- Live pose / camera Performance traces  
- Implementing any of the above in this pass  

---

## 12. Summary

Integrate Firebase **once** for Prompt 11 using the same facade style as PoseCoach and FocusFlow: anonymous install id, safe custom keys, coarse breadcrumbs, non-fatals on real failures, and a small set of **session- and sync-scoped** Performance traces. Keep product analytics on the existing `AnalyticsService` contract and the section-14 allowlist. Ship platform config as gitignored files with a no-config safe mode so CI and clones still build.

**Next step when ready:** execute Phase A under Prompt 11 (still a separate task from this plan doc).
