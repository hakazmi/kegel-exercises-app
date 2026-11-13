import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_models.dart';
import '../../core/services/haptics_service.dart';
import '../../core/widgets/secondary_button.dart';

/// Debug screen: profile, today's plan, last 10 sessions, haptics probe.
class DataDebugScreen extends ConsumerStatefulWidget {
  const DataDebugScreen({super.key});

  @override
  ConsumerState<DataDebugScreen> createState() => _DataDebugScreenState();
}

class _DataDebugScreenState extends ConsumerState<DataDebugScreen> {
  String _hapticsLog = 'Tap Test vibration to run patterns and probe.';
  bool _testing = false;

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

  @override
  Widget build(BuildContext context) {
    final UserProfile profile = ref.watch(userProfileProvider);
    final AsyncValue<TodayPlan> plan = ref.watch(todayPlanProvider);
    final AsyncValue<List<SessionRecord>> latest =
        ref.watch(latestSessionsProvider(10));

    return Scaffold(
      appBar: AppBar(title: const Text('Data debug')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
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
