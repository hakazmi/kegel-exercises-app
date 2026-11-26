/**
 * Generates production documentation for the Men's Kegel Exercises app.
 * Sources: docs/product-spec.md, decisions, firebase plans, codebase.
 */
const {
  Document,
  Packer,
  Paragraph,
  TextRun,
  Table,
  TableRow,
  TableCell,
  HeadingLevel,
  AlignmentType,
  BorderStyle,
  WidthType,
  PageNumber,
  Header,
  Footer,
  LevelFormat,
  ShadingType,
} = require('docx');
const fs = require('fs');
const path = require('path');

const PAGE_WIDTH = 12240;
const MARGIN = 1080;
const CONTENT_WIDTH = PAGE_WIDTH - MARGIN * 2;

const brandGreen = '0B7A4B';
const ink = '0E1412';
const muted = '66706B';
const border = 'DCE3E0';
const softBg = 'F5F7F6';

function hr() {
  return new Paragraph({
    spacing: { before: 120, after: 200 },
    border: {
      bottom: { style: BorderStyle.SINGLE, size: 12, color: border },
    },
    children: [],
  });
}

function p(text, opts = {}) {
  return new Paragraph({
    spacing: { after: opts.after ?? 160, before: opts.before ?? 0, line: 276 },
    alignment: opts.align,
    children: [
      new TextRun({
        text,
        font: 'Calibri',
        size: opts.size ?? 22,
        color: opts.color ?? ink,
        bold: opts.bold,
        italics: opts.italics,
      }),
    ],
  });
}

function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 160 },
    children: [
      new TextRun({ text, font: 'Calibri', size: 32, bold: true, color: brandGreen }),
    ],
  });
}

function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 280, after: 120 },
    children: [
      new TextRun({ text, font: 'Calibri', size: 26, bold: true, color: ink }),
    ],
  });
}

function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 200, after: 80 },
    children: [
      new TextRun({ text, font: 'Calibri', size: 24, bold: true, color: ink }),
    ],
  });
}

function bullet(text, ref = 'bullets') {
  return new Paragraph({
    numbering: { reference: ref, level: 0 },
    spacing: { after: 80, line: 276 },
    children: [
      new TextRun({ text, font: 'Calibri', size: 22, color: ink }),
    ],
  });
}

function cell(text, opts = {}) {
  const width = opts.width ?? 2340;
  return new TableCell({
    width: { size: width, type: WidthType.DXA },
    shading: opts.header
      ? { type: ShadingType.CLEAR, fill: brandGreen }
      : opts.alt
        ? { type: ShadingType.CLEAR, fill: softBg }
        : undefined,
    borders: {
      top: { style: BorderStyle.SINGLE, size: 4, color: border },
      bottom: { style: BorderStyle.SINGLE, size: 4, color: border },
      left: { style: BorderStyle.SINGLE, size: 4, color: border },
      right: { style: BorderStyle.SINGLE, size: 4, color: border },
    },
    margins: { top: 60, bottom: 60, left: 80, right: 80 },
    children: [
      new Paragraph({
        children: [
          new TextRun({
            text,
            font: 'Calibri',
            size: opts.header ? 20 : 19,
            bold: opts.header || opts.bold,
            color: opts.header ? 'FFFFFF' : ink,
          }),
        ],
      }),
    ],
  });
}

function table(headers, rows, widths) {
  const cols = widths || headers.map(() => Math.floor(CONTENT_WIDTH / headers.length));
  return new Table({
    width: { size: CONTENT_WIDTH, type: WidthType.DXA },
    columnWidths: cols,
    rows: [
      new TableRow({
        children: headers.map((h, i) => cell(h, { header: true, width: cols[i] })),
      }),
      ...rows.map(
        (r, ri) =>
          new TableRow({
            children: r.map((c, i) =>
              cell(String(c), { width: cols[i], alt: ri % 2 === 1 }),
            ),
          }),
      ),
    ],
  });
}

