-- Kegel sync RPCs + reset / delete account

create or replace function public._kegel_millis(p jsonb, p_key text)
returns bigint
language sql
immutable
as $$
  select coalesce(nullif(p ->> p_key, '')::bigint, 0);
$$;

create or replace function public._kegel_date(p text)
returns date
language sql
immutable
as $$
  select case
    when p is null or btrim(p) = '' then null
    else p::date
  end;
$$;

create or replace function public._kegel_timestamptz(p text)
returns timestamptz
language sql
immutable
as $$
  select case
    when p is null or btrim(p) = '' then null
    else p::timestamptz
  end;
$$;

-- ---------------------------------------------------------------------------
-- kegel_upsert_profile
-- ---------------------------------------------------------------------------
create or replace function public.kegel_upsert_profile(p_profile jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_millis bigint;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_millis := public._kegel_millis(p_profile, 'updated_at_millis');

  insert into public.profiles as t (
    user_id, display_name, goal, experience, sessions_per_day, track,
    level, level_started_on, plan_started_on, rest_weekday,
    onboarding_done, tutorial_done, paywall_seen, level_unlock_snoozed,
    guide_seen_at, time_zone, updated_at_millis
  )
  values (
    v_uid,
    p_profile->>'display_name',
    p_profile->>'goal',
    p_profile->>'experience',
    nullif(p_profile->>'sessions_per_day', '')::int,
    p_profile->>'track',
    coalesce(nullif(p_profile->>'level', '')::int, 1),
    public._kegel_date(p_profile->>'level_started_on'),
    public._kegel_date(p_profile->>'plan_started_on'),
    nullif(p_profile->>'rest_weekday', '')::int,
    coalesce((p_profile->>'onboarding_done')::boolean, false),
    coalesce((p_profile->>'tutorial_done')::boolean, false),
    coalesce((p_profile->>'paywall_seen')::boolean, false),
    coalesce((p_profile->>'level_unlock_snoozed')::boolean, false),
    public._kegel_timestamptz(p_profile->>'guide_seen_at'),
    p_profile->>'time_zone',
    v_millis
  )
  on conflict (user_id) do update
  set
    display_name = excluded.display_name,
    goal = excluded.goal,
    experience = excluded.experience,
    sessions_per_day = excluded.sessions_per_day,
    track = excluded.track,
    level = case when t.updated_at_millis < excluded.updated_at_millis then excluded.level else t.level end,
    level_started_on = case when t.updated_at_millis < excluded.updated_at_millis then excluded.level_started_on else t.level_started_on end,
    plan_started_on = case when t.updated_at_millis < excluded.updated_at_millis then excluded.plan_started_on else t.plan_started_on end,
    rest_weekday = case when t.updated_at_millis < excluded.updated_at_millis then excluded.rest_weekday else t.rest_weekday end,
    -- flags only turn on
    onboarding_done = t.onboarding_done or excluded.onboarding_done,
    tutorial_done = t.tutorial_done or excluded.tutorial_done,
    paywall_seen = t.paywall_seen or excluded.paywall_seen,
    level_unlock_snoozed = case when t.updated_at_millis < excluded.updated_at_millis then excluded.level_unlock_snoozed else t.level_unlock_snoozed end,
    guide_seen_at = coalesce(greatest(t.guide_seen_at, excluded.guide_seen_at), t.guide_seen_at, excluded.guide_seen_at),
    time_zone = coalesce(excluded.time_zone, t.time_zone),
    updated_at_millis = greatest(t.updated_at_millis, excluded.updated_at_millis)
  where t.updated_at_millis <= excluded.updated_at_millis
     or (not t.onboarding_done and excluded.onboarding_done)
     or (not t.tutorial_done and excluded.tutorial_done)
     or (not t.paywall_seen and excluded.paywall_seen);
end;
$$;

revoke all on function public.kegel_upsert_profile(jsonb) from public;
grant execute on function public.kegel_upsert_profile(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- kegel_upsert_sessions
-- ---------------------------------------------------------------------------
create or replace function public.kegel_upsert_sessions(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  r jsonb;
  v_millis bigint;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  for r in select * from jsonb_array_elements(coalesce(p_rows, '[]'::jsonb))
  loop
    v_millis := public._kegel_millis(r, 'updated_at_millis');

    insert into public.sessions as t (
      user_id, sync_id, started_at, completed_at, level, day_in_level,
      track, kind, duration_seconds, longest_hold_seconds, completed,
      updated_at_millis, is_deleted
    )
    values (
      v_uid,
      (r->>'sync_id')::uuid,
      public._kegel_timestamptz(r->>'started_at'),
      public._kegel_timestamptz(r->>'completed_at'),
      (r->>'level')::int,
      (r->>'day_in_level')::int,
      r->>'track',
      r->>'kind',
      coalesce(nullif(r->>'duration_seconds', '')::int, 0),
      coalesce(nullif(r->>'longest_hold_seconds', '')::int, 0),
      coalesce((r->>'completed')::boolean, false),
      v_millis,
      coalesce((r->>'is_deleted')::boolean, false)
    )
    on conflict (user_id, sync_id) do update
    set
      started_at = excluded.started_at,
      completed_at = excluded.completed_at,
      level = excluded.level,
      day_in_level = excluded.day_in_level,
      track = excluded.track,
      kind = excluded.kind,
      duration_seconds = excluded.duration_seconds,
      longest_hold_seconds = excluded.longest_hold_seconds,
      completed = excluded.completed,
      updated_at_millis = excluded.updated_at_millis,
      is_deleted = excluded.is_deleted
    where t.updated_at_millis < excluded.updated_at_millis;
  end loop;
end;
$$;

revoke all on function public.kegel_upsert_sessions(jsonb) from public;
grant execute on function public.kegel_upsert_sessions(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- kegel_upsert_habit_ticks
-- ---------------------------------------------------------------------------
create or replace function public.kegel_upsert_habit_ticks(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  r jsonb;
  v_millis bigint;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  for r in select * from jsonb_array_elements(coalesce(p_rows, '[]'::jsonb))
  loop
    v_millis := public._kegel_millis(r, 'updated_at_millis');

    insert into public.habit_ticks as t (
      user_id, sync_id, day, habit_id, updated_at_millis, is_deleted
    )
    values (
      v_uid,
      (r->>'sync_id')::uuid,
      public._kegel_date(r->>'day'),
      r->>'habit_id',
      v_millis,
      coalesce((r->>'is_deleted')::boolean, false)
    )
    on conflict (user_id, sync_id) do update
    set
      day = excluded.day,
      habit_id = excluded.habit_id,
      updated_at_millis = excluded.updated_at_millis,
      is_deleted = excluded.is_deleted
    where t.updated_at_millis < excluded.updated_at_millis;
  end loop;
end;
$$;

revoke all on function public.kegel_upsert_habit_ticks(jsonb) from public;
grant execute on function public.kegel_upsert_habit_ticks(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- kegel_upsert_walking_logs
-- ---------------------------------------------------------------------------
create or replace function public.kegel_upsert_walking_logs(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  r jsonb;
  v_millis bigint;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  for r in select * from jsonb_array_elements(coalesce(p_rows, '[]'::jsonb))
  loop
    v_millis := public._kegel_millis(r, 'updated_at_millis');

    insert into public.walking_logs as t (
      user_id, sync_id, day, minutes, updated_at_millis, is_deleted
    )
    values (
      v_uid,
      (r->>'sync_id')::uuid,
      public._kegel_date(r->>'day'),
      coalesce(nullif(r->>'minutes', '')::int, 0),
      v_millis,
      coalesce((r->>'is_deleted')::boolean, false)
    )
    on conflict (user_id, sync_id) do update
    set
      day = excluded.day,
      minutes = excluded.minutes,
      updated_at_millis = excluded.updated_at_millis,
      is_deleted = excluded.is_deleted
    where t.updated_at_millis < excluded.updated_at_millis;
  end loop;
end;
$$;

revoke all on function public.kegel_upsert_walking_logs(jsonb) from public;
grant execute on function public.kegel_upsert_walking_logs(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- kegel_upsert_checkins
-- ---------------------------------------------------------------------------
create or replace function public.kegel_upsert_checkins(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  r jsonb;
  v_millis bigint;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  for r in select * from jsonb_array_elements(coalesce(p_rows, '[]'::jsonb))
  loop
    v_millis := public._kegel_millis(r, 'updated_at_millis');

    insert into public.checkins as t (
      user_id, sync_id, day, goal, score, updated_at_millis, is_deleted
    )
    values (
      v_uid,
      (r->>'sync_id')::uuid,
      public._kegel_date(r->>'day'),
      r->>'goal',
      (r->>'score')::smallint,
      v_millis,
      coalesce((r->>'is_deleted')::boolean, false)
    )
    on conflict (user_id, sync_id) do update
    set
      day = excluded.day,
      goal = excluded.goal,
      score = excluded.score,
      updated_at_millis = excluded.updated_at_millis,
      is_deleted = excluded.is_deleted
    where t.updated_at_millis < excluded.updated_at_millis;
  end loop;
end;
$$;

revoke all on function public.kegel_upsert_checkins(jsonb) from public;
grant execute on function public.kegel_upsert_checkins(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- kegel_insert_hold_tests
-- ---------------------------------------------------------------------------
create or replace function public.kegel_insert_hold_tests(p_rows jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  r jsonb;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  for r in select * from jsonb_array_elements(coalesce(p_rows, '[]'::jsonb))
  loop
    insert into public.hold_tests as t (user_id, sync_id, held_at, seconds)
    values (
      v_uid,
      (r->>'sync_id')::uuid,
      public._kegel_timestamptz(r->>'held_at'),
      (r->>'seconds')::int
    )
    on conflict (user_id, sync_id) do nothing;
  end loop;
end;
$$;

revoke all on function public.kegel_insert_hold_tests(jsonb) from public;
grant execute on function public.kegel_insert_hold_tests(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- kegel_reset_my_data (keeps auth.users)
-- ---------------------------------------------------------------------------
create or replace function public.kegel_reset_my_data()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  delete from public.sessions where user_id = v_uid;
  delete from public.habit_ticks where user_id = v_uid;
  delete from public.walking_logs where user_id = v_uid;
  delete from public.hold_tests where user_id = v_uid;
  delete from public.checkins where user_id = v_uid;
  delete from public.user_preferences where user_id = v_uid;
  delete from public.devices where user_id = v_uid;

  update public.profiles
  set
    goal = null,
    experience = null,
    sessions_per_day = null,
    track = null,
    level = 1,
    level_started_on = null,
    plan_started_on = null,
    rest_weekday = null,
    onboarding_done = false,
    tutorial_done = false,
    paywall_seen = false,
    level_unlock_snoozed = false,
    guide_seen_at = null,
    updated_at_millis = 0,
    updated_at = now()
  where user_id = v_uid;
end;
$$;

revoke all on function public.kegel_reset_my_data() from public;
grant execute on function public.kegel_reset_my_data() to authenticated;

-- ---------------------------------------------------------------------------
-- kegel_delete_my_account
-- ---------------------------------------------------------------------------
create or replace function public.kegel_delete_my_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  delete from auth.users where id = v_uid;
end;
$$;

revoke all on function public.kegel_delete_my_account() from public;
grant execute on function public.kegel_delete_my_account() to authenticated;

notify pgrst, 'reload schema';
