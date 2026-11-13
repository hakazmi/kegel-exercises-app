# Men's Kegel App: Product Spec v1

Nov 12, 2026 · @Haider Ali

## 1. Product summary

A simple pelvic floor trainer for men: a 60-second setup, a guided 2-minute session on day one, and a level plan that progresses over 8 weeks or more. The reference app proves the session player works; this spec keeps that and removes the 50-screen funnel in front of it.

**Who it is for:** adult men (18+) who want bladder control, erection support, ejaculation control, recovery after prostate surgery, or general pelvic health.

**Product principles** (every screen must pass these):

- First rep within 2 minutes of install.
- Ask only what changes the plan.
- Claim only what we can source. No invented statistics, testimonials, endorsement logos or predicted results.
- Relaxation and safety content is always free.
- Data stays on the device. No account in v1.
- Clinical, non-sexual wording and visuals everywhere, including the store listing.

## 2. Scope

v1 ships the session player, five levels, five tracks and three tabs. Everything else from the reference app is cut.

**In v1**

- 6-screen onboarding
- Muscle-finding tutorial
- Session player with ring timer, voice cues and vibration
- 5 levels, 5 goal tracks, including a relaxation-first track
- Today, Progress and Learn tabs, plus Settings
- Reminders, streak, 4-week check-in
- "I felt pain" flow
- Subscription paywall shown after the first session

**Cut from the reference app**

| Cut | Why |
| --- | --- |
| 39-step quiz, body type, habits, sleep, relationship questions | Do not change the plan; main user complaint |
| Fake "preparing your plan" loader, predicted peak date, strength curve | Not real; nothing is measured |
| Before/after photos, testimonials, "89%" statistics | Unsourced; misleading-claims risk |
| NHS, Mayo, Harvard logos, "expert approved" seal, "Best Kegel App" badge | Implies endorsement we do not have |
| Community, Ask tab, leaderboard | Moderation and privacy burden; little user value |
| No-sugar and no-smoking challenges, knowledge test, cross-promo banner | Filler, off-topic |
| "Sexual guide" and libido articles | Store policy risk; unsupported claims |
| Email and account prompt | Not needed while data is local |
| Separate fitness workouts | Only bridge and squat are kept, inside the levels |

## 3. App map

The app has 19 screens: 6 onboarding, 5 in the session flow, 1 paywall and 7 across three tabs. First-run order is Onboarding, Tutorial, First session, Paywall, Today.

| ID | Screen | Purpose |
| --- | --- | --- |
| O1 | Welcome | Age confirmation, disclaimer |
| O2 | Goal | Picks the track |
| O3 | Safety check | Routes pain and surgery cases |
| O4 | Experience | Decides whether the tutorial is shown |
| O5 | Time and reminder | Sessions per day, notification permission |
| O6 | Your plan | Real schedule, honest timeline |
| T1 | Muscle-finding tutorial | Teaches the correct contraction |
| S1 | Before you start | What this session contains |
| S2 | Countdown | 5 seconds |
| S3 | Player | Squeeze, hold, relax, rest |
| S4 | Session done | Result, pain check, next step |
| P1 | Paywall | Plans and terms |
| H1 | Today (tab) | Today's sessions |
| H2 | Levels | The 5 levels and where the user is |
| H3 | Pain help | Stops strengthening, offers relaxation, clinician note |
| G1 | Progress (tab) | Streak, calendar, check-in |
| G2 | Check-in | One question for the user's goal |
| L1 | Learn (tab) | 8 short articles with sources |
| X1 | Settings | Plan, reminders, data, legal |

## 4. Onboarding (6 screens, about 60 seconds)

Six screens replace the reference app's 39. Each one sets something the plan uses. A progress bar shows 1 of 6 to 6 of 6, and Back works on every screen.

**O1 Welcome**

- Title: "Train your pelvic floor in a few minutes a day"
- Body: "Guided exercises for bladder control and pelvic health. No equipment."
- Checkbox (required): "I am 18 or older"
- Small print: "This app is not a medical device and does not diagnose, treat, cure or prevent any medical condition. Talk to a healthcare professional for medical advice."
- Button: "Get started". Links: Terms, Privacy Policy.

