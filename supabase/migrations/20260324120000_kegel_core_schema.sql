-- Kegel core schema: profiles, devices, preferences, sessions, habits, walking, hold tests, checkins.
-- Additive. RLS: users only touch their own rows.
-- devices: minimal only (no model / OS / personal device fingerprint).
-- Dual timestamps on synced rows:
--   updated_at_millis (client) -> last-write-wins
--   updated_at        (server trigger) -> "changed since" pulls

create or replace function public.kegel_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- 1. Profiles (plan + flow flags; NO safety flags)
create table if not exists public.profiles (
  user_id              uuid primary key references auth.users (id) on delete cascade,
  display_name         text,
  goal                 text,
  experience           text,
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
  guide_seen_at        timestamptz,
  time_zone            text,
  updated_at_millis    bigint not null default 0,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- 2. Devices (minimal — only what sync needs; no model / OS / personal info)
create table if not exists public.devices (
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  device_id    text not null check (char_length(device_id) between 8 and 64),
  app_version  text,
  last_seen_at timestamptz not null default now(),
  created_at   timestamptz not null default now(),
  primary key (user_id, device_id)
);

-- 3. Preferences (reminder + UX toggles; field-level newest-wins JSON)
create table if not exists public.user_preferences (
  user_id           uuid primary key references auth.users (id) on delete cascade,
  prefs             jsonb not null default '{}'::jsonb,
  updated_at_millis bigint not null default 0,
  updated_at        timestamptz not null default now()
);

-- 4. Sessions (no feel column in cloud)
create table if not exists public.sessions (
  user_id              uuid not null default auth.uid() references auth.users (id) on delete cascade,
  sync_id              uuid not null,
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

-- 7. Hold tests
create table if not exists public.hold_tests (
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  sync_id    uuid not null,
  held_at    timestamptz not null,
  seconds    int not null check (seconds >= 0),
  created_at timestamptz not null default now(),
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
create index if not exists habit_ticks_user_updated_idx on public.habit_ticks (user_id, updated_at);
create index if not exists walking_logs_user_day_idx on public.walking_logs (user_id, day);
create index if not exists walking_logs_user_updated_idx on public.walking_logs (user_id, updated_at);
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

-- Policies (select auth.uid())
create policy "profiles_select_own" on public.profiles for select
  using ((select auth.uid()) = user_id);
create policy "profiles_insert_own" on public.profiles for insert
  with check ((select auth.uid()) = user_id);
create policy "profiles_update_own" on public.profiles for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "devices_select_own" on public.devices for select
  using ((select auth.uid()) = user_id);
create policy "devices_insert_own" on public.devices for insert
  with check ((select auth.uid()) = user_id);
create policy "devices_update_own" on public.devices for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "devices_delete_own" on public.devices for delete
  using ((select auth.uid()) = user_id);

create policy "prefs_select_own" on public.user_preferences for select
  using ((select auth.uid()) = user_id);
create policy "prefs_insert_own" on public.user_preferences for insert
  with check ((select auth.uid()) = user_id);
create policy "prefs_update_own" on public.user_preferences for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "sessions_select_own" on public.sessions for select
  using ((select auth.uid()) = user_id);
create policy "sessions_insert_own" on public.sessions for insert
  with check ((select auth.uid()) = user_id);
create policy "sessions_update_own" on public.sessions for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "habit_ticks_select_own" on public.habit_ticks for select
  using ((select auth.uid()) = user_id);
create policy "habit_ticks_insert_own" on public.habit_ticks for insert
  with check ((select auth.uid()) = user_id);
create policy "habit_ticks_update_own" on public.habit_ticks for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "walking_logs_select_own" on public.walking_logs for select
  using ((select auth.uid()) = user_id);
create policy "walking_logs_insert_own" on public.walking_logs for insert
  with check ((select auth.uid()) = user_id);
create policy "walking_logs_update_own" on public.walking_logs for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "hold_tests_select_own" on public.hold_tests for select
  using ((select auth.uid()) = user_id);
create policy "hold_tests_insert_own" on public.hold_tests for insert
  with check ((select auth.uid()) = user_id);

create policy "checkins_select_own" on public.checkins for select
  using ((select auth.uid()) = user_id);
create policy "checkins_insert_own" on public.checkins for insert
  with check ((select auth.uid()) = user_id);
create policy "checkins_update_own" on public.checkins for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

grant select, insert, update on public.profiles, public.devices, public.user_preferences,
  public.sessions, public.habit_ticks, public.walking_logs, public.checkins to authenticated;
grant select, insert on public.hold_tests to authenticated;
revoke all on public.profiles, public.devices, public.user_preferences, public.sessions,
  public.habit_ticks, public.walking_logs, public.hold_tests, public.checkins from anon;

-- Profile row on signup
create or replace function public.kegel_handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'full_name')
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists kegel_on_auth_user_created on auth.users;
create trigger kegel_on_auth_user_created
  after insert on auth.users
  for each row execute function public.kegel_handle_new_user();
