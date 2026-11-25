# Kegel Exercises App × Supabase: implementation plan

This plan adds **required accounts** (Sign In / Create Account, plus **Continue with Google**) and cloud sync to the Flutter Kegel app. Sync follows the same offline-first approach as PoseCoach (`E:\pose_correction\supabase\supabase_scaling.md`) and FocusFlow (`E:\Screen-time_android_app\docs\supabase-integration-plan.md`):

- The phone stays the source of truth.
- Changes are tracked locally (dirty flags / tombstones).
- A background job uploads only what changed, in batches, and downloads only what changed.
- **Reset data** erases cloud + local training data but **keeps the account**.
- **Delete account** erases **account + all cloud data** (and wipes the phone).

Work through the phases in order. Each phase should build and run on its own so it can ship in separate commits.

**Reference patterns to copy (concepts, not literal Android code):**

| Source | What to reuse |
|--------|----------------|
| PoseCoach `supabase_scaling.md` | Offline-first delta sync, dirty flags, tombstones, flush-before-sign-out, pause sync during active sessions, 15‑minute resume gate, WorkManager-style background sync, RLS + `(select auth.uid())`, CLI-only migrations |
| FocusFlow `supabase-integration-plan.md` | Required auth gate, Sign In / Create Account tabs, Google via Credential Manager + browser fallback, `reset_my_data` vs `delete_my_account` RPCs, Account binder restore/merge/replace, privacy split (what never leaves the phone), test vs production handoff |

---

## 0. Ground rules (read first)

1. **An account is required, but the network is not (after first sign-in).**
   - Users must Sign In, Create Account, or Continue with Google once, **before** onboarding.
   - After that the app works fully offline: plan, sessions, habits, reminders, and the player never wait on the network. The saved session keeps the user signed in.
   - The cloud is sync and backup.
2. **Privacy hard rules (product + clinical).** These must never go to Supabase, analytics, or logs:
   - Safety answers (`pain`, `painSexual`, `recentSurgery`, `catheter`)
   - Session **feel** (`fine` / `mildDiscomfort` / `pain`)
   - Anything that would identify sexual function beyond the user’s chosen **goal** label already stored for plan routing
   - **Check-ins (date, goal, score) do sync** to the user’s own account under RLS so Progress history survives reinstall. They must **never** go to analytics or third parties.
3. **Local saves never upload directly.** They mark rows “needs upload”. A `SyncCoordinator` decides when to push.
4. **Last write wins by the client’s `updated_at_millis`, enforced on the server.** An older write never overwrites a newer row.
5. **“Changed since” downloads use the server’s `updated_at`**, never the phone’s clock.
6. **Schema changes go only through the Supabase CLI** (`supabase db push`) and timestamped files in `supabase/migrations/`. Never paste SQL into the dashboard for production schema, and never edit a migration that has already been applied.
7. **No secrets in git.** URL and anon key come from local/CI config (e.g. `--dart-define` or a non-committed env file). The **service role key never goes in the app**.
8. **Do not sync on hot paths.** Session player ticks, haptics, and countdown frames only update memory/local DB. Sync runs after the session ends, on background, or on a schedule.

---

## 1. What we store today, and what goes to the cloud

Today everything is on-device: Drift SQLite (`kegel_exercises.sqlite`) + SharedPreferences (`user_profile_v1`, hold tests, reminder helpers). There is **no account**.