**O2 Goal** (single choice, required)

- Question: "What do you want to work on?"
- Options: Bladder control · Erection support · Ejaculation control · Recovery after prostate surgery · General pelvic health
- Logic: sets the track (section 8). Changeable later in Settings.

**O3 Safety check** (multi-select, required)

- Question: "Do any of these apply to you?"
- Options: Pelvic, groin or genital pain · Pain with erection or ejaculation · Surgery in the last 3 months · A urinary catheter in place right now · None of these
- Logic:
  - Either pain option: assign the relaxation-first track. Show: "Squeezing exercises can make pain worse. We will start you with relaxation only. Please see a doctor or pelvic floor physiotherapist."
  - Catheter: no exercises are unlocked. Show: "Do not do these exercises with a catheter in place. Come back when it is removed and your care team says you can start." Learn tab stays open.
  - Recent surgery: show "Check with your surgeon or physiotherapist before starting." The user confirms to continue.

**O4 Experience** (single choice)

- Question: "Have you done Kegel exercises before?"
- Options: No · Yes, but I am not sure I do them right · Yes, I am confident
- Logic: the first two show the tutorial (T1) before the first session. The third skips it; it stays available in Learn.

**O5 Time and reminder**

- Question: "How much time can you give each day?"
- Options: About 3 minutes (1 session) · About 5 minutes (2 sessions) · About 10 minutes (3 sessions)
- Reminder: time picker, default 9:00 pm. Buttons: "Remind me" (triggers the system permission prompt) and "Not now".

**O6 Your plan**

- Shows: track name, Level 1 week view with one rest day, sessions per day, session length.
- Timeline copy: "Week 1: you learn the movement. Most men feel no change yet, and that is normal. Weeks 2 to 4: holds get easier. Weeks 6 to 12: the usual window for noticing results with daily practice. Results vary."
- Button: "Start my first session"

Not asked at onboarding: age band, body type, symptoms, habits, sleep, relationship, events, target date.

## 5. Tutorial, first session and paywall

The user does a real session before seeing a price. The paywall comes after it and can be closed.

**T1 Muscle-finding tutorial** (3 cards, then a practice)

1. Where: a side-view diagram with the pelvic floor highlighted. "These muscles run from the pubic bone to the tailbone and support the bladder and bowel."
2. How to find them: "Tighten as if you are stopping yourself passing wind, and draw the penis slightly inward. The testicles should lift a little." Note: "You can test once by slowing your urine flow. Do not practise that way."
3. What to avoid: "Keep buttocks, thighs and stomach relaxed. Keep breathing."
4. Practice: 3 guided reps (squeeze 3 seconds, relax 3 seconds). Then: "Did you feel the lift?" Yes continues. Not sure repeats the practice or continues anyway, with a tip to try lying down.

**First session:** Level 1, Day 1, through the normal player (section 7).

**S4 Session done:** "Session 1 complete." Streak starts at 1 day. Pain check (section 7). Button: "Continue".

**P1 Paywall**

- When: once after the first session, and whenever the user taps locked content. Never before the first session.
- Close (X) is visible from the start. Closing goes to Today with the free tier.
- Headline: "Unlock the full program"
- Three lines: "Levels 2 to 5 with progressive plans" · "Programs built for your goal" · "Detailed progress and 4-week check-ins"
- A plain line: "Level 1, the tutorial and relaxation exercises stay free."
- Plan cards: billed price and billing period are the largest text. A per-day price may appear smaller underneath.
- Under the button, always visible: trial length if any, the price charged when the trial ends, that it renews automatically, and "Cancel anytime in Google Play".
- Footer: Restore purchase · Terms · Privacy Policy.
- No countdown timers, no pre-selected upsell, no imagery of couples.

## 6. Today tab (H1, H2, H3)

Today answers one question: what do I do now. It shows only today's sessions and one button.

**H1 Today, top to bottom**

