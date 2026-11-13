import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/data/providers.dart';
import '../../core/widgets/widgets.dart';
import 'simple_markdown.dart';

/// L2 Article — Markdown body from assets plus a Sources list.
class L2ArticleScreen extends ConsumerWidget {
  const L2ArticleScreen({super.key, required this.articleId});

  final String articleId;

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ArticleContent?> articleAsync =
        ref.watch(_articleBodyProvider(articleId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.commonBack,
          onPressed: () => context.pop(),
        ),
      ),
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace st) => Center(child: Text('$e')),
        data: (ArticleContent? article) {
          if (article == null) {
            return Center(child: Text(l10n.l2NotFound));
          }
          final double bottomInset = MediaQuery.paddingOf(context).bottom;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              bottomInset + AppSpacing.xxl,
            ),
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: AppRadii.xlAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Illustration(
                      assetPath: article.image,
                      semanticLabel: article.title,
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.l2MinutesRead(article.minutes).toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(article.title, style: AppTypography.display),
              const SizedBox(height: AppSpacing.lg),
              SimpleMarkdown(source: article.bodyMarkdown),
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.l2Sources,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final ArticleSource source in article.sources) ...[
                InkWell(
                  onTap: () => _openUrl(source.url),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Text(
                      source.title,
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

final _articleBodyProvider =
    FutureProvider.family<ArticleContent?, String>((Ref ref, String id) {
  return ref.watch(contentRepositoryProvider).loadArticleById(id);
});