| Data | Today | Cloud? | Why |
|------|-------|--------|-----|
| Plan / profile: goal, experience, sessions/day, track, level, levelStartedOn, planStartedOn, restWeekday | `UserProfile` prefs | **Yes** → `profiles` + plan fields | Survive reinstall; continue the plan on a new phone |
| Onboarding / tutorial / paywall / unlock snooze flags | prefs | **Yes** → `profiles` | Skip completed steps after restore |
| Reminder enabled, time, days, discreet / voice / vibration | prefs | **Yes** → `user_preferences.prefs` | Preferences follow the account; **OS notification schedules stay local** |
| Safety flags | prefs | **No** | Clinical privacy; re-ask or keep local-only after restore |
| Completed sessions (level, day, track, kind, duration, longest hold, completed) | Drift `sessions` | **Yes** → `sessions` | Streak, unlock, progress history |
| Session `feel` | Drift `sessions.feel` | **No** | Privacy; strip before upload or store null in cloud |
| Habit ticks | Drift `habit_ticks` | **Yes** → `habit_ticks` | Continuity of daily habits |
| Walking minutes | Drift `walking_logs` | **Yes** → `walking_logs` | Progress / goal continuity |
| Hold-test results + “guide seen” | prefs | **Yes** → `hold_tests` + profile/prefs flag | Strength history and guide gate |
| Check-in rows (date, goal, score 1–5) | Drift `checkins` | **Yes** → `checkins` | Progress history; user’s own backup under RLS only — never analytics |
| Reminder timezone / level-unlock notice dedupe | prefs | **No** | Device-only scheduling helpers |
| Bundled content (JSON/articles) | assets | **No** | Not user data |
| Premium / RevenueCat | stub today | **Out of scope for this plan** | Keep billing separate; link by `user_id` later if needed |

---

## 2. Product decisions (locked for this plan)

1. **Separate Supabase projects for this app** (nothing shared with PoseCoach or FocusFlow):
   - **Test project:** developer-owned; all building and testing here first.
   - **Production project:** manager-owned; developer never applies schema directly. Handoff = migration files + checklist (section 9).
2. **Sign-in is required**, with a dedicated auth flow **before** onboarding:
   - **Sign In** (email + password) — separate tab/mode
   - **Create Account** (email + password + name + age/terms) — separate tab/mode
   - **Continue with Google** — separate primary button on both tabs
   - Email confirmation + forgot password
   - **No Apple, no X/Twitter, no anonymous guests** in v1
3. **One account across methods.** Google and email with the same verified email link to one Supabase user.
4. **Rules for wipe actions (match FocusFlow / PoseCoach intent):**

   | User action | Local phone | Supabase account (`auth.users`) | Supabase app tables |
   |-------------|-------------|----------------------------------|---------------------|
   | **Reset / Delete all my data** | Full wipe of plan, sessions, habits, walking, hold tests, check-ins, prefs (same as today’s `DataResetService`) → back to Welcome/onboarding | **Keep** | **Delete user data** via `kegel_reset_my_data()`; profile row kept with onboarding flags cleared |
   | **Delete account** | Full wipe + clear session | **Delete** | **Cascade delete** via `kegel_delete_my_account()` → `delete from auth.users` |
   | **Sign out** | Keep local data; cancel pending workers after flush attempt | Keep | Keep (synced). Navigate to Auth |

5. **Stable device id (Flutter):** a hashed installation id (e.g. from `flutter_secure_storage` / Android `ANDROID_ID` / iOS identifierForVendor equivalent), truncated hex. Used only to tell phones apart for sync/heartbeat — **not** for advertising. **Do not store phone model, OS version, or other device fingerprinting.**
6. **Plan and progress are per account.** Two phones on one account share plan state, sessions, habits, walking, hold tests, and check-ins (newest `updated_at_millis` wins). Safety flags and session feel never sync.

---

## Phase 1: Supabase project and schema

### 1.1 Repo setup

Add a **`supabase/`** folder at the Kegel repo root (same conventions as PoseCoach):

- **`README.md`:** additive-only migrations; RLS on every table; `(select auth.uid())` in policies; never edit an applied migration.
- **`config.toml`:**
  - `project_id = "kegel-exercises"`
  - Auth redirect: `kegel://auth-callback`
  - `enable_confirmations = true`
- **`email_templates/`:** confirm signup, reset password, change email (branded for this app).
- **`migrations/`:** the two files below.

**Dashboard (test project first):**

- **Authentication → Providers**
  - **Email** on: confirm email on, min password 8, leaked-password protection if available.
  - **Google** on.
  - All other providers **off**.
- **URL configuration:** Site URL + redirect `kegel://auth-callback`.
- **Google Cloud Console** (this app’s OAuth project only):
  - **Web** client → ID/secret into Supabase Google provider; Web client ID also into the Flutter app as `GOOGLE_WEB_CLIENT_ID`.
  - **Android** clients for the app package + debug/release/Play signing SHA-1s.
  - Consent screen: app name, logo, privacy policy, support email.