1. Week strip: 7 days, completed days ticked, rest day marked.
2. Level card: "Level 1 · Day 3 of 7". Tapping opens H2.
3. Today's list: Session 1, Session 2, Session 3 (marked optional), then Relaxation breathing (2 minutes). The count follows the O5 choice. Each row shows its length and a tick when done.
4. Primary button: "Start session" (starts the next undone item).
5. Text link: "I felt pain" (opens H3).

**States**

- All done: "Done for today. Rest is part of the training."
- Rest day: breathing only, with "Rest day. Your muscles recover today."
- Daily cap: after 3 strengthening sessions the button is disabled with "That is enough for today. Doing more can tire the muscles and slow progress."
- Missed days: no guilt message. The plan resumes on the same level day.
- Catheter flag: no sessions, only the O3 message and a button to update the answer.

**H2 Levels:** the 5 levels with day ranges, the current one highlighted, locked ones showing a lock for free users. The user can repeat a level or step down one level at any time.

**H3 Pain help**

- Copy: "Stop the squeezing exercises for now. Pain can mean the muscles are too tight, and more squeezing can make that worse."
- Actions: "Switch me to relaxation exercises" (changes the track) · "Keep my plan" · a note to see a doctor or pelvic floor physiotherapist, especially if pain continues or occurs with erection or ejaculation.

## 7. Session player (S1 to S4)

This is the core of the product and follows the reference app closely: a ring timer, one cue at a time, and vibration so the user can train without looking.

**S1 Before you start**

- Shows: session length, the blocks in it (for example "Holds: 5 reps" and "Quick squeezes: 5 reps"), and the position for this level (lying, sitting or standing).
- Link: "Show me how" opens the tutorial.
- Button: "Start".

**S2 Countdown:** "Get ready", 5 seconds, skippable by tap.

**S3 Player**

- Ring timer fills during each phase. Colour by phase: squeeze and hold in the accent colour, relax in green, rest in grey.
- Centre: the side-view diagram, with the muscle line lifting on squeeze and lowering on relax.
- Phase word in large type: "Squeeze", "Hold", "Relax", "Rest".
- One cue line under it, rotating: "Keep breathing normally" · "Buttocks, thighs and stomach stay relaxed" · "Let go completely" · "Gentle effort is enough".
- Rep counter: "Rep 3 of 5". Strip at the bottom showing the current and next block.
- Controls: pause or resume, voice on or off, vibration on or off, exit (asks to confirm; a partial session is not counted).
- Vibration: one long pulse at squeeze, two short pulses at relax.
- Voice: a spoken "Squeeze" and "Relax" only. Off by default, for privacy.
- The screen stays awake during a session.

**S4 Session done**

- Shows: "Session complete", time, streak, what is next today.
- Pain check, one tap: "How did that feel?" Fine · Mild discomfort · Pain. "Pain" opens H3. "Mild discomfort" twice in a row suggests stepping down a level.

**Session definition** (sessions are data, so levels can be tuned without a release):

```json
{
  "id": "L1_standard",
  "level": 1,
  "position": "lying_or_sitting",
  "blocks": [
    { "type": "hold",  "reps": 5, "squeezeSec": 3, "relaxSec": 3 },
    { "type": "rest",  "sec": 10 },
    { "type": "quick", "reps": 5, "squeezeSec": 1, "relaxSec": 2 }
  ]
}
```

The player is a small state machine: idle, countdown, squeeze, relax, rest, paused, done. Each transition fires the vibration, the optional voice cue and the ring reset.

## 8. Exercises, levels and tracks

The library has 10 exercises, arranged into 5 levels and 5 tracks. The numbers below follow common patient guidance (sources in section 15). They are not a proven dose, and a pelvic floor physiotherapist must review them before launch.

**Exercise library**

| Exercise | What the user does | Type |
| --- | --- | --- |
| Slow hold | Squeeze, hold, fully release | Strength |
| Quick squeeze | Squeeze hard for 1 second, release at once | Strength |
| Strong hold | Near-maximum squeeze, held | Strength |
| Standing and walking holds | Slow holds while upright, then while walking | Function |
| Bridge with hold | Squeeze, lift hips, hold, lower and release | Function |
| Squat with coordination | Relax going down, squeeze coming up | Function |
| The Knack | Squeeze just before a cough, lift or sneeze | Function |
| Diaphragmatic breathing | Belly breath in as the pelvic floor lets go | Relaxation |
| Reverse Kegel | Gently release and lengthen instead of squeezing | Relaxation |
| Child's pose and happy baby | Held stretches, 1 to 3 minutes | Relaxation |

