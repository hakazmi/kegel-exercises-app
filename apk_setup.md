# Kegel Exercises (Flutter) — Setup Guide

**Product:** Men’s pelvic floor trainer (temporary display name: **Kegel Exercises**)  
**Package name:** `com.syarix.kegelexercisesapp` (same for debug and release)  
**Project type:** Flutter app (Android + iOS). Android build lives under `android/`.  
**Auth deep link:** `kegel://auth-callback`

This guide covers:

1. Building the APK (Flutter / Android Studio / CLI)
2. Setting up the Supabase database and sign-in
3. Setting up Firebase Analytics, Crashlytics and Performance
4. Checking that everything works

Related docs:

- `docs/product-spec.md` — product behaviour
- `docs/supabase-integration-plan.md` — sync / privacy design
- `supabase/README.md` — migration rules
- `docs/firebase-setup.md` — short Firebase placement note
- `docs/firebase-crashlytics-performance-plan.md` — what we measure

---

## 1) APK build steps

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) **stable** (Dart 3) on `PATH`, or a known SDK path (e.g. `E:\flutter`)
- Android Studio (or Android SDK + **JDK 17**)
- Git access to the repo
- A phone or emulator with USB debugging for install tests

Git LFS is **not** required. Videos and images are normal repo assets.

### Clone

```powershell
git clone <YOUR_REPO_URL> kegel-exercises-app
cd kegel-exercises-app
```

After cloning, confirm these exist:

- `pubspec.yaml`
- `android/` and `ios/`
- `assets/content/` (`levels.json`, `exercises.json`, `tracks.json`, `articles/`)
- `assets/videos/` (exercise demos)
- `supabase/migrations/` (schema + RPCs)

### Flutter packages

```powershell
flutter pub get
```

### `android/local.properties` (SDK path + cloud keys)

File path: `android/local.properties` (gitignored).

**About `sdk.dir` / `flutter.sdk`:**

- Android Studio / Flutter usually write these when you open the project.
- For CLI-only machines, create the file yourself.

Example:

```properties
sdk.dir=C:\\Users\\YOUR_USER\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\path\\to\\flutter
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY
GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
CLOUD_SYNC_ENABLED=true
```

| Key | Required | Where it comes from |
|-----|----------|---------------------|
| `sdk.dir` | Yes (Android builds) | Android SDK path |
| `flutter.sdk` | Yes (Flutter Gradle) | Flutter SDK path |
| `SUPABASE_URL` | Yes for sign-in / sync | Supabase Project Settings → API |
| `SUPABASE_ANON_KEY` | Yes for sign-in / sync | Supabase `anon` / publishable key |
| `GOOGLE_WEB_CLIENT_ID` | Yes for “Continue with Google” | **Web** OAuth client ID (section 2D). Not the Android client ID. |
| `CLOUD_SYNC_ENABLED` | No (default from secrets) | Set `false` to keep auth UI but disable sync |

Notes:

- Without Supabase keys the Flutter app still **builds**. Auth is skipped / blocked depending on config; local training still works when cloud is not configured.
- Never commit `android/local.properties`.
- Never put the Supabase **service_role** key in the app.

### Bake secrets into Dart (required for debug/dev without `--dart-define`)

The app reads cloud config from:

1. `--dart-define=SUPABASE_URL=…` (and related) if passed at build time, else  
2. `lib/core/cloud/cloud_secrets.dart` (gitignored), generated from `android/local.properties`.

After editing `android/local.properties`, regenerate secrets before building:

```powershell
# If the project script exists:
powershell -ExecutionPolicy Bypass -File tools\sync_cloud_secrets.ps1
```

If that script is missing, create / update `lib/core/cloud/cloud_secrets.dart` to match (same shape as today):

```dart
// GENERATED — do not commit.
abstract final class CloudSecrets {
  static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String supabaseAnonKey = 'YOUR_KEY';
  static const String googleWebClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  static const bool cloudSyncEnabled = true;
}
```

Or pass defines on every build:

```powershell
flutter build apk --debug `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY `
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com `
  --dart-define=CLOUD_SYNC_ENABLED=true
```

### Firebase config file

Put the Firebase Android config at:

`android/app/google-services.json`

The file must be created for package **`com.syarix.kegelexercisesapp`** (see section 3).  
If the file is missing, the APK still builds; Crashlytics / Performance / Analytics stay off (no-op). **Never commit this file.**

iOS (when you ship iOS): `ios/Runner/GoogleService-Info.plist` (also gitignored).

### Build from Android Studio (Flutter project)

1. Open Android Studio or VS Code / Cursor with the Flutter plugin.
2. Open the **repo root** (folder with `pubspec.yaml`), not only `android/`.
3. Wait for pub get / Gradle sync.
4. Select a device, then **Run** (debug), or use the Terminal commands below.

### Build debug APK (CLI)

```powershell
flutter pub get
flutter build apk --debug
```

APK output:

`build/app/outputs/flutter-apk/app-debug.apk`

(Also under `build/app/outputs/apk/debug/` after Gradle finishes.)

### Build release APK (CLI)

```powershell
flutter build apk --release --target-platform=android-arm64
```

APK output:

`build/app/outputs/flutter-apk/app-release.apk`

Release currently signs with the **debug** keystore in `android/app/build.gradle.kts` so local install works. For Play Store, create a real upload keystore (below).

R8 minify / resource shrink are **off** for local release builds (faster, more reliable on AGP 9). Turn them on again before store shipping if you want shrinking.

### Install on a phone

```powershell
adb devices
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

Or release:

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

Launch:

```powershell
adb shell am start -n com.syarix.kegelexercisesapp/.MainActivity
```

### Signed release for Play Store / testers

1. Create an upload keystore (keep it and passwords safe — every update must use the same key).
2. Add `android/key.properties` (gitignored) and wire `signingConfigs` in `android/app/build.gradle.kts` (same pattern as other Play apps).
3. Raise `version` / `versionCode` in `pubspec.yaml` before each store upload.
4. Build:

```powershell
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**SHA-1** (needed for Google sign-in):

Debug key:

```powershell
cd android
.\gradlew.bat :app:signingReport
```

Look for `Variant: debug` → `SHA1`.

Upload / Play App Signing key: print with `keytool -list -v -keystore …` or copy from Play Console → **Setup → App signing**.

---

## 2) Supabase setup

Migrations live in `supabase/migrations/`. Apply with the CLI only — do **not** paste production schema into the Dashboard SQL Editor.

| Order | File | What it creates |
|-------|------|-----------------|
| 1 | `20260324120000_kegel_core_schema.sql` | Tables `profiles`, `devices`, `user_preferences`, `sessions`, `habit_ticks`, `walking_logs`, `hold_tests`, `checkins`; triggers; indexes; RLS; profile row on signup |
| 2 | `20260324120100_kegel_sync_rpcs.sql` | Sync / wipe RPCs: `kegel_upsert_profile`, session/habit/walking/checkin/hold helpers, `kegel_reset_my_data`, `kegel_delete_my_account`, … |
| 3 | `20260325180000_goal_plans.sql` | Goal / plan related additions |

Use a **separate** Supabase project for this app (do not reuse PoseCoach or FocusFlow). Prefer a **test** project for development and a **production** project for store builds.

### A) Create the project

1. Open [https://supabase.com](https://supabase.com) and create a project (region closest to users).
2. **Project Settings → API** — copy:
   - **Project URL** → `SUPABASE_URL`
   - **`anon` / publishable key** → `SUPABASE_ANON_KEY`
   - Do **not** put the `service_role` key in the app.
3. Note the **project ref** (subdomain of `https://abcd1234.supabase.co`).

### B) Apply migrations (CLI)

1. Install the [Supabase CLI](https://supabase.com/docs/guides/cli).
2. From the repo root:

```powershell
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

Confirm:

```powershell
supabase migration list
```

Optional SQL checks (Dashboard → SQL Editor, read-only):

```sql
select proname from pg_proc where proname like 'kegel_%' order by proname;

select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'profiles','devices','user_preferences','sessions',
    'habit_ticks','walking_logs','hold_tests','checkins'
  );