- **Emails:** branded templates + custom SMTP before launch.
- Link CLI to **test** only: `supabase link --project-ref <test-ref>` then `supabase db push`.

### 1.2 Migration 1 — core schema

`supabase/migrations/YYYYMMDDHHMMSS_kegel_core_schema.sql`

```sql
-- Kegel core schema: profiles, devices, preferences, sessions, habits, walking, hold tests, checkins.
-- Additive. RLS: users only touch their own rows.
-- devices: minimal only (no model / OS / personal device fingerprint).
-- Dual timestamps on synced rows:
--   updated_at_millis (client) -> last-write-wins
--   updated_at        (server trigger) -> "changed since" pulls

create or replace function public.kegel_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- 1. Profiles (plan + flow flags; NO safety flags)
create table if not exists public.profiles (
  user_id              uuid primary key references auth.users (id) on delete cascade,
  display_name         text,
  goal                 text,          -- enum string
  experience           text,          -- none | unsure | confident
  sessions_per_day     int check (sessions_per_day between 1 and 3),
  track                text,
  level                int not null default 1 check (level >= 1),
  level_started_on     date,
  plan_started_on      date,
  rest_weekday         int check (rest_weekday between 1 and 7),
  onboarding_done      boolean not null default false,
  tutorial_done        boolean not null default false,
  paywall_seen         boolean not null default false,
  level_unlock_snoozed boolean not null default false,
  guide_seen_at        timestamptz,   -- hold-test / muscle guide finished
  time_zone            text,
  updated_at_millis    bigint not null default 0,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- 2. Devices (minimal — only what sync needs; no model / OS / personal info)
create table if not exists public.devices (
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  device_id    text not null check (char_length(device_id) between 8 and 64), -- hashed install id
  app_version  text,              -- optional: debug support only, not required for sync
  last_seen_at timestamptz not null default now(),
  created_at   timestamptz not null default now(),
  primary key (user_id, device_id)
);

-- 3. Preferences (reminder + UX toggles; field-level newest-wins JSON)
-- Shape example:
-- {
--   "reminderEnabled": {"value": true, "at": 1730000000000},
--   "reminderTime": {"value": 1260, "at": ...},
--   "reminderDays": {"value": [1,2,3,4,5,6,7], "at": ...},
--   "discreetNotifications": {"value": true, "at": ...},
--   "voiceOn": {"value": false, "at": ...},
--   "vibrationOn": {"value": true, "at": ...}
-- }
create table if not exists public.user_preferences (
  user_id           uuid primary key references auth.users (id) on delete cascade,
  prefs             jsonb not null default '{}'::jsonb,
  updated_at_millis bigint not null default 0,
  updated_at        timestamptz not null default now()
);

-- 4. Sessions (no feel column in cloud)
create table if not exists public.sessions (
  user_id              uuid not null default auth.uid() references auth.users (id) on delete cascade,
  sync_id              uuid not null,              -- permanent id created on phone
  started_at           timestamptz not null,
  completed_at         timestamptz,
  level                int not null,
  day_in_level         int not null,
  track                text not null,
  kind                 text not null check (kind in ('strengthening','body','breathing','relaxation')),
  duration_seconds     int not null default 0 check (duration_seconds >= 0),
  longest_hold_seconds int not null default 0 check (longest_hold_seconds >= 0),
  completed            boolean not null default false,
  updated_at_millis    bigint not null,
  is_deleted           boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  primary key (user_id, sync_id)
);

-- 5. Habit ticks
create table if not exists public.habit_ticks (
  user_id           uuid not null default auth.uid() references auth.users (id) on delete cascade,
  sync_id           uuid not null,
  day               date not null,
  habit_id          text not null,
  updated_at_millis bigint not null,
  is_deleted        boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  primary key (user_id, sync_id),
  unique (user_id, day, habit_id)
);

-- 6. Walking logs
create table if not exists public.walking_logs (
  user_id           uuid not null default auth.uid() references auth.users (id) on delete cascade,
  sync_id           uuid not null,
  day               date not null,
  minutes           int not null default 0 check (minutes >= 0),
  updated_at_millis bigint not null,
  is_deleted        boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  primary key (user_id, sync_id),
  unique (user_id, day)
);

-- 7. Hold tests (append-friendly strength history; no device_id needed)
create table if not exists public.hold_tests (
  user_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  sync_id        uuid not null,
  held_at        timestamptz not null,
  seconds        int not null check (seconds >= 0),
  created_at     timestamptz not null default now(),
  primary key (user_id, sync_id)
);

-- 8. Check-ins (G2 history — user's own backup under RLS; never analytics)
create table if not exists public.checkins (
  user_id           uuid not null default auth.uid() references auth.users (id) on delete cascade,
  sync_id           uuid not null,
  day               date not null,
  goal              text not null,
  score             smallint not null check (score between 1 and 5),
  updated_at_millis bigint not null,
  is_deleted        boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  primary key (user_id, sync_id),
  unique (user_id, day)
);

-- updated_at triggers
drop trigger if exists profiles_touch on public.profiles;
create trigger profiles_touch before update on public.profiles
  for each row execute function public.kegel_touch_updated_at();
drop trigger if exists user_preferences_touch on public.user_preferences;
create trigger user_preferences_touch before update on public.user_preferences
  for each row execute function public.kegel_touch_updated_at();
drop trigger if exists sessions_touch on public.sessions;
create trigger sessions_touch before update on public.sessions
  for each row execute function public.kegel_touch_updated_at();
drop trigger if exists habit_ticks_touch on public.habit_ticks;
create trigger habit_ticks_touch before update on public.habit_ticks
  for each row execute function public.kegel_touch_updated_at();
drop trigger if exists walking_logs_touch on public.walking_logs;
create trigger walking_logs_touch before update on public.walking_logs
  for each row execute function public.kegel_touch_updated_at();
drop trigger if exists checkins_touch on public.checkins;
create trigger checkins_touch before update on public.checkins
  for each row execute function public.kegel_touch_updated_at();

-- Indexes
create index if not exists sessions_user_updated_idx on public.sessions (user_id, updated_at);
create index if not exists sessions_user_started_idx on public.sessions (user_id, started_at desc);
create index if not exists habit_ticks_user_day_idx on public.habit_ticks (user_id, day);
create index if not exists walking_logs_user_day_idx on public.walking_logs (user_id, day);
create index if not exists hold_tests_user_held_idx on public.hold_tests (user_id, held_at desc);
create index if not exists checkins_user_day_idx on public.checkins (user_id, day);
create index if not exists checkins_user_updated_idx on public.checkins (user_id, updated_at);

-- RLS
alter table public.profiles enable row level security;
alter table public.devices enable row level security;
alter table public.user_preferences enable row level security;
alter table public.sessions enable row level security;
alter table public.habit_ticks enable row level security;
alter table public.walking_logs enable row level security;
alter table public.hold_tests enable row level security;
alter table public.checkins enable row level security;

-- Standard select/insert/update own for mutable tables; hold_tests select+insert only
-- (implement with (select auth.uid()) = user_id like FocusFlow)

grant select, insert, update on public.profiles, public.devices, public.user_preferences,
  public.sessions, public.habit_ticks, public.walking_logs, public.checkins to authenticated;
grant select, insert on public.hold_tests to authenticated;
revoke all on public.profiles, public.devices, public.user_preferences, public.sessions,
  public.habit_ticks, public.walking_logs, public.hold_tests, public.checkins from anon;

-- Profile row on signup
create or replace function public.kegel_handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (user_id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'full_name'))
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists kegel_on_auth_user_created on auth.users;
create trigger kegel_on_auth_user_created
  after insert on auth.users
  for each row execute function public.kegel_handle_new_user();
```

