import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import 'engine/engine_models.dart';
import 'session_controller.dart';
import 'session_exit.dart';

/// S2 Countdown — "Get ready", 5 seconds, tap to skip.
class S2CountdownScreen extends ConsumerStatefulWidget {
  const S2CountdownScreen({
    super.key,
    this.itemId,
  });

  final String? itemId;

  @override
  ConsumerState<S2CountdownScreen> createState() => _S2CountdownScreenState();
}

class _S2CountdownScreenState extends ConsumerState<S2CountdownScreen> {
  bool _started = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureStarted());
  }

  Future<void> _ensureStarted() async {
    if (_started) {
      return;
    }
    _started = true;
    final String itemId = widget.itemId ?? 'strength_1';
    final SessionPlayState? existing = ref.read(sessionControllerProvider);
    if (existing == null || existing.itemId != itemId) {
      await ref.read(sessionControllerProvider.notifier).begin(itemId);
    }
  }

  void _goPlayer() {
    if (_navigating || !mounted) {
      return;
    }
    _navigating = true;
    context.go(
      '${AppRoutes.player}?itemId=${Uri.encodeComponent(widget.itemId ?? 'strength_1')}',
    );
  }

  void _onSkip() {
    ref.read(sessionControllerProvider.notifier).skipCountdown();
    _goPlayer();
  }

  Future<void> _onSystemBack() async {
    if (_navigating) {
      return;
    }
    final bool ok = await confirmSessionExit(context);
    if (!ok || !mounted) {
      return;
    }
    _navigating = true;
    await ref.read(sessionControllerProvider.notifier).exitSession();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    ref.listen<SessionPlayState?>(sessionControllerProvider,
        (SessionPlayState? prev, SessionPlayState? next) {
      if (next == null || _navigating) {
        return;
      }
      final EngineMachineState m = next.engineState.machine;
      if (m != EngineMachineState.countdown &&
          m != EngineMachineState.idle &&
          !next.engineState.exited) {
        _goPlayer();
      }
    });

    final SessionPlayState? play = ref.watch(sessionControllerProvider);
    final int seconds = play?.engineState.machine == EngineMachineState.countdown
        ? play!.engineState.secondsRemaining
        : 5;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _onSystemBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.darkScreen,
        child: Scaffold(
          backgroundColor: AppColors.sessionBackground,
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onSkip,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.s2GetReady,
                      style: AppTypography.display.copyWith(
                        color: AppColors.sessionText,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      '$seconds',
                      style: AppTypography.display.copyWith(
                        color: AppColors.accent,
                        fontSize: 72,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.s2TapToSkip,
                      style: AppTypography.body.copyWith(
                        color: AppColors.sessionTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
