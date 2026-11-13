import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/services/haptics_service.dart';
import '../../core/time/app_clock.dart';
import '../../core/widgets/secondary_button.dart';

/// Debug screen: profile, today's plan, last 10 sessions, haptics, day tools.
class DataDebugScreen extends ConsumerStatefulWidget {
  const DataDebugScreen({super.key});

  @override
  ConsumerState<DataDebugScreen> createState() => _DataDebugScreenState();
}

class _DataDebugScreenState extends ConsumerState<DataDebugScreen> {
  String _hapticsLog = 'Tap Test vibration to run patterns and probe.';
  bool _testing = false;
  String _toolsLog = '';
  int _sampleDays = 7;

  Future<void> _testVibration() async {
    setState(() => _testing = true);
    final HapticsService haptics = ref.read(hapticsServiceProvider);
    final HapticsCapabilities caps = await haptics.probe();
    final StringBuffer buf = StringBuffer()
      ..writeln('hasVibrator: ${caps.hasVibrator}')
      ..writeln(
        'hasCustomVibrationsSupport: ${caps.hasCustomVibrationsSupport}',
      )
      ..writeln('Playing heavy (squeeze)…');
    setState(() => _hapticsLog = buf.toString());
    await haptics.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    buf.writeln('Playing medium (relax)…');
    setState(() => _hapticsLog = buf.toString());
    await haptics.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    buf.writeln('Playing vibrate (session end)…');
    setState(() => _hapticsLog = buf.toString());
    await haptics.vibrate();
    buf.writeln('Done.');
    if (!mounted) {
      return;
    }
    setState(() {
      _hapticsLog = buf.toString();
      _testing = false;
    });
  }

  void _shiftDay(int delta) {
    ref.read(debugDayOffsetProvider.notifier).shift(delta);
    ref.invalidate(todayPlanProvider);
    ref.invalidate(sessionsProvider);
    final DateTime now = ref.read(appClockProvider).now();
    setState(() {
      _toolsLog =
          'App today → ${dateOnly(now).toIso8601String().substring(0, 10)} '
          '(offset ${ref.read(debugDayOffsetProvider)}d)';
    });
  }

  Future<void> _completeTodayItems() async {
    final UserProfile profile = ref.read(userProfileProvider);
    final TodayPlan plan = await ref.read(todayPlanProvider.future);
    final DateTime now = ref.read(appClockProvider).now();
    final int day = PlanRules.dayInLevel(
      profile: profile,
      sessions: await ref.read(sessionsProvider.future),
    );
    for (final TodayItem item in plan.items) {
      if (item.done) {
        continue;
      }
      await ref.read(sessionRepositoryProvider).insert(
            SessionRecord(
              startedAt: now,
              completedAt: now,
              level: profile.level,
              dayInLevel: day,
              track: profile.track,
              kind: item.kind,
              durationSeconds: item.durationSeconds,
              longestHoldSeconds: 0,
              completed: true,
              feel: SessionFeel.fine,
            ),
          );
    }
    ref.invalidate(sessionsProvider);
    ref.invalidate(todayPlanProvider);
    setState(() => _toolsLog = "Completed today's undone items.");
  }

  Future<void> _resetToday() async {
    final DateTime now = ref.read(appClockProvider).now();
    final int removed =
        await ref.read(sessionRepositoryProvider).deleteOnDay(now);
    ref.invalidate(sessionsProvider);
    ref.invalidate(todayPlanProvider);
    setState(() => _toolsLog = 'Reset today ($removed sessions removed).');
  }

  Future<void> _setSafety({bool? pain, bool? catheter}) async {
    final UserProfile profile = ref.read(userProfileProvider);
    await ref.read(userProfileProvider.notifier).save(
          profile.copyWith(
            safetyFlags: profile.safetyFlags.copyWith(
              pain: pain,
              catheter: catheter,
            ),
            track: pain == true
                ? TrackId.relaxationFirst
                : profile.track,
          ),
        );
    ref.invalidate(todayPlanProvider);
    setState(() => _toolsLog = 'Safety flags updated.');
  }