### 1.3 Migration 2 — sync RPCs + reset / delete account

`supabase/migrations/YYYYMMDDHHMMSS_kegel_sync_functions.sql`

Implement (FocusFlow-style, security invoker where possible):

| Function | Role |
|----------|------|
| `kegel_upsert_profile(jsonb)` | Upsert plan/flags; `onboarding_done` / `tutorial_done` only turn **on**; level uses last-write-wins by `updated_at_millis` |
| `kegel_upsert_sessions(jsonb)` | Batch upsert by `(user_id, sync_id)`; LWW; supports `is_deleted` tombstones |
| `kegel_upsert_habit_ticks(jsonb)` | Batch upsert; LWW + tombstones |
| `kegel_upsert_walking_logs(jsonb)` | Batch upsert; LWW + tombstones |
| `kegel_upsert_checkins(jsonb)` | Batch upsert by `(user_id, sync_id)` / unique day; LWW + tombstones |
| `kegel_insert_hold_tests(jsonb)` | Insert batch; `on conflict do nothing` (safe retry) |
| `kegel_reset_my_data()` | **security definer.** Deletes sessions, habit_ticks, walking_logs, hold_tests, checkins, user_preferences, devices for `auth.uid()`. Resets profile plan/flags to empty/false defaults. **Does not delete `auth.users`.** |
| `kegel_delete_my_account()` | **security definer.** `delete from auth.users where id = auth.uid()` — cascades all app tables. |