**Levels** (per session; sessions per day come from O5; one rest day each week)

| Level | Days | Slow holds | Quick squeezes | Position and extras |
| --- | --- | --- | --- | --- |
| 1 Start | 1 to 7 | 5 reps, 3 s hold, 3 s relax | 5 | Lying or sitting |
| 2 Build | 8 to 14 | 8 reps, 5 s hold, 5 s relax | 8 | Sitting |
| 3 Steady | 15 to 28 | 10 reps, 7 s hold, 7 s relax | 10 | Sitting and standing |
| 4 Deep | 29 to 56 | 10 reps, 8 to 10 s hold | 12 | Standing; bridge and squat added |
| 5 Maintain | 57 onward | 10 reps, 10 s hold | 15 | Any; walking holds and Knack drills |

Every day in every level ends with 2 minutes of diaphragmatic breathing.

**Level rules**

- A level unlocks when the user completes at least 5 of the last 7 days in the current one. The day ranges are the fastest possible pace.
- If the user cannot hold for the full time, the app says: "Hold as long as you can and build up."
- The user can repeat or step down a level at any time. Stepping up early is not offered.

**Tracks**

| Track | Set by | What changes |
| --- | --- | --- |
| General and bladder | Goal: bladder control or general health | Standard levels. The Knack from Level 3. |
| Erection support | Goal | Standard levels. Strong holds from Level 3. Bridge and squat in Level 4. |
| Ejaculation control | Goal | Standard levels. Reverse Kegel and extra breathing every day from Level 1. |
| After prostate surgery | Goal | Gentler holds: build to 10 seconds, relax for 4, up to 10 reps. The Knack from Level 2. Blocked while a catheter is in place. |
| Relaxation first | Pain answer at O3, or "Pain" at S4 | No strengthening. Daily breathing, reverse Kegel and stretches for 2 weeks. Then: "If the pain has settled and a clinician agrees, you can start Level 1." |

## 9. Progress, Learn and Settings

**G1 Progress**

- Streak in days, and sessions completed this week.
- Current level and days completed in it.
- Longest hold reached, in seconds. This is the one honest strength measure a phone can show.
- Month calendar with completed days marked.
- Check-in card (premium detail, free baseline).
- Gear icon opens Settings.

**G2 Check-in**

- One question, matched to the goal, on a 1 to 5 scale. Examples: bladder, "How often did you leak in the last week?"; erection support, "How would you rate erection firmness in the last week?"; ejaculation control, "How much control did you feel in the last week?"
- Offered after session 3 as a baseline, then every 4 weeks. Always skippable.
- Result is the user's own numbers side by side: "Week 0: 2 of 5. Week 4: 3 of 5." No predictions.
- Stored on the device only. Never sent to analytics.
- If a score stays at the lowest value after 8 weeks: "Exercises do not help everyone. It is worth talking to a doctor."

**L1 Learn** (8 articles, each under 150 words, each ending with its sources)

1. How the pelvic floor works
2. Finding the right muscles (the tutorial, replayable)
3. Five common mistakes
4. When to relax instead of squeeze
5. What to expect, week by week
6. Exercises after prostate surgery
7. When to see a doctor
8. Where our guidance comes from

**X1 Settings**

- Plan: goal, daily time, safety answers.
- Reminders: on or off, time, days.
- Session: voice, vibration.
- Privacy: discreet notifications (on by default), delete all my data.
- Subscription: manage in Google Play, restore purchase.
- About: medical disclaimer, Privacy Policy, Terms, contact email, version.

## 10. Free and Premium

Free is a complete, safe starting point; Premium is the long-term program. Safety and relaxation content is never locked.