```

**Later schema changes:** `supabase migration new <snake_case_name>` → edit → `supabase db push`. Never edit an already-applied migration.

### C) Auth redirect

In Supabase → **Authentication → URL Configuration**:

1. **Site URL:** your landing / privacy site (or a placeholder during test).
2. **Redirect URLs** — add exactly:

```text
kegel://auth-callback
```

This returns the user into the Android app after email confirm, password reset, or browser Google OAuth.

### C1) Email provider

**Authentication → Providers → Email:**

1. Enable **Email**.
2. Set **Confirm email** = **ON** for production-like testing.
3. Configure custom SMTP (Resend / SendGrid / etc.) so confirm / reset emails actually arrive.

Optional branded templates: paste files from `supabase/email_templates/` into **Authentication → Emails → Templates** (keep `{{ … }}` placeholders). See that folder’s README.

### D) Google sign-in (“Continue with Google”)

Two redirect URLs — do not mix them:

| Where | URL | Purpose |
|-------|-----|---------|
| Supabase → Redirect URLs | `kegel://auth-callback` | Back into the Android app |
| Google Cloud → Web OAuth client → Authorized redirect URIs | `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback` | Google → Supabase first |

#### Google Cloud

1. Create / select a Cloud project for this app only.
2. **OAuth consent screen:** app name, support email, logo, privacy policy; publish when ready.
3. **Credentials → OAuth client ID → Web application**
   - Authorized redirect URI:

     ```text
     https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback
     ```

   - Copy **Client ID** and **Client secret**.
4. **Credentials → OAuth client ID → Android**
   - Package: `com.syarix.kegelexercisesapp`
   - SHA-1 for each signing key you use (debug, upload, Play App Signing).

#### Supabase Google provider

**Authentication → Providers → Google:**

1. Enable Google.
2. Paste the **Web** client ID and **Web** client secret.
3. Leave skip-nonce **off** (the app sends a nonce).
4. Save.

#### App

Put the **Web** client ID in `android/local.properties` as `GOOGLE_WEB_CLIENT_ID`, regenerate `cloud_secrets.dart` (or pass `--dart-define`), then rebuild.

Checklist:

- [ ] Redirect URLs include `kegel://auth-callback`
- [ ] Web client redirect URI is the Supabase `/auth/v1/callback` URL
- [ ] Android OAuth clients exist for `com.syarix.kegelexercisesapp` + correct SHA-1s
- [ ] Supabase Google provider uses the **Web** client ID/secret
- [ ] `GOOGLE_WEB_CLIENT_ID` is the Web client ID
- [ ] Deep link `kegel://` is **not** added as a Google Cloud redirect URI

### E) Privacy (what never leaves the phone)

These must **never** go to Analytics, Crashlytics, Performance, or logs:

- Safety answers (`pain`, `painSexual`, `recentSurgery`, `catheter`)
- Session **feel** (`fine` / `mildDiscomfort` / `pain`)
- Email, display name, Supabase `user_id`, auth tokens

Check-in **scores** sync only to the user’s own Supabase rows under RLS for Progress restore — never to Analytics.

### F) Reset vs delete account

| Action in Settings | Local phone | Supabase account | Cloud app tables |
|--------------------|-------------|------------------|------------------|
| Reset / erase my data | Wipe plan + sessions + prefs | **Keep** | Cleared via `kegel_reset_my_data` |
| Delete account | Wipe + sign out | **Deleted** | Cleared via `kegel_delete_my_account` |
| Sign out | Keep local; flush sync if possible | Keep | Keep |

After wipe / delete, the anonymous Crashlytics `installation_id` is rotated.

---

## 3) Firebase Analytics + Crashlytics + Performance

Package name must be `com.syarix.kegelexercisesapp`. One Android app registration covers debug and release.

Unlike FocusFlow (Analytics off), **this app turns Google Analytics on** for Product Spec §14 events.

