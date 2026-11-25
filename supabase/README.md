# Supabase (Kegel Exercises)

## Rules

- Additive migrations only — never edit a migration that has already been applied.
- Every table has row-level security (RLS).
- Policies use `(select auth.uid())`.
- Apply with the CLI only: `supabase link` then `supabase db push`.
- Never put the service role key in the app or in git.
- Test project first; production is applied by the manager from a handoff checklist.

## Auth redirect

`kegel://auth-callback`

## Apply (test)

```bash
supabase link --project-ref <test-ref>
supabase db push
```

## Checks

```sql
select proname from pg_proc where proname like 'kegel_%';
select tablename, rowsecurity from pg_tables where schemaname = 'public';
```