| Feature | Free | Premium |
| --- | --- | --- |
| Onboarding, tutorial, Learn articles | Yes | Yes |
| Level 1, repeatable without limit | Yes | Yes |
| Relaxation-first track, daily breathing | Yes | Yes |
| Reminders, streak, calendar | Yes | Yes |
| Pain help and safety routing | Yes | Yes |
| Levels 2 to 5 | No | Yes |
| Goal-specific track content (strong holds, bridge, squat, Knack) | No | Yes |
| Check-in history and comparison | Baseline only | Yes |

**Pricing:** not set yet. Recommended structure is two plans, monthly and yearly, with a short free trial on the yearly plan, priced per country in Play Console. Decide the numbers after checking competitor prices in the launch markets (section 15, open decisions).

## 11. Notifications

Notifications are discreet by default: nothing on the lock screen says "Kegel" or names a health goal. The app sends at most 2 a day and none for marketing.

| Trigger | Discreet copy (default) | Full copy (if the user turns discreet off) |
| --- | --- | --- |
| Daily reminder at the chosen time | "Time for your 2-minute session" | "Time for your pelvic floor session" |
| Nothing done by 2 hours after the reminder, streak of 3 days or more | "Keep your streak going today" | Same |
| Level unlocked | "New level unlocked" | Same |
| 4-week check-in due | "Your 4-week check-in is ready" | Same |

Rules: no reminder after the day's sessions are done, none on a rest day except the daily reminder for breathing, and the notification channel name in system settings is "Daily reminder".

## 12. Safety rules

These eight rules are requirements, not suggestions. Each one maps to a screen above.

1. Pain at onboarding or after a session moves the user to relaxation only and shows a clinician note (O3, S4, H3).
2. No exercises while a catheter is in place (O3, H1).
3. Strengthening is capped at 3 sessions a day (H1).
4. Every level has a weekly rest day and daily relaxation breathing (section 8).
5. The "relax buttocks, thighs and stomach, keep breathing" cue appears in every session (S3).
6. Stopping urine flow is described as a one-time test, never as an exercise (T1).
7. No promise of results anywhere. Timelines say "results vary" (O6, Learn).
8. A check-in that shows no change after 8 weeks suggests seeing a doctor (G2).

The app never diagnoses. It does not label a user as having erectile dysfunction, premature ejaculation or any other condition from their answers.

## 13. Google Play checklist

Twelve items must be done before the first submission. Policies change, so re-read the [Health Content and Services policy](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en) the week you submit. This is not legal advice.

- [ ] Complete the Health apps declaration in Play Console (Policy, App content) with categories that match the app's real features
- [ ] Do not declare the app as a medical device
- [ ] Publish the privacy policy at a public web URL (not a PDF) and link it in Play Console and in Settings
- [ ] Put the disclaimer in the store description: "not a medical device and does not diagnose, treat, cure, or prevent any medical condition", plus a line to consult a healthcare professional
- [ ] Show the same disclaimer in the app (O1 and Settings)
- [ ] Fill in the Data safety form, including what each SDK collects (billing, analytics, crash reports)
- [ ] Request no health permissions and do not use Health Connect
- [ ] Answer the content rating questionnaire accurately and set the target audience to 18 and over
- [ ] Paywall shows price, billing period, trial length, what the trial converts to, and how to cancel
- [ ] Store title, short description, icon and screenshots contain no sexual keywords, no suggestive imagery and no result claims
- [ ] No endorsement logos, testimonials or statistics that are not real and documented
- [ ] If accounts are added later, add account deletion in the app and on the web first

**Store listing draft**

- Title: "\[App name\]: Pelvic Floor Trainer for Men"
- Short description: "Guided pelvic floor exercises for men. 2-minute sessions, no equipment."
- Description opening: "Short, guided pelvic floor (Kegel) sessions with a clear level plan. Built around published patient guidance, with relaxation exercises and safety checks included." Then the feature list, then the disclaimer.
- Screenshots: the player, the level plan, Today, Learn. Diagrams only.

## 14. Analytics and success measures

The north-star measure is men completing 4 or more session days a week. Analytics carries event names and plan settings only; safety answers and check-in scores never leave the device.