const doc = new Document({
  styles: {
    default: {
      document: {
        styles: [
          {
            id: 'Normal',
            run: { font: 'Calibri', size: 22, color: ink },
          },
        ],
      },
    },
  },
  numbering: {
    config: [
      {
        reference: 'bullets',
        levels: [
          {
            level: 0,
            format: LevelFormat.BULLET,
            text: '•',
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 360, hanging: 180 } } },
          },
        ],
      },
      {
        reference: 'flow',
        levels: [
          {
            level: 0,
            format: LevelFormat.DECIMAL,
            text: '%1.',
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 360, hanging: 180 } } },
          },
        ],
      },
      {
        reference: 'safety',
        levels: [
          {
            level: 0,
            format: LevelFormat.DECIMAL,
            text: '%1.',
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 360, hanging: 180 } } },
          },
        ],
      },
    ],
  },
  sections: [
    {
      properties: {
        page: {
          size: { width: PAGE_WIDTH, height: 15840 },
          margin: { top: MARGIN, bottom: MARGIN, left: MARGIN, right: MARGIN },
        },
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              children: [
                new TextRun({
                  text: 'Kegel Exercises — Product & Technical Documentation',
                  font: 'Calibri',
                  size: 16,
                  color: muted,
                }),
              ],
              border: {
                bottom: { style: BorderStyle.SINGLE, size: 6, color: border },
              },
            }),
          ],
        }),
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              alignment: AlignmentType.RIGHT,
              children: [
                new TextRun({ text: 'Confidential  ·  Page ', font: 'Calibri', size: 16, color: muted }),
                new TextRun({ children: [PageNumber.CURRENT], font: 'Calibri', size: 16, color: muted }),
                new TextRun({ text: ' of ', font: 'Calibri', size: 16, color: muted }),
                new TextRun({ children: [PageNumber.TOTAL_PAGES], font: 'Calibri', size: 16, color: muted }),
              ],
            }),
          ],
        }),
      },
      children: [
        // COVER
        new Paragraph({ spacing: { before: 1200 }, children: [] }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({
              text: 'KEGEL EXERCISES',
              font: 'Calibri',
              size: 56,
              bold: true,
              color: brandGreen,
            }),
          ],
        }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { before: 120, after: 200 },
          children: [
            new TextRun({
              text: 'Men’s Pelvic Floor Trainer',
              font: 'Calibri',
              size: 28,
              color: ink,
            }),
          ],
        }),
        hr(),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { before: 200 },
          children: [
            new TextRun({
              text: 'Product & Technical Documentation',
              font: 'Calibri',
              size: 32,
              bold: true,
              color: ink,
            }),
          ],
        }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { before: 80, after: 400 },
          children: [
            new TextRun({
              text: 'Production reference for product, engineering, QA and compliance',
              font: 'Calibri',
              size: 22,
              color: muted,
              italics: true,
            }),
          ],
        }),
        table(
          ['Field', 'Value'],
          [
            ['Document type', 'Product & technical specification'],
            ['Product name', 'Kegel Exercises (temporary display name)'],
            ['Application ID', 'com.syarix.kegelexercisesapp'],
            ['Platforms', 'Android and iOS (single Flutter codebase)'],
            ['Audience', 'Adult men (18+)'],
            ['Primary sources', 'Product Spec v1, decisions log, Firebase plan, codebase'],
            ['Version of this document', '1.0 — November 2026'],
            ['Classification', 'Internal / production'],
          ],
          [3200, 6880],
        ),
        p(
          'This document describes how the shipped product works today: user journeys, screens, features, data storage, cloud sync, analytics, Crashlytics and Performance Monitoring. It is intended for product managers, engineers, QA and store-compliance reviewers.',
          { before: 360, after: 200 },
        ),
        p(
          'Disclaimer: The app is not a medical device and does not diagnose, treat, cure or prevent any medical condition. Users should speak with a healthcare professional for medical advice.',
          { italics: true, color: muted },
        ),

        // 1 INTRO
        h1('1. Introduction'),
        h2('1.1 Purpose of the product'),
        p(
          'Kegel Exercises is a guided pelvic floor trainer for adult men. It delivers a short setup, a real guided session on day one, and a progressive multi-week level plan. The product focuses on bladder control, erection support, ejaculation control, recovery after prostate surgery, and general pelvic health — using clinical, non-sexual wording and visuals throughout.',
        ),
        h2('1.2 Product principles'),
        bullet('First rep within about two minutes of install.'),
        bullet('Ask only what changes the training plan.'),
        bullet('Claim only what can be sourced — no invented statistics, testimonials or predicted results.'),
        bullet('Relaxation and safety content is always free.'),
        bullet('Training data stays on the device by default; optional account sync is offline-first.'),
        bullet('Clinical, non-sexual wording and visuals everywhere, including store listing.'),
        h2('1.3 Who it is for'),
        p(
          'Adult men (18+) who want a practical, discreet daily practice. The app never diagnoses conditions (it does not label users with erectile dysfunction, premature ejaculation or similar from their answers).',
        ),
        h2('1.4 What “done” looks like for v1'),
        p(
          'Core training loop shipped: onboarding, tutorial, session player, levels and tracks, Today / Progress / Learn tabs, Settings, reminders, check-ins, safety routing, Crashlytics, Performance and Analytics. Paywall / RevenueCat and final store hardening remain open items on the build checklist.',
        ),

        // 2 ARCHITECTURE
        h1('2. System architecture'),
        h2('2.1 Technology stack'),
        table(
          ['Layer', 'Choice'],
          [
            ['UI framework', 'Flutter (Dart 3), material_ui (not flutter/material)'],
            ['State', 'flutter_riverpod (no code generation)'],
            ['Navigation', 'go_router'],
            ['Local DB', 'Drift (SQLite) + SharedPreferences'],
            ['Content', 'JSON / Markdown under assets/content'],
            ['Cloud (optional)', 'Supabase Auth + sync RPCs (offline-first)'],
            ['Billing (planned)', 'RevenueCat / purchases_flutter'],
            ['Notifications', 'flutter_local_notifications + timezone'],
            ['Voice / haptics', 'flutter_tts, vibration / HapticFeedback'],
            ['Observability', 'Firebase Analytics, Crashlytics, Performance'],
          ],
          [3200, 6880],
        ),
        h2('2.2 Code organisation'),
        bullet('lib/features — feature screens and controllers (UI draws; logic in notifiers).'),
        bullet('lib/core — domain models, plan rules, session engine, data, cloud, diagnostics.'),
        bullet('lib/app — theme tokens, router, localisation (ARB), root wiring.'),
        bullet('assets/content — levels, exercises, tracks, articles (not hard-coded in widgets).'),
        h2('2.3 Session engine'),
        p(
          'The session player is driven by a pure Dart state machine (no Flutter imports): idle → countdown → squeeze / hold / relax / rest → paused → done. Each transition can fire vibration, optional TTS and ring animation reset. Session definitions (reps, hold times, positions) come from content JSON so levels can be tuned without rewriting UI.',
        ),

        // 3 FLOW
        h1('3. Application flow'),
        h2('3.1 First-run journey'),
        new Paragraph({
          numbering: { reference: 'flow', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Install and optional sign-in (when Supabase keys are configured).', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'flow', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Onboarding O1–O6 (~60 seconds): age gate, goal, safety, experience, time/reminder, plan preview.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'flow', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Muscle-finding tutorial T1 (skipped only if user is confident; still available in Learn).', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'flow', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'First real session: S1 Before → S2 Countdown → S3 Player → S4 Done (feel check).', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'flow', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Land on Today (H1). Paywall is reserved after first session / locked content (RevenueCat still pending).', font: 'Calibri', size: 22 })],
        }),
        h2('3.2 Daily loop'),
        bullet('Open Today → see week strip, level progress, today’s items.'),
        bullet('Start next unfinished item (strengthening, optional body work, breathing).'),
        bullet('Complete session → feel check → streak / unlock rules update.'),
        bullet('Optional Progress check-in (after session 3, then every 4 weeks).'),
        bullet('Learn articles and Settings available any time.'),
        h2('3.3 Safety branches'),
        bullet('Pain at O3 or S4 → relaxation-first track + clinician note (H3).'),
        bullet('Catheter at O3 → strengthening blocked until answer updated.'),
        bullet('Recent surgery → confirm understanding, then continue with caution copy.'),
        bullet('Daily strengthening capped at 3 sessions; weekly rest day; daily breathing.'),

        // 4 FEATURES
        h1('4. Features and how they work'),
        h2('4.1 Guided training sessions'),
        p(
          'Sessions combine a ring timer, phase cues (Squeeze / Hold / Relax / Rest), optional voice, vibration patterns, and position guidance. Wakelock keeps the screen on during play. Exit mid-session is confirmed and does not count as completed.',
        ),
        h2('4.2 Levels and progression'),
        p(
          'Five levels increase hold duration, reps and functional extras over time. A level unlock offer appears when the user completes enough recent days (at least 5 of the last 7 in the current span). Unlock is never silent: the user chooses Start next level or Stay. Free users may be routed to paywall for Levels 2–5 depending on entitlement flags.',
        ),
        h2('4.3 Goal tracks'),
        table(
          ['Track', 'Set by', 'Behaviour'],
          [
            ['General & bladder', 'Goal choice', 'Standard levels; Knack from Level 3'],
            ['Erection support', 'Goal choice', 'Strong holds from L3; bridge/squat in L4'],
            ['Ejaculation control', 'Goal choice', 'Extra reverse Kegel / breathing from L1'],
            ['After prostate surgery', 'Goal choice', 'Gentler holds; blocked with catheter'],
            ['Relaxation first', 'Pain path', 'No strengthening for ~2 weeks'],
          ],
          [2400, 2400, 5280],
        ),
        h2('4.4 Reminders'),
        p(
          'Local scheduled notifications (discreet by default). Channel name: “Daily reminder”. No marketing blasts. Reminder scheduling is best-effort and must never block onboarding or session completion.',
        ),
        h2('4.5 Progress & check-ins'),
        p(
          'Progress shows streak, this-week sessions, longest prescribed hold completed, calendar, and check-in card. Check-in scores stay on device and are never sent to Analytics. No-change after 8 weeks suggests seeing a doctor — without diagnosing.',
        ),
        h2('4.6 Learn'),
        p(
          'Eight short articles with sources. Featured path replays the muscle-finding tutorial. Safety and relaxation content remains free.',
        ),
        h2('4.7 Hold test & habits (supporting tools)'),
        p(
          'Optional hold-test history and daily habit ticks / walking minutes support engagement. Habit ticks do not drive streak or level unlock.',
        ),
        h2('4.8 Optional cloud account'),
        p(
          'When Supabase is configured, users can sign in (email or Google). Sync is offline-first: local Drift rows carry sync_id / sync_dirty flags; a coordinator debounces push and pulls on resume. Reset data and delete account clear local state and rotate the anonymous Crashlytics install id.',
        ),

        // 5 SCREENS
        h1('5. Screen catalogue'),
        h2('5.1 Auth'),
        table(
          ['ID', 'Screen', 'Purpose'],
          [['Auth', 'Sign in / Sign up', 'Optional when cloud keys present; otherwise skipped']],
          [1200, 2800, 6080],
        ),
        h2('5.2 Onboarding'),
        table(
          ['ID', 'Screen', 'Purpose'],
          [
            ['O1', 'Welcome', 'Age confirmation, medical disclaimer, Terms / Privacy'],
            ['O2', 'Goal', 'Single choice → track'],
            ['O3', 'Safety check', 'Pain / surgery / catheter routing'],
            ['O4', 'Experience', 'Whether tutorial is required'],
            ['O5', 'Time & reminder', 'Sessions per day + reminder permission'],
            ['O6', 'Your plan', 'Honest timeline; start first session'],
          ],
          [1000, 2600, 6480],
        ),
        h2('5.3 Tutorial & session'),
        table(
          ['ID', 'Screen', 'Purpose'],
          [
            ['T1', 'Muscle-finding tutorial', 'Where / how / don’ts + practice reps'],
            ['S1', 'Before you start', 'Blocks, duration, position; Start'],
            ['S2', 'Countdown', '5-second get ready (skippable)'],
            ['S3', 'Player', 'Ring timer, cues, voice, vibration, pause/exit'],
            ['S4', 'Session done', 'Summary, feel check, next step'],
            ['P1', 'Paywall', 'Plans / restore (RevenueCat pending)'],
          ],
          [1000, 2800, 6280],
        ),
        h2('5.4 Main tabs & supporting screens'),
        table(
          ['ID', 'Screen', 'Purpose'],
          [
            ['H1', 'Today', 'Week strip, level card, today’s list, Start'],
            ['H2', 'Levels / Level day', 'Five levels, day panels, unlock state'],
            ['H3', 'Pain help', 'Stop strengthening; switch to relaxation'],
            ['G1', 'Progress', 'Streak, calendar, stats, check-in entry'],
            ['G2', 'Check-in', 'One goal question, 1–5 scale'],
            ['L1', 'Learn', 'Article list + featured tutorial'],
            ['L2', 'Article', 'Markdown article with sources'],
            ['X1', 'Settings', 'Plan, reminders, session, privacy, about'],
            ['—', 'Safety answers', 'Re-run O3 routing from Settings'],
            ['—', 'Exercise detail / Habit guide / Hold test', 'Supporting training tools'],
          ],
          [1000, 3200, 5880],
        ),
        h2('5.5 Screen behaviour notes'),
        bullet('Today is the home of “what do I do now”; completed Day N shows Day N+1 as tomorrow (Start locked until the next calendar day).'),
        bullet('Rest day sits inside each plan week (day 7 relative to plan start), with breathing still available.'),
        bullet('System back on session screens matches Exit confirm; Progress/Learn back returns to Today.'),
        bullet('Portrait-only; edge-to-edge system UI with light/dark chrome per screen.'),

        // 6 CONTENT
        h1('6. Training content model'),
        h2('6.1 Exercise library (summary)'),
        p(
          'Content lives in assets/content (exercises.json, levels.json, tracks.json, articles). Examples include Slow hold, Quick squeeze, Strong hold, Standing/walking holds, Bridge, Squat, The Knack, Diaphragmatic breathing, Reverse Kegel, and stretch poses. Numbers follow common patient guidance and require clinical review before store claims.',
        ),
        h2('6.2 Levels (fastest pace overview)'),
        table(
          ['Level', 'Days', 'Focus'],
          [
            ['1 Start', '1–7', 'Short holds, lying/sitting'],
            ['2 Build', '8–14', 'Longer holds, sitting'],
            ['3 Steady', '15–28', 'Sitting + standing'],
            ['4 Deep', '29–56', 'Standing; bridge/squat extras'],
            ['5 Maintain', '57+', 'Any position; walking holds / Knack'],
          ],
          [2200, 2200, 5680],
        ),
        p('Every day includes daily relaxation breathing. Strengthening is capped at three sessions per day.'),

        // 7 DATABASE
        h1('7. Data layer and database'),
        h2('7.1 Design'),
        p(
          'Primary store is on-device SQLite via Drift. Profile and preferences use SharedPreferences. Hold-test results use prefs. Cloud sync mirrors selected tables to Supabase under RLS when the user is signed in — local writes remain the source of truth until successfully pushed.',
        ),
        h2('7.2 Drift tables (schema version 3)'),
        table(
          ['Table', 'Key fields', 'Notes'],
          [
            [
              'sessions',
              'startedAt, completedAt, level, dayInLevel, track, kind, durationSeconds, longestHoldSeconds, completed, feel',
              'kind: strengthening|body|breathing|relaxation; feel never analytics',
            ],
            [
              'checkins',
              'date, goal, score',
              'Scores on device only; never Analytics',
            ],
            [
              'habit_ticks',
              'date, habitId',
              'Do not drive streak/unlock',
            ],
            [
              'walking_logs',
              'date, minutes',
              'Self-reported walking',
            ],
          ],
          [2200, 4200, 3680],
        ),
        h2('7.3 Sync columns (all four tables)'),
        bullet('sync_id — stable UUID for cloud identity of the row'),
        bullet('updated_at_millis — conflict / freshness'),
        bullet('sync_dirty — needs push'),
        bullet('is_deleted — soft delete for sync tombstones'),
        h2('7.4 Profile / settings (prefs)'),
        p(
          'UserProfile holds goal, safety flags, experience, sessionsPerDay, reminder settings, track, level, levelStartedOn, planStartedOn, restWeekday, onboardingDone, tutorialDone, voice/vibration, paywallSeen, unlock snooze flags, and related fields. Safety answers and clinical scores must never leave the phone via analytics or Crashlytics keys.',
        ),
        h2('7.5 Data reset'),
        p(
          'Settings → Reset / Delete account clears Drift tables, prefs, reminders, and sync metadata (optionally auth hint). Crashlytics installation_id is rotated so future crash reports are not joined to the wiped install.',
        ),

        // 8 ANALYTICS
        h1('8. Analytics'),
        p(
          'Product analytics use Firebase Analytics behind AnalyticsService. Only the allowlisted events from Product Spec §14 are sent. A deny-list strips sensitive parameter keys if ever passed accidentally.',
        ),
        table(
          ['Event', 'When', 'Properties'],
          [
            ['onboarding_step', 'Each O1–O6 complete', 'step'],
            ['onboarding_done', 'O6 finished', 'sessions_per_day, reminder_on'],
            ['tutorial_done', 'T1 finished', 'felt_lift (yes | not_sure)'],
            ['session_start', 'S3 begins', 'level, session_number_today'],
            ['session_done', 'S4 shown', 'level, seconds'],
            ['session_exit', 'Exit mid-session', 'level, phase'],
            ['paywall_view', 'Paywall shown', 'source'],
            ['trial_start / purchase', 'Store confirms', 'plan'],
            ['level_up', 'Level unlocked', 'level'],
            ['reminder_change', 'Reminder toggled', 'on'],
          ],
          [2800, 3200, 4080],
        ),
        p(
          'Funnel to watch: install → onboarding done → first session done → day-2 return → day-7 return → trial/purchase → day-30 return. North-star: men completing 4+ session days per week.',
        ),

        // 9 CRASHLYTICS PERFORMANCE
        h1('9. Crashlytics and Performance Monitoring'),
        h2('9.1 Goals'),
        p(
          'Crashlytics answers “what failed and in what context?” Performance answers “what was slow?” Neither may receive clinical answers, session feel, check-in scores, emails or auth user ids.',
        ),
        h2('9.2 Bootstrap'),
        bullet('Firebase.initializeApp() — no-ops if google-services.json / plist missing.'),
        bullet('CrashReporting.initialize — anonymous installation_id, app_version, build_type, Flutter error hooks.'),
        bullet('Gradle Google Services + Crashlytics plugins apply only when config file exists.'),
        bullet('Performance custom traces via Flutter firebase_performance (AGP 9: native perf Gradle plugin omitted due to Transform API removal).'),
        h2('9.3 Crashlytics custom keys (examples)'),
        table(
          ['Key', 'Meaning'],
          [
            ['installation_id', 'Anonymous UUID; rotated on wipe/delete'],
            ['app_version', 'version (buildNumber)'],
            ['build_type', 'debug | profile | release'],
            ['signed_in / cloud_sync_enabled', 'Booleans only'],
            ['onboarding_done / tutorial_done', 'Booleans'],
            ['track / level / screen', 'Coarse navigation context'],
            ['session_kind / voice_on / vibration_on', 'Session context'],
          ],
          [4200, 5880],
        ),
        h2('9.4 Breadcrumbs & non-fatals'),
        p(
          'Breadcrumbs (≤300 chars) mark coarse lifecycle: app start, auth (no email), onboarding step, session begin/play/done/exit, sync push/pull, video init, reminder schedule, account reset/delete. Non-fatals are recorded for real failures (video decode, sync, Drift, TTS, notifications) after local handling — not for expected user cancels.',
        ),
        h2('9.5 Performance custom traces'),
        table(
          ['Trace', 'Measures'],
          [
            ['app_hydrate', 'Prefs + cloud bootstrap after Firebase init'],
            ['session_engine_build', 'Definition + engine construction'],
            ['session_play', 'Play duration; metrics elapsed_sec, completed, pause_count'],
            ['video_init', 'Asset init; metric ok 0/1; abandon on cancel'],
            ['sync_push / sync_pull', 'Cloud batch latency; row_count'],
            ['account_action', 'Reset or delete account'],
          ],
          [3600, 6480],
        ),
        p(
          'Rules: session-scoped traces only — never per tick or per video frame. Failed work should abandon traces (do not stop) so averages stay clean.',
        ),
        h2('9.6 Privacy checklist for observability'),
        bullet('Never send: safety flags, feel, check-in scores, email, display name, Supabase user id, tokens.'),
        bullet('Rotate installation_id on reset / delete account.'),
        bullet('Update Privacy Policy and Play Data safety for crash logs, diagnostics and analytics.'),

        // 10 SAFETY
        h1('10. Safety rules (product requirements)'),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Pain at onboarding or after a session → relaxation only + clinician note.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'No exercises while a catheter is in place.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Strengthening capped at 3 sessions a day.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Weekly rest day and daily relaxation breathing.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Cue every session: relax buttocks, thighs and stomach; keep breathing.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'Stopping urine flow is a one-time test, never an exercise.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'No promise of results; timelines say results vary.', font: 'Calibri', size: 22 })],
        }),
        new Paragraph({
          numbering: { reference: 'safety', level: 0 },
          spacing: { after: 80 },
          children: [new TextRun({ text: 'No change after 8 weeks on check-in → suggest seeing a doctor.', font: 'Calibri', size: 22 })],
        }),
        p('The app never diagnoses from questionnaire answers.'),

        // 11 FREE PREMIUM
        h1('11. Free and Premium'),
        table(
          ['Feature', 'Free', 'Premium'],
          [
            ['Onboarding, tutorial, Learn', 'Yes', 'Yes'],
            ['Level 1 + daily breathing', 'Yes', 'Yes'],
            ['Relaxation-first / pain help', 'Yes', 'Yes'],
            ['Reminders, streak, calendar', 'Yes', 'Yes'],
            ['Levels 2–5', 'No', 'Yes'],
            ['Goal-specific extras', 'No', 'Yes'],
            ['Check-in history comparison', 'Baseline only', 'Yes'],
          ],
          [4200, 2940, 2940],
        ),
        p(
          'Pricing must come from store products (RevenueCat) — never hard-coded trial length or prices in UI copy. Paywall close must remain available; Level 1 and safety content stay free.',
        ),

        // 12 STATUS
        h1('12. Delivery status (engineering checklist)'),
        table(
          ['Area', 'Status'],
          [
            ['Scaffold, theme, router', 'Done'],
            ['Data, content, plan rules', 'Done'],
            ['Onboarding O1–O6', 'Done'],
            ['Tutorial + session player', 'Done'],
            ['Home / Progress / Learn / Settings', 'Done'],
            ['Reminders + level unlock offer', 'Done'],
            ['Analytics + Crashlytics + Performance', 'Done (config local)'],
            ['Paywall + RevenueCat', 'Open'],
            ['QA hardening + store release', 'Open'],
          ],
          [5200, 4880],
        ),

        // 13 APPENDIX
        h1('13. Appendix — related project documents'),
        bullet('docs/product-spec.md — authoritative product behaviour and copy rules.'),
        bullet('docs/decisions.md — decisions not spelled out in the spec.'),
        bullet('docs/progress.md — Prompt 0–13 build checklist.'),
        bullet('docs/firebase-crashlytics-performance-plan.md — observability design.'),
        bullet('docs/firebase-setup.md — local google-services.json placement.'),
        bullet('docs/supabase-integration-plan.md — cloud account / sync design.'),
        p(
          'End of document. For store submission, re-read Google Play Health Content policy the week of upload and complete Data safety for Analytics, Crashlytics and Performance.',
          { before: 200, italics: true, color: muted },
        ),
      ],
    },
  ],
});

const outPath = path.join(__dirname, 'Kegel_Exercises_Product_Technical_Documentation.docx');
Packer.toBuffer(doc).then((buffer) => {
  fs.writeFileSync(outPath, buffer);
  console.log('WROTE ' + outPath);
});
