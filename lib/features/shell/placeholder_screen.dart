import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

/// A flow link shown on a [PlaceholderScreen].
class RouteLink {
  const RouteLink(this.path, this.label);

  final String path;
  final String label;
}

/// Temporary screen that shows a route id and forwards to the next flow steps.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.id,
    required this.name,
    this.nextRoutes = const <RouteLink>[],
    this.useSessionTheme = false,
    this.showBottomGap = false,
  });

  final String id;
  final String name;
  final List<RouteLink> nextRoutes;
  final bool useSessionTheme;
  final bool showBottomGap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme =
        useSessionTheme ? AppTheme.session() : Theme.of(context);

    final Widget scaffold = Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.placeholderScreen(id, name)),
            ),
            body: SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  showBottomGap ? AppSpacing.xxl * 2 : AppSpacing.xl,
                ),
                children: [
                  Text(id, style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.placeholderHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  for (int i = 0; i < nextRoutes.length; i++) ...[
                    if (i == 0)
                      PrimaryButton(
                        label: nextRoutes[i].label,
                        onPressed: () => context.go(nextRoutes[i].path),
                      )
                    else
                      SecondaryButton(
                        label: nextRoutes[i].label,
                        onPressed: () => context.push(nextRoutes[i].path),
                      ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );

    if (!useSessionTheme) {
      return scaffold;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
      ),
      child: scaffold,
    );
  }
}