| Event | Fired when | Properties |
| --- | --- | --- |
| onboarding\_step | Each of O1 to O6 is completed | step |
| onboarding\_done | O6 button tapped | sessions\_per\_day, reminder\_on |
| tutorial\_done | T1 finished | felt\_lift (yes or not sure) |
| session\_start | S3 begins | level, session\_number\_today |
| session\_done | S4 shown | level, seconds |
| session\_exit | User exits mid-session | level, phase |
| paywall\_view | P1 shown | source (first\_session or locked\_content) |
| trial\_start, purchase | Play Billing confirms | plan |
| level\_up | Level unlocked | level |
| reminder\_change | Reminder toggled | on or off |

**Funnel to watch, in order:** install, onboarding done, first session done, day-2 return, day-7 return, trial or purchase, day-30 return.

No targets are set yet. Record two weeks of baseline after launch, then set a target for each step. If paywall conversion is the weak step, test a medium onboarding of 8 to 10 screens against this one before adding persuasion screens.

## 15. Build plan, open decisions and sources

The build runs in five milestones, each ending in something testable. Tick items off as they ship.

**M1 Session engine**

- [ ] Session JSON schema and the Level 1 to 5 definitions for all tracks
- [ ] Timer state machine with pause and resume
- [ ] Ring timer, phase text, cue rotation
- [ ] Vibration patterns and optional voice cues
- [ ] Side-view diagram with squeeze and relax animation

**M2 Plan and Today**

- [ ] Local storage for plan, completed sessions and settings
- [ ] Level progression rule (5 of 7 days) and step-down
- [ ] Today tab with all states, daily cap, rest day
- [ ] Levels screen
- [ ] Pain help flow and track switching

**M3 Onboarding and tutorial**

- [ ] O1 to O6 with safety routing
- [ ] Tutorial with practice reps
- [x] Reminder scheduling and discreet notifications

**M4 Progress, Learn, Settings, paywall**

- [ ] Progress tab, calendar, streak, longest hold
- [ ] Check-in flow, stored locally
- [ ] 8 Learn articles written and source-linked
- [ ] Settings, including delete all data
- [ ] Play Billing subscriptions, paywall, restore, feature gating

**M5 Launch readiness**

- [ ] Physiotherapist review of levels, tracks and all exercise copy
- [ ] Analytics events, verified to exclude sensitive answers
- [ ] Privacy policy and terms published
- [ ] Section 13 checklist complete
- [ ] Closed test with at least 10 users, then production release

**Open decisions**

- App name and visual identity.
- Prices and trial length per market.
- Which pelvic floor physiotherapist reviews the content, and whether they can be named in the app.
- Android only at launch, or iOS at the same time.
- Whether check-in questions use a validated questionnaire. Licensing for those has not been checked.

**Sources**

- [Advanced Urology: pelvic floor therapy for men](https://learn.advancedurology.com/education/pelvic-floor-therapy-men) (exercise types, hold times, relaxation exercises, 6 to 12 week timeline)
- [NHS Fife: pelvic floor exercises before and after prostate surgery](https://www.nhsfife.org/media/na0bpxi5/pelvic-floor-exercises-befor-and-after-surgery-to-remove-the-prostate.pdf) (post-surgery dosing, catheter rule, over-exercise warning)
- [Herman and Wallace: pelvic floor exercises for male sexual dysfunction](https://hermanwallace.com/blog/treating-male-sexual-dysfunction-with-pelvic-floor-muscle-exercises) (summary of the 2019 systematic review)
- [Myers and Smith 2019, Physiotherapy](https://pubmed.ncbi.nlm.nih.gov/30979506/) (the systematic review)
- [Physiotutors: reverse Kegels](https://www.physiotutors.com/reverse-kegels/) (when squeezing makes symptoms worse)
- [Google Play: Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en)
- [Google Play: Inappropriate Content](https://support.google.com/googleplay/android-developer/answer/9878810?hl=en-GB)
- [Google Play: Misleading Claims](https://support.google.com/googleplay/android-developer/answer/16680223?hl=en)
- [Google Play: account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en-GB)
- [Android Developers Blog: subscription disclosure](https://android-developers.googleblog.com/2020/04/building-user-trust-through-more.html)
