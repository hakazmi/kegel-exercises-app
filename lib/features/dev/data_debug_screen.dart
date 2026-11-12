import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_models.dart';

/// Debug screen: profile, today's plan, last 10 sessions.
class DataDebugScreen extends ConsumerWidget {
  const DataDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserProfile profile = ref.watch(userProfileProvider);
    final AsyncValue<TodayPlan> plan = ref.watch(todayPlanProvider);
    final AsyncValue<List<SessionRecord>> latest =
        ref.watch(latestSessionsProvider(10));

    return Scaffold(
      appBar: AppBar(title: const Text('Data debug')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
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
