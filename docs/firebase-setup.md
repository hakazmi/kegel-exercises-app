# Firebase local setup (Crashlytics + Performance + Analytics)

> Full install / Supabase / Firebase walkthrough: see root **`apk_setup.md`** (same role as FocusFlow `apk_setup.md` and PoseCoach `steps_to_build_apk.md`).

Config files are **gitignored**. Place them yourself after creating the Firebase project.

## 1) Create the Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Create a project for this app (do **not** reuse FocusFlow or PoseCoach).
3. Enable **Google Analytics** (needed for Prompt 11 product events).
4. Add an **Android** app with package `com.syarix.kegelexercisesapp`.
5. Download `google-services.json`.
6. Add an **iOS** app when you ship iOS; download `GoogleService-Info.plist`.
7. In the console: enable **Crashlytics** and **Performance**.

## 2) Place the files

| File | Path |
|------|------|
| Android | `android/app/google-services.json` |
| iOS | `ios/Runner/GoogleService-Info.plist` |

Without these files the app still builds: Firebase plugins stay off and diagnostics no-op.

## 3) Verify on a phone

1. Rebuild and install a debug APK.
2. Open **Data debug** (`/dev/data`) → **Test non-fatal**.
3. Optionally **Force test crash** (debug only), then relaunch.
4. Check Firebase Console → Crashlytics (reports after relaunch).
5. Use the app for a few minutes; Performance → Custom traces: `app_hydrate`, `session_play`, `video_init`, `sync_*`.

## Privacy

Never send safety answers, session feel, or check-in scores. Reports carry an anonymous `installation_id`, app version, and coarse labels only. See `docs/firebase-crashlytics-performance-plan.md`.