Grant `execute` to `authenticated` only. `notify pgrst, 'reload schema'`.

**Post-push checks:**

```sql
select proname from pg_proc where proname like 'kegel_%';
select tablename, rowsecurity from pg_tables where schemaname = 'public';
```

---

## Phase 2: Flutter dependencies and config

1. **Packages (ask before adding if the repo rule requires it; list for the plan):**
   - `supabase_flutter` (auth + postgrest)
   - `google_sign_in` and/or Credential Manager path for Android ID token → Supabase
   - `workmanager` or `android_alarm_manager_plus` / background sync equivalent for Flutter
   - `connectivity_plus` for offline auth banner
   - Secure storage for session if not fully handled by `supabase_flutter`
2. **Config via `--dart-define` or local untracked file:**
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_WEB_CLIENT_ID`, `CLOUD_SYNC_ENABLED`
   - Blank config → Auth screen shows “Sign-in isn’t set up in this build” (dev only)
3. **Deep link:** `kegel://auth-callback` for email confirm + password reset + Google browser fallback.
4. **Android / iOS:** INTERNET; intent filters / URL schemes for the callback.

---

## Phase 3: Local change tracking (Drift + prefs)

Extend local persistence so every cloud-bound row can sync (PoseCoach pattern):

### 3.1 Drift changes

On `sessions`, `habit_ticks`, `walking_logs` (and a new local `hold_tests` table if still prefs-only):

- `syncId` (UUID, permanent)
- `updatedAtMillis`
- `syncDirty`
- `isDeleted` (tombstone where deletes must propagate)

**DAO rule:** clear dirty only if `updatedAtMillis` still equals the value that was sent (`markSynced(id, sentAt)`), so an edit during upload is not lost.

### 3.2 Profile / preferences

- Keep `UserProfile` as the UI source of truth.
- Add `profileSyncDirty` / preference field timestamps (or a small `SyncMetadata` store).
- **Never** put `safetyFlags` into the cloud profile payload.

### 3.3 One-time backfill

On first launch of the sync-capable build:

1. Assign `syncId` to existing session/habit/walking/hold rows.
2. Mark them dirty.
3. Set `room_imported` / `sync_backfill_done` flag so it runs once.

### 3.4 Repository hooks

| Local write | Sync mark |
|-------------|-----------|
| Session completed | dirty session (without `feel`) |
| Habit tick / untick | dirty tick or tombstone |
| Walking minutes | dirty log |
| Hold test saved | dirty hold test |
| Check-in saved (date, goal, score) | dirty check-in |
| Plan / onboarding fields | dirty profile |
| Reminder / voice / vibration | dirty preferences |
| Safety toggle | **local only** |

After marking dirty → `syncCoordinator.notifyLocalChange()` (debounced).

### 3.5 Align wipe helpers with cloud

Update `DataResetService` / Settings:

- **Reset data:** if signed in → confirm “Also erase your cloud backup?” → call `kegel_reset_my_data()` → then existing local wipe → Auth? **No** — stay signed in, go to Welcome/onboarding (account kept). Re-schedule nothing until plan rebuilt.
- **Delete account:** two-step confirm → `kegel_delete_my_account()` → full local wipe including sync metadata + session → Auth.
- Ensure reminder helper prefs are cleared on both paths (fix today’s wipe gap).