  Future<void> _addSampleSessions() async {
    final UserProfile profile = ref.read(userProfileProvider);
    final DateTime today = dateOnly(ref.read(appClockProvider).now());
    final bool relaxation = profile.track == TrackId.relaxationFirst;
    int added = 0;
    for (int i = _sampleDays - 1; i >= 0; i--) {
      final DateTime day = today.subtract(Duration(days: i));
      if (PlanRules.isConfiguredRestWeekday(day, profile.restWeekday) &&
          !relaxation) {
        continue;
      }
      if (relaxation) {
        await ref.read(sessionRepositoryProvider).insert(
              SessionRecord(
                startedAt: day.add(const Duration(hours: 9)),
                completedAt: day.add(const Duration(hours: 9, minutes: 2)),
                level: profile.level,
                dayInLevel: 1,
                track: profile.track,
                kind: SessionKind.breathing,
                durationSeconds: 120,
                longestHoldSeconds: 0,
                completed: true,
              ),
            );
        added += 1;
      } else {
        await ref.read(sessionRepositoryProvider).insert(
              SessionRecord(
                startedAt: day.add(const Duration(hours: 9)),
                completedAt: day.add(const Duration(hours: 9, minutes: 1)),
                level: profile.level,
                dayInLevel: 1,
                track: profile.track,
                kind: SessionKind.strengthening,
                durationSeconds: 55,
                longestHoldSeconds: 3 + (i % 3),
                completed: true,
                feel: SessionFeel.fine,
              ),
            );
        added += 1;
      }
    }
    ref.invalidate(sessionsProvider);
    ref.invalidate(todayPlanProvider);
    setState(() => _toolsLog = 'Added $added sample sessions over $_sampleDays days.');
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile profile = ref.watch(userProfileProvider);
    final AsyncValue<TodayPlan> plan = ref.watch(todayPlanProvider);
    final AsyncValue<List<SessionRecord>> latest =
        ref.watch(latestSessionsProvider(10));
    final bool premium = ref.watch(isPremiumOverrideProvider);
    final DateTime appNow = ref.watch(appClockProvider).now();

    return Scaffold(
      appBar: AppBar(title: const Text('Data debug')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Text('Day tools', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'App today: ${dateOnly(appNow).toIso8601String().substring(0, 10)}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              SecondaryButton(
                label: 'Day −1',
                expand: false,
                onPressed: () => _shiftDay(-1),
              ),
              SecondaryButton(
                label: 'Day +1',
                expand: false,
                onPressed: () => _shiftDay(1),
              ),
              SecondaryButton(
                label: "Complete today's items",
                expand: false,
                onPressed: _completeTodayItems,
              ),
              SecondaryButton(
                label: 'Reset today',
                expand: false,
                onPressed: _resetToday,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Sample sessions', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Last $_sampleDays days',
                  style: AppTypography.body,
                ),
              ),
              IconButton(
                onPressed: _sampleDays > 1
                    ? () => setState(() => _sampleDays -= 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                onPressed: _sampleDays < 56
                    ? () => setState(() => _sampleDays += 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          SecondaryButton(
            label: 'Add sample sessions',
            onPressed: _addSampleSessions,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            title: const Text('Premium'),
            value: premium,
            onChanged: (bool value) {
              ref.read(isPremiumOverrideProvider.notifier).set(value);
              setState(() => _toolsLog = 'Premium → $value');
            },
          ),
          SwitchListTile(
            title: const Text('Pain flag'),
            value: profile.safetyFlags.pain,
            onChanged: (bool value) => _setSafety(pain: value),
          ),
          SwitchListTile(
            title: const Text('Catheter flag'),
            value: profile.safetyFlags.catheter,
            onChanged: (bool value) => _setSafety(catheter: value),
          ),
          if (_toolsLog.isNotEmpty)
            Text(
              _toolsLog,
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
            ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Haptics', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(
            label: _testing ? 'Testing…' : 'Test vibration',
            onPressed: _testing ? null : _testVibration,
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
            _hapticsLog,
            style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Profile', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            profile.toJson().toString(),
            style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text("Today's plan", style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          plan.when(
            data: (TodayPlan value) => SelectableText(
              'state=${value.state.name} level=${value.level} '
              'day=${value.dayInLevel} track=${value.track.name}\n'
              '${value.items.map((TodayItem i) => '${i.id}: done=${i.done} optional=${i.optional}').join('\n')}',
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
            ),
            loading: () => const Text('Loading plan…'),
            error: (Object e, StackTrace st) => Text('Plan error: $e'),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Last 10 sessions', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          latest.when(
            data: (List<SessionRecord> rows) {
              if (rows.isEmpty) {
                return const Text('No sessions yet.');
              }
              return SelectableText(
                rows
                    .map(
                      (SessionRecord s) =>
                          '#${s.id} ${s.kind.name} L${s.level}d${s.dayInLevel} '
                          'completed=${s.completed} feel=${s.feel?.name} '
                          '${s.startedAt.toIso8601String()}',
                    )
                    .join('\n'),
                style:
                    AppTypography.caption.copyWith(color: AppColors.textPrimary),
              );
            },
            loading: () => const Text('Loading sessions…'),
            error: (Object e, StackTrace st) => Text('Sessions error: $e'),
          ),
        ],
      ),
    );
  }
}
