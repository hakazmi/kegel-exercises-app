import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import 'crash_reporting.dart';

/// Updates Crashlytics `screen` key when the go_router location changes.
class DiagnosticsRouterBinder extends ConsumerStatefulWidget {
  const DiagnosticsRouterBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DiagnosticsRouterBinder> createState() =>
      _DiagnosticsRouterBinderState();
}

class _DiagnosticsRouterBinderState
    extends ConsumerState<DiagnosticsRouterBinder> {
  GoRouter? _router;
  String? _lastPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GoRouter router = ref.read(routerProvider);
    if (!identical(_router, router)) {
      _router?.routerDelegate.removeListener(_onRoute);
      _router = router;
      _router!.routerDelegate.addListener(_onRoute);
      _onRoute();
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRoute);
    super.dispose();
  }

  void _onRoute() {
    final GoRouter? router = _router;
    if (router == null) {
      return;
    }
    // Before the first parse, currentConfiguration is empty and
    // GoRouter.state throws StateError ("Bad state: No element").
    final RouteMatchList matches = router.routerDelegate.currentConfiguration;
    if (matches.isEmpty) {
      return;
    }
    final String path = matches.uri.path;
    if (path.isEmpty || path == _lastPath) {
      return;
    }
    _lastPath = path;
    CrashReporting.setKey('screen', path);
    CrashReporting.log('screen: $path');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