---

## Phase 4: Auth UI and gate (Sign In / Sign Up / Google separately)

### 4.1 Splash routing (before onboarding)

```
Splash
  └─ restoreSession()
      ├─ no session ─────────────────────────────▶ Auth (mode: signin | signup)
      └─ session ok ─▶ onboardingDone? ─ no ───▶ O1 Welcome …
                                      └ yes ──▶ Main (Today)
Auth success ─▶ AccountBinder.onSignedIn() ─▶ restore/merge ─▶ onboarding or Main
```

- Auth uses `popUpTo` root so Back leaves the app (or exits).
- Back from O1 Welcome can return to Auth.
- Offline with **saved** session: stay signed in; never bounce to Auth only because the network is down.
- Offline with **no** session: Auth shows “You’re offline…” and disables submit until connected.

### 4.2 Auth screens (Flutter, existing design tokens)

**One route, two modes/tabs (separate UX as requested):**

1. **Hero** (calm clinical copy): Sign In = “Welcome back.” / Create Account = “Let’s get you set up.”
2. **Segmented control:** Sign in | Create account (switching keeps email).
3. **Continue with Google** — full-width, **separate** from email (same button on both tabs).
4. Divider: “or use email”.
5. **Create account only:** Name; Terms/Privacy checkbox (button disabled until ticked); optional “I am 18 or older” if not already only on O1 — product may keep age gate on O1 after auth; do not duplicate poorly. Prefer: account create collects name + terms; O1 still collects 18+.
6. **Email + password** (show/hide); Create account shows “8+ characters”.
7. **Primary:** “Sign in” or “Create account”.
8. **Sign in only:** “Forgot password?” → neutral “If an account exists…”.
9. Friendly errors (FocusFlow table): wrong password, confirm email + Resend, email already registered → switch to Sign in, offline, rate limit.

**Google (separate implementation path):**

1. Prefer native Google ID token → `signInWithIdToken(provider: Google)`.
2. Fallback: browser OAuth + `kegel://auth-callback`.
3. Cancel → stay on Auth, no error toast.
4. If email user retries password on a Google-only account → “This email uses Google sign-in. Tap Continue with Google.”

**Check inbox** after email sign-up; **Reset password** screen from recovery deep link.

### 4.3 AccountBinder after sign-in

| Situation | Behaviour |
|-----------|-----------|
| New install, empty cloud | Continue to onboarding; uploads as they progress |
| New install / reinstall, cloud has data | Restore profile, prefs, sessions, habits, walking, hold tests, check-ins. Skip completed onboarding if `onboarding_done`. **Re-collect or keep local-only safety** (never restore safety from cloud — there is none). Reminder OS schedules rebuilt from prefs |
| Existing local data, first-time account, empty cloud | Mark all dirty and upload; go Main if already onboarded |
| Local + cloud both have data | Merge by `sync_id` / keys, LWW |
| Different `lastAuthUserId` | “This phone has another account’s data. Replace with *email*’s?” Replace = wipe synced local tables then restore; Cancel = sign out |

Show a short “Getting your account ready…” loader with a 10 s timeout → continue with local + background sync.

### 4.4 Settings → Account

New first group:

- Name, email, method chip (Google / Email)
- Sync status: “Backed up …”, “N changes waiting”, last error (safe text)
- **Back up now**
- **Change password** (email accounts)
- **Sign out** (flush pending first; warn if N unsynced)
- **Reset all my data** (account kept; cloud + local data wiped)
- **Delete account** (red; type DELETE / hold confirm → cloud account + data + local wipe → Auth)

Privacy copy: what is backed up (including check-ins to the user’s account only) vs what never leaves the phone (safety answers, session feel). No phone model or OS version is collected.

---

## Phase 5: Sync engine

### 5.1 SyncRepository

Under one mutex; verify `expectedUserId` before applying pulls.

**`pushAll()` order:**

