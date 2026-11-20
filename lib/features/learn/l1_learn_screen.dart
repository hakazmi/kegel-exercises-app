import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/data/providers.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';

/// Fixed thumbnail slot so every Learn row title shares the same left edge.
const Size _kLearnThumbSlot = Size(56, 56);

/// L1 Learn — featured tutorial card and article list with thumbnails.
class L1LearnScreen extends ConsumerWidget {
  const L1LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<ArticleContent>> articlesAsync =
        ref.watch(articlesProvider);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: articlesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace st) => Center(child: Text('$e')),
          data: (List<ArticleContent> articles) {
            ArticleContent? featured;
            final List<ArticleContent> list = <ArticleContent>[];
            for (final ArticleContent article in articles) {
              if (article.featured && featured == null) {
                featured = article;
              } else {
                list.add(article);
              }
            }
            // Keep all eight reachable: if featured was also needed in the list
            // we still show the other seven; featured opens tutorial or article.
            return ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                bottomInset + AppSpacing.xxl,
              ),
              children: [
                Text(l10n.tabLearn, style: AppTypography.display),
                const SizedBox(height: AppSpacing.lg),
                if (featured != null) ...[
                  Reveal(
                    from: RevealFrom.drop,
                    child: _FeaturedCard(
                      l10n: l10n,
                      article: featured,
                      onTap: () => _open(context, featured!),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                Text(l10n.l1ArticlesHeading, style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                for (int i = 0; i < list.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  Reveal(
                    from: i.isEven ? RevealFrom.left : RevealFrom.right,
                    delay: AppMotion.stagger(
                      i,
                      base: const Duration(milliseconds: 120),
                    ),
                    child: _ArticleRow(
                      l10n: l10n,
                      tint: _tints[i % _tints.length],
                      article: list[i],
                      onTap: () => _open(context, list[i]),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Pastel tile colours, cycled down the list.
  static const List<Color> _tints = <Color>[
    AppColors.lavender,
    AppColors.peach,
    AppColors.sky,
    AppColors.blush,
    AppColors.pistachio,
  ];

  void _open(BuildContext context, ArticleContent article) {
    if (article.opensTutorial) {
      context.push('${AppRoutes.tutorial}?replay=1');
      return;
    }
    context.push('${AppRoutes.article}?id=${Uri.encodeComponent(article.id)}');
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.l10n,
    required this.article,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final ArticleContent article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lavender,
      borderRadius: AppRadii.xlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.lgAll,
                ),
                child: _LearnThumbnail(
                  assetPath: article.image,
                  semanticLabel: article.title,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.l1StartHere(article.minutes).toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      article.title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.l1ReplayTutorial,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({
    required this.l10n,
    required this.article,
    required this.tint,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final ArticleContent article;

  /// Pastel colour behind the article's picture.
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.xlAll,
          boxShadow: AppElevation.level1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: AppRadii.lgAll,
              ),
              child: _LearnThumbnail(
                assetPath: article.image,
                semanticLabel: article.title,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.l1Minutes(article.minutes),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: AppSpacing.xxs),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnThumbnail extends StatelessWidget {
  const _LearnThumbnail({
    required this.assetPath,
    required this.semanticLabel,
  });

  final String assetPath;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kLearnThumbSlot.width,
      height: _kLearnThumbSlot.height,
      child: Center(
        child: Illustration(
          assetPath: assetPath,
          semanticLabel: semanticLabel,
          width: _kLearnThumbSlot.width,
          height: _kLearnThumbSlot.height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
