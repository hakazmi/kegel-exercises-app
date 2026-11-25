import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/content/exercise_media.dart';
import '../../core/content/info_copy.dart';
import '../../core/data/providers.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';

/// Instruction screen for one exercise (like the pose-correction app's
/// exercise page): the demo video of the body, for squeeze exercises the
/// 3D "what happens inside" animation, the position and dose, numbered
/// steps and why it helps.
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<ExerciseContent> all =
        ref.watch(exercisesProvider).asData?.value ?? const <ExerciseContent>[];
    ExerciseContent? ex;
    for (final ExerciseContent e in all) {
      if (e.id == exerciseId) {
        ex = e;
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightScreen,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ex == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _Body(l10n: l10n, ex: ex),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.l10n, required this.ex});

  final AppLocalizations l10n;
  final ExerciseContent ex;

  String _position(String p) => switch (p) {
    'lying' => l10n.poseLyingOnBack,
    'sitting' => l10n.poseSitting,
    'standing' => l10n.poseStanding,
    'kneeling' => l10n.poseKneeling,
    _ => l10n.exdAnyPosition,
  };

  @override
  Widget build(BuildContext context) {
    final InfoContent info = InfoCopy.exercise(l10n, ex);
    final String? video = ExerciseMedia.video(ex.id);
    final String? poster = ExerciseMedia.poster(ex.id);
    final bool squeeze = ExerciseMedia.squeezeExercises.contains(ex.id);
    // Long holds (stretches, breathing) are shown in minutes.
    final bool timed = ex.holdSec >= 60;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              PressScale(
                onTap: () => context.pop(),
                semanticLabel: l10n.commonBack,
                child: Container(
                  width: AppSpacing.minTouchTarget,
                  height: AppSpacing.minTouchTarget,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppElevation.level1,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  ex.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.minTouchTarget),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              if (video != null && poster != null)
                Reveal(
                  from: RevealFrom.drop,
                  child: Stack(
                    children: [
                      ExerciseVideo(
                        asset: video,
                        poster: poster,
                        semanticLabel: ex.name,
                      ),
                      if (squeeze)
                        Positioned(
                          left: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: _Tag(
                            icon: Icons.accessibility_new_rounded,
                            text: l10n.exdBodyTag,
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Reveal(
                from: RevealFrom.left,
                delay: const Duration(milliseconds: 80),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final String p in ex.positions)
                      _Chip(
                        icon: Icons.accessibility_new_rounded,
                        text: _position(p),
                        bg: AppColors.goalBladderBg,
                        fg: AppColors.goalBladderFg,
                      ),
                    if (timed)
                      _Chip(
                        icon: Icons.schedule_rounded,
                        text: l10n.exdMinutes((ex.holdSec / 60).round()),
                        bg: AppColors.mint,
                        fg: AppColors.primary,
                      )
                    else ...[
                      if (ex.defaultReps > 1)
                        _Chip(
                          icon: Icons.repeat_rounded,
                          text: l10n.exdReps(ex.defaultReps),
                          bg: AppColors.mint,
                          fg: AppColors.primary,
                        ),
                      if (ex.holdSec > 1)
                        _Chip(
                          icon: Icons.timer_outlined,
                          text: l10n.exdHoldSec(ex.holdSec),
                          bg: AppColors.streakBg,
                          fg: AppColors.streakFg,
                        ),
                    ],
                  ],
                ),
              ),
              if (squeeze) ...[
                const SizedBox(height: AppSpacing.lg),
                Reveal(
                  from: RevealFrom.rise,
                  delay: const Duration(milliseconds: 120),
                  child: _Card(
                    icon: Icons.visibility_rounded,
                    title: l10n.exdInsideTitle,
                    tint: AppColors.blush,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.exdInsideHint, style: AppTypography.body),
                        const SizedBox(height: AppSpacing.sm),
                        // The same squeeze, seen from inside: lift, hold
                        // for this exercise's hold time, let go.
                        PelvicFloorDemoLoop(
                          height: 220,
                          squeeze: const Duration(milliseconds: 1200),
                          hold: Duration(
                            milliseconds: (ex.holdSec.clamp(0, 8) * 1000).clamp(
                              400,
                              8000,
                            ),
                          ),
                          relax: const Duration(milliseconds: 2200),
                          rest: const Duration(milliseconds: 1000),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Reveal(
                from: RevealFrom.rise,
                delay: const Duration(milliseconds: 160),
                child: _Card(
                  icon: Icons.format_list_numbered_rounded,
                  title: l10n.exdHowTo,
                  tint: AppColors.lavender,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.body, style: AppTypography.body),
                      if (info.points.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        for (int i = 0; i < info.points.length; i++)
                          _Step(number: i + 1, text: info.points[i]),
                      ],
                    ],
                  ),
                ),
              ),
              if (info.note != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Reveal(
                  from: RevealFrom.rise,
                  delay: const Duration(milliseconds: 200),
                  child: _Card(
                    icon: Icons.lightbulb_rounded,
                    title: l10n.exdWhy,
                    tint: AppColors.pistachio,
                    child: Text(info.note!, style: AppTypography.body),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: PrimaryButton(
            label: l10n.exdGotIt,
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: AppRadii.pillAll,
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.ink),
          const SizedBox(width: 4),
          Text(
            text.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.title,
    required this.tint,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Icon(icon, size: 19, color: AppColors.ink),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
