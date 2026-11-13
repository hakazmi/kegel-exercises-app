import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/illustration.dart';

/// Side-view pelvic floor diagram with overlaid labels (SVG has no text).
///
/// Labels are positioned in the native 260×180 viewBox so they clear the
/// figure lines at the real rendered aspect ratio.
class AnatomyDiagram extends StatelessWidget {
  const AnatomyDiagram({super.key});

  static const double viewBoxWidth = 260;
  static const double viewBoxHeight = 180;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.t1AnatomySemantic,
      image: true,
      child: AspectRatio(
        aspectRatio: viewBoxWidth / viewBoxHeight,
        child: ClipRRect(
          borderRadius: AppRadii.xlAll,
          child: ColoredBox(
            color: AppColors.mint,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double w = constraints.maxWidth;
                final double h = constraints.maxHeight;

                TextStyle labelStyle({
                  required double size,
                  required FontWeight weight,
                  required Color color,
                }) {
                  return TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: size,
                    fontWeight: weight,
                    color: color,
                    height: 1.1,
                  );
                }

                /// Centres [child] on viewBox point ([x], [y]).
                Widget centeredAt(double x, double y, Widget child) {
                  return Positioned(
                    left: (x / viewBoxWidth) * w,
                    top: (y / viewBoxHeight) * h,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, -0.5),
                      child: child,
                    ),
                  );
                }

                /// Places [child] with its left edge at [x] and baseline at [y].
                Widget baselineAt(double x, double y, Widget child) {
                  return Positioned(
                    left: (x / viewBoxWidth) * w,
                    top: (y / viewBoxHeight) * h,
                    child: FractionalTranslation(
                      translation: const Offset(0, -1),
                      child: child,
                    ),
                  );
                }

                /// Places [child] with its right edge at [x] and baseline at [y].
                Widget rightBaselineAt(double x, double y, Widget child) {
                  return Positioned(
                    left: (x / viewBoxWidth) * w,
                    top: (y / viewBoxHeight) * h,
                    child: FractionalTranslation(
                      translation: const Offset(-1, -1),
                      child: child,
                    ),
                  );
                }

                /// Centres horizontally on [x], baseline at [y].
                Widget centeredBaselineAt(double x, double y, Widget child) {
                  return Positioned(
                    left: (x / viewBoxWidth) * w,
                    top: (y / viewBoxHeight) * h,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, -1),
                      child: child,
                    ),
                  );
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ExcludeSemantics(
                      child: Illustration(
                        assetPath: 'assets/images/anatomy_side.svg',
                        semanticLabel: l10n.t1AnatomySemantic,
                        fit: BoxFit.contain,
                      ),
                    ),
                    ExcludeSemantics(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          centeredAt(
                            104,
                            75,
                            Text(
                              l10n.t1AnatomyBladder,
                              style: labelStyle(
                                size: 12,
                                weight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          baselineAt(
                            14,
                            152,
                            Text(
                              l10n.t1AnatomyPubicBone,
                              style: labelStyle(
                                size: 12,
                                weight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          // Right-aligned to mirror Pubic bone's left inset (14).
                          rightBaselineAt(
                            246,
                            150,
                            Text(
                              l10n.t1AnatomyTailbone,
                              style: labelStyle(
                                size: 12,
                                weight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          centeredBaselineAt(
                            124,
                            170,
                            Text(
                              l10n.t1AnatomyPelvicFloor,
                              style: labelStyle(
                                size: 13,
                                weight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