1. Snapshot any pending local session completion.
2. Dirty profile → `kegel_upsert_profile`
3. Dirty preferences → upsert `user_preferences`
4. Dirty sessions (strip `feel`) → `kegel_upsert_sessions`
5. Dirty habit ticks → `kegel_upsert_habit_ticks`
6. Dirty walking → `kegel_upsert_walking_logs`
7. Dirty check-ins → `kegel_upsert_checkins`
8. Dirty hold tests → `kegel_insert_hold_tests`
9. Device heartbeat at most once/day — upsert **only** `(user_id, device_id, app_version?, last_seen_at)`. Never send model, manufacturer, or OS version.

Failures leave rows dirty + store friendly `lastError`.

**`pullAll()`:**

1. Profile (flags only turn on where specified; LWW for plan fields)
2. Preferences (field-level merge)
3. Sessions / habits / walking / check-ins with `updated_at > cursor` (5 s overlap)
4. Hold tests: paged by `held_at` if needed
5. Apply tombstones locally

`syncAll()` = pull then push; save last sync time.

### 5.2 SyncCoordinator triggers

| Trigger | Action |
|---------|--------|
| Local change | Debounced push (~1.5 s) |
| App resume | Full sync only if last sync older than **15 minutes** |
| App background | Push if pending |
| Session / hold-test / tutorial **active** | **Pause uploads**; flush once when finished (PoseCoach workout pause) |
| “Back up now” | Immediate pull + push |
| Periodic (e.g. 6 h) | Full sync when online |
| Signed out / not configured | No network; keep dirty marks for later |

### 5.3 Sign-out / reset / delete (exact behaviour)

**Sign out**

1. Confirm.
2. `flushBeforeSignOut` (timeout ~20 s).
3. If pending remain → “N changes haven’t backed up. Sign out anyway?”
4. Cancel workers; clear session; keep `lastAuthUserId`.
5. Navigate to Auth.
6. **Keep local training data** on the phone (user can still see history offline until they reset or switch accounts). Reminder schedules can keep running from local prefs.

**Reset / Delete all my data** (Settings — extends today’s wipe)

1. Confirm: removes plan, sessions, habits, walking, hold tests, check-ins from this phone.
2. If signed in: “Also erase your cloud backup?” → **Yes required for signed-in users** (or single confirm that covers both).
3. Call `kegel_reset_my_data()`.
4. Local `DataResetService.deleteEverything()` including check-ins (+ clear sync metadata tables, cancel reminders).
5. **Stay signed in**; go to Welcome / onboarding.
6. Account email/Google login still works.

**Delete account**

1. Two-step confirm (type DELETE or hold).
2. Call `kegel_delete_my_account()`.
3. Full local wipe (data + sync metadata + session).
4. Navigate to Auth (required to use the app again).
5. Publish a simple web deletion request page for store compliance.

---

## Phase 6: Privacy, store listing, logging

- Play / store data safety: name, email, app activity (plan/progress), app info (version, hashed device id). Encryption in transit. In-app deletion.
- Privacy policy: section 1 tables; explicitly list what never leaves the phone.
- Logging: never log tokens, emails, safety flags, check-in scores, feel values, or device model. Use safe error messages only.

---

## Phase 7: Tests and rollout

**Unit / widget**

- Backfill assigns sync ids once.
- Session upload payload omits `feel`.
- Profile upload omits safety flags.
- Check-in write marks cloud dirty; payload includes date, goal, score; never sent to analytics.
- LWW merge + tombstone apply.
- `markSynced` does not clear a row edited during upload.
- Auth form validation (signin vs signup separately); Google cancel; friendly errors.
- Splash: no session → Auth; session + onboarded → Main; offline with session stays Main.
- Reset RPC path keeps session; delete account clears session.

**Manual QA (high signal)**

| Case | Expected |
|------|----------|
| Fresh install | Splash → Auth; onboarding blocked until signed in |
| Create account | Check inbox → confirm → onboarding |
| Sign in (email) | Restores or continues correctly |
| Continue with Google | Native or browser; lands onboarding/Main |
| Offline after sign-in | Full app works; syncs when online |
| Finish a session offline | Appears in cloud after reconnect (no `feel`) |
| Reset data while signed in | Cloud tables empty for user; auth user remains; local wiped; still signed in → Welcome |
| Delete account | `auth.users` gone; all rows gone; local wiped; Auth |
| Sign out with pending | Warning count; then Auth |
| Different account on phone | Replace prompt; no mixed histories |
| During S3 player | No sync traffic; one push after done |