### A) Create the Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Create a **new** project for this app (do not reuse PoseCoach / FocusFlow).
3. **Google Analytics: On.**
4. **Add app → Android** → package `com.syarix.kegelexercisesapp`.
5. Download `google-services.json`.

### B) Place the file

```text
android/app/google-services.json
```

Do not commit it. Without it, builds still succeed; Firebase features no-op.

### C) Enable products

1. **Crashlytics** → Enable / Get started  
2. **Performance** → Get started  
3. Analytics is already available when you enabled Google Analytics for the project  

### D) Rebuild and verify

1. Rebuild and install (debug is fine for first checks).
2. Use the app: sign in, finish a short session, open an exercise video.
3. **Crashlytics:** after a forced debug crash (Data debug only) and relaunch, a report appears. New projects show “waiting for data” until the first report.
4. **Performance → Custom traces** (first data can take hours on a new project):

| Custom trace | What it measures |
|--------------|------------------|
| `app_hydrate` | Prefs + cloud bootstrap after Firebase init |
| `session_engine_build` | Building the session timeline |
| `session_play` | One play through (not per tick); metrics include elapsed / completed |
| `video_init` | Exercise video controller init (`ok` 0/1) |
| `sync_push` / `sync_pull` | Supabase sync batches |
| `account_action` | Reset data / delete account |

5. **Analytics DebugView** (optional): confirm only §14 events; never feel / safety / check-in scores.

**Privacy:** reports carry anonymous `installation_id`, app version, build type, and coarse labels (screen, level, track id). No clinical answers.

More detail: `docs/firebase-crashlytics-performance-plan.md`.

---

## 4) Check that everything works

Run on a phone built with sections 1–3.

| # | Step | Expected result |
|---|------|-----------------|
| 1 | Cold start with keys + `google-services.json` | App opens; no red-screen error |
| 2 | Create account (email + password) | “Check your email” if confirm is on; confirm link opens app via `kegel://auth-callback` |
| 3 | Finish onboarding O1–O6 | Plan saved; first session path available |
| 4 | Complete tutorial (if shown) + one strengthening session | S4 done; session row in Drift / syncs when signed in |
| 5 | Supabase → `profiles` | Row for user with `onboarding_done = true` |
| 6 | Supabase → `sessions` | Completed session present (`feel` not stored in cloud) |
| 7 | Sign out → sign in again | Plan / sessions restore; safety flags stay local |
| 8 | Continue with Google | Account picker (or browser fallback) completes |
| 9 | Settings → Reset all my data | Local wipe; cloud training data cleared; account remains |
| 10 | Settings → Delete account (type DELETE) | Auth user gone; local wipe |
| 11 | Data debug → test non-fatal (debug) | Event in Crashlytics after short wait / relaunch |
| 12 | Firebase Performance | Custom traces appear after use |
| 13 | Reminder on in Settings | Notification at chosen time (discreet by default) |

---

## 5) Common problems

| Symptom | Likely fix |
|---------|------------|
| Builds but auth says cloud not set up | Missing / empty secrets — check `local.properties` + regenerate `cloud_secrets.dart` or pass `--dart-define` |
| Google sign-in fails / cancels | Wrong SHA-1 on Android OAuth client; or Web client ID missing in app / Supabase |
| Email link doesn’t open app | Redirect URL must be exactly `kegel://auth-callback`; intent-filter already in `AndroidManifest.xml` |
| Firebase always “off” | Missing `android/app/google-services.json` for this package name |
| Release Gradle hangs on minify | Confirm `isMinifyEnabled = false` in `android/app/build.gradle.kts` for local builds |
| `Bad state: No element` on start | Fixed in diagnostics router binder — pull latest; ensure you are not on an old broken APK |

---

## 6) What not to commit

- `android/local.properties`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/core/cloud/cloud_secrets.dart`
- Keystores / `android/key.properties`
- `.env` files

---

End of setup guide. For product behaviour (screens, safety, free vs premium), see `docs/product-spec.md` and `docs/exports/Kegel_Exercises_Product_Technical_Documentation.docx`.