**Rollout**

1. Developer: migrations on **test** + full QA.
2. Handoff checklist to manager for **production** (section 9).
3. Release build uses production URL/anon key.
4. `CLOUD_SYNC_ENABLED` kill switch for emergency builds.

---

## 8. Files to add or change (checklist)

**New**

- `supabase/README.md`, `config.toml`, `email_templates/*`, `migrations/*`
- `docs/supabase-handoffs/` (dated handoff notes)
- `lib/core/cloud/` — client, auth repo, errors, sync metadata, preferences merge, sync repository, coordinator, background worker, account binder, device id
- `lib/features/auth/` — sign-in screen, sign-up mode, Google button, check-email, reset-password
- `lib/features/settings/` — account section / screen
- Tests listed in Phase 7

**Changed**

- `pubspec.yaml` (+ permissions / deep links)
- Drift schema + generated code (sync columns)
- Repositories: dirty marks; strip private fields on upload
- `DataResetService` + `x1_settings_screen.dart` — reset vs delete account vs sign out
- Router / splash — auth gate before onboarding
- Reminder service — rebuild schedules after preference restore; clear helper keys on wipe

---

## 9. Production handoff (developer → manager)

Same rules as FocusFlow:

1. Test everything on the **test** project first.
2. Send migration files **in order**, backup instruction, `supabase db push`, SQL checks, dashboard auth/Google/SMTP checklist.
3. Manager returns production URL + anon key only (never service role).
4. Developer never runs CLI against production.
5. Additive migrations only; apply DB **before** shipping the app build that requires the new RPCs.

**Handoff message template**

```
Kegel Exercises — production database update (date)

Tested on: test project, app build <version>, QA cases passed.

Please apply:
1. Backup production.
2. supabase db push  (new files: <list in order>)
3. Checks: kegel_% functions present; RLS true on all public tables.
4. Dashboard: Email + Google on; other providers off; redirect kegel://auth-callback; SMTP + templates.

Safe before app update: yes if additive only.
```

---

## 10. Mapping to the two reference docs

| Concept | PoseCoach scaling doc | FocusFlow plan | This app |
|---------|----------------------|----------------|----------|
| Phone is source of truth | Yes | Yes | Yes |
| Dirty flags + tombstones | Yes | Yes | Yes |
| Delta upsert RPCs | `posecoach_sync_*` | `focusflow_upsert_*` | `kegel_upsert_*` / insert hold tests |
| Pause sync during intense activity | During workout | During pose camera | During session player / hold test / tutorial practice |
| Safe sign-out flush | Yes | Yes | Yes |
| Preferences JSON LWW | `user_preferences` | Same | Same (reminders + UX toggles) |
| Required auth before main flow | (PoseCoach has accounts) | Yes, before onboarding | Yes, before onboarding |
| Google + email separately | Social + email | Explicit Google button + tabs | Explicit Google + Sign In tab + Create Account tab |
| Reset data, keep account | (prefs/challenge clear patterns) | `focusflow_reset_my_data` | `kegel_reset_my_data` |
| Delete account + cascade | — | `focusflow_delete_my_account` | `kegel_delete_my_account` |
| Privacy exclusions | Camera never uploaded | Screen-time details / camera; no phone model | Safety flags, session feel; no device model/OS; check-ins only in user’s own DB |

---

## Done when

- New users must Sign In, Create Account, or Continue with Google before onboarding.
- Once signed in, the app works offline as today.
- Cloud stores plan, sessions (without feel), habits, walking, hold tests, check-ins, and non-sensitive preferences.
- `devices` stores only hashed device id (+ optional app version / last seen) — no model or OS.
- Safety answers and session feel never leave the phone. Check-ins sync only to the user’s own account (not analytics).
- **Reset** clears local + cloud **data** but keeps the Supabase account.
- **Delete account** removes the auth user and all cloud rows, and wipes the phone.
- Sync does not run on player tick hot paths; pending uploads flush after sessions.
- Test project verified; production applied only via manager handoff.
