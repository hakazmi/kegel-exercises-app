import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/cloud/account_binder.dart';
import '../../core/cloud/auth_repository.dart';
import '../../core/cloud/cloud_config.dart';
import '../../core/cloud/cloud_providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/links.dart';
import '../../core/data/providers.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';

/// Required account gate: Sign in | Create account + Continue with Google.
///
/// Layout mirrors FocusFlow (hero + overlapping form sheet + ime padding so
/// fields and CTA stay above the keyboard) and PoseCoach (compact hero when
/// the keyboard is open).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late AuthMode _mode = widget.initialMode;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();
  final GlobalKey _ctaKey = GlobalKey();

  bool _obscure = true;
  bool _termsAccepted = false;
  bool _busy = false;
  bool _online = true;
  String? _error;
  bool _checkEmail = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    unawaited(_probeConnectivity());
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final bool online = results.any(
          (ConnectivityResult r) => r != ConnectivityResult.none,
        );
        if (mounted) {
          setState(() => _online = online);
        }
      },
      onError: (Object _) {},
      cancelOnError: true,
    );
    for (final FocusNode node in <FocusNode>[
      _nameFocus,
      _emailFocus,
      _passwordFocus,
    ]) {
      node.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (!(_nameFocus.hasFocus ||
        _emailFocus.hasFocus ||
        _passwordFocus.hasFocus)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _ensureFocusedVisible();
    });
  }

  Future<void> _ensureFocusedVisible() async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) {
      return;
    }
    final BuildContext? fieldCtx = _nameFocus.hasFocus
        ? _nameKey.currentContext
        : _emailFocus.hasFocus
        ? _emailKey.currentContext
        : _passwordFocus.hasFocus
        ? _passwordKey.currentContext
        : null;
    // Only scroll as far as needed: bring the button into view above the
    // keyboard, then make sure the focused field is not pushed off the top.
    final BuildContext? ctaCtx = _ctaKey.currentContext;
    if (ctaCtx != null) {
      await Scrollable.ensureVisible(
        ctaCtx,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    }
    if (fieldCtx != null && mounted) {
      await Scrollable.ensureVisible(
        fieldCtx,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  Future<void> _probeConnectivity() async {
    try {
      final List<ConnectivityResult> results = await Connectivity()
          .checkConnectivity();
      if (!mounted) {
        return;
      }
      setState(() {
        _online = results.any(
          (ConnectivityResult r) => r != ConnectivityResult.none,
        );
      });
    } on Object {
      // Assume online if probe fails (widget tests).
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    for (final FocusNode node in <FocusNode>[
      _nameFocus,
      _emailFocus,
      _passwordFocus,
    ]) {
      node.removeListener(_onFocusChange);
      node.dispose();
    }
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _busy = true;
    });
    final AuthRepository auth = ref.read(authRepositoryProvider);
    final AuthResult result = _mode == AuthMode.signIn
        ? await auth.signInWithEmail(
            email: _email.text,
            password: _password.text,
          )
        : await auth.signUpWithEmail(
            email: _email.text,
            password: _password.text,
            name: _name.text,
          );
    if (!mounted) {
      return;
    }
    if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      setState(() {
        _busy = false;
        _error = result.errorMessage;
        if (result.errorMessage!.contains('already exists')) {
          _mode = AuthMode.signIn;
        }
      });
      return;
    }
    if (result.needsEmailConfirmation) {
      setState(() {
        _busy = false;
        _checkEmail = true;
      });
      return;
    }
    if (result.session != null) {
      if (_mode == AuthMode.signUp && _name.text.trim().isNotEmpty) {
        await ref
            .read(syncMetadataStoreProvider)
            .setDisplayName(_name.text.trim());
      }
      await _afterSignedIn();
      return;
    }
    setState(() => _busy = false);
  }

  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _busy = true;
    });
    final AuthResult result = await ref
        .read(authRepositoryProvider)
        .signInWithGoogle();
    if (!mounted) {
      return;
    }
    if (result.cancelled) {
      setState(() => _busy = false);
      return;
    }
    if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      setState(() {
        _busy = false;
        _error = result.errorMessage;
      });
      return;
    }
    if (result.session != null) {
      await _afterSignedIn();
      return;
    }
    setState(() => _busy = false);
  }

  Future<void> _afterSignedIn() async {
    setState(() => _busy = true);
    final AuthRepository auth = ref.read(authRepositoryProvider);
    final String userId = auth.currentUser!.id;
    final String? email = auth.currentUser?.email;
    final AccountBinder binder = ref.read(accountBinderProvider);
    AccountBindResult bind = await binder.onSignedIn(
      userId: userId,
      email: email,
    );

    if (bind.action == AccountBindAction.askReplace && mounted) {
      final bool? replace = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Replace data on this phone?'),
            content: Text(
              'This phone has another account’s data. Replace it with '
              '${email ?? 'this account'}’s backup?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep local'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Replace'),
              ),
            ],
          );
        },
      );
      if (replace == true) {
        bind = await binder.replaceWithAccount(userId: userId, email: email);
      } else if (replace == false) {
        bind = await binder.keepLocalAndBind(userId: userId, email: email);
      } else {
        await auth.signOut();
        if (mounted) {
          setState(() => _busy = false);
        }
        return;
      }
    }

    await ref.read(userProfileProvider.notifier).reload();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (bind.action == AccountBindAction.goMain) {
      context.go(AppRoutes.today);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  Future<void> _forgotPassword() async {
    final String email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email first.');
      return;
    }
    setState(() => _busy = true);
    await ref.read(authRepositoryProvider).resetPassword(email);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists for that email, you’ll get a reset link.',
        ),
      ),
    );
  }

  Future<void> _openLegal(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? helper,
    Widget? suffix,
    IconData? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      filled: true,
      fillColor: AppColors.surfaceMuted,
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, color: AppColors.textSecondary, size: 22),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: Color(0xFFB42318)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool configured = CloudConfig.isConfigured;
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bool compact = keyboard > 0;
    final Size size = MediaQuery.sizeOf(context);
    final bool short = size.height < 760;

    final bool canSubmit =
        !_busy &&
        _online &&
        configured &&
        _email.text.trim().isNotEmpty &&
        _password.text.length >= (_mode == AuthMode.signUp ? 8 : 1) &&
        (_mode == AuthMode.signIn ||
            (_termsAccepted && _name.text.trim().isNotEmpty));

    if (_checkEmail) {
      return _CheckEmailPage(
        email: _email.text.trim(),
        busy: _busy,
        onBack: () => setState(() {
          _checkEmail = false;
          _mode = AuthMode.signIn;
        }),
        onResend: () async {
          setState(() => _busy = true);
          await ref
              .read(authRepositoryProvider)
              .resendConfirmation(_email.text);
          if (mounted) {
            setState(() => _busy = false);
          }
        },
      );
    }

    final double navBar = MediaQuery.paddingOf(context).bottom;
    final Widget sheet = Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        compact ? AppSpacing.md : AppSpacing.lg,
        AppSpacing.xl,
        compact ? AppSpacing.md : AppSpacing.md + navBar,
      ),
      child: _buildForm(configured: configured, canSubmit: canSubmit),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFDDF1E4),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _HeroBackground()),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Keyboard closed and enough room: fixed screen, no scrolling.
              final double minFixed = _mode == AuthMode.signUp ? 760 : 660;
              if (!compact && constraints.maxHeight >= minFixed) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _AuthHero(
                        compact: false,
                        short: short,
                        signIn: _mode == AuthMode.signIn,
                      ),
                    ),
                    sheet,
                  ],
                );
              }
              // Keyboard open (or very short screen): compact hero and a
              // scrollable sheet that fills to the bottom.
              return CustomScrollView(
                controller: _scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: _AuthHero(
                      compact: true,
                      short: short,
                      signIn: _mode == AuthMode.signIn,
                    ),
                  ),
                  SliverFillRemaining(hasScrollBody: false, child: sheet),
                ],
              );
            },
          ),
          if (_busy)
            const Positioned.fill(
              child: _BusyOverlay(message: 'Getting your account ready…'),
            ),
        ],
      ),
    );
  }

  Widget _buildForm({required bool configured, required bool canSubmit}) {
    final bool compact = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModeTabs(
          mode: _mode,
          onChanged: (AuthMode next) {
            setState(() {
              _mode = next;
              _error = null;
            });
          },
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        if (!configured)
          _InfoBanner(
            text:
                'Sign-in isn’t set up in this build. Add '
                'SUPABASE_URL and SUPABASE_ANON_KEY, then rebuild.',
          )
        else if (!_online)
          const _InfoBanner(
            text: 'You’re offline. Connect to the internet to sign in.',
            danger: true,
          ),
        if (configured && _online) ...[
          _GoogleButton(
            enabled: !_busy && CloudConfig.googleConfigured,
            onPressed: _submitGoogle,
          ),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          const _OrDivider(),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        ],
        if (_mode == AuthMode.signUp) ...[
          KeyedSubtree(
            key: _nameKey,
            child: TextField(
              controller: _name,
              focusNode: _nameFocus,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              enabled: !_busy,
              decoration: _fieldDecoration(
                label: 'Name',
                prefix: Icons.person_outline_rounded,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _emailFocus.requestFocus(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        KeyedSubtree(
          key: _emailKey,
          child: TextField(
            controller: _email,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            textInputAction: TextInputAction.next,
            enabled: !_busy,
            decoration: _fieldDecoration(
              label: 'Email',
              prefix: Icons.mail_outline_rounded,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        KeyedSubtree(
          key: _passwordKey,
          child: TextField(
            controller: _password,
            focusNode: _passwordFocus,
            obscureText: _obscure,
            autofillHints: const <String>[AutofillHints.password],
            textInputAction: TextInputAction.done,
            enabled: !_busy,
            decoration: _fieldDecoration(
              label: 'Password',
              helper: _mode == AuthMode.signUp ? '8+ characters' : null,
              prefix: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (canSubmit) {
                unawaited(_submitEmail());
              }
            },
          ),
        ),
        if (_mode == AuthMode.signUp) ...[
          const SizedBox(height: AppSpacing.sm),
          _TermsRow(
            accepted: _termsAccepted,
            onChanged: (bool v) => setState(() => _termsAccepted = v),
            onTerms: () => _openLegal(AppLinks.terms),
            onPrivacy: () => _openLegal(AppLinks.privacyPolicy),
          ),
        ],
        if (_mode == AuthMode.signIn)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _busy ? null : _forgotPassword,
              child: Text(
                'Forgot password?',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _ErrorBox(message: _error!),
        ],
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        KeyedSubtree(
          key: _ctaKey,
          child: _GradientCta(
            label: _mode == AuthMode.signIn ? 'Sign in' : 'Create account',
            icon: _mode == AuthMode.signIn
                ? Icons.arrow_forward_rounded
                : Icons.person_add_alt_1_rounded,
            enabled: canSubmit,
            onPressed: _submitEmail,
          ),
        ),
      ],
    );
  }
}

/// Mint gradient and soft glows behind the whole auth screen, so the
/// sheet's rounded corners sit on the hero colour.
class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.mint,
            AppColors.sessionBackground,
            Color(0xFFDDF1E4),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: _GlowOrb(size: 200, alpha: 0.18),
          ),
          Positioned(
            left: -50,
            top: 260,
            child: _GlowOrb(size: 140, alpha: 0.12),
          ),
        ],
      ),
    );
  }
}

/// Mint hero: brand row, headline and the lying-figure pelvic floor
/// spotlight. Collapses to the brand row while the keyboard is open.
class _AuthHero extends StatelessWidget {
  const _AuthHero({
    required this.compact,
    required this.short,
    required this.signIn,
  });

  final bool compact;
  final bool short;
  final bool signIn;

  /// Spotlight height is this fraction of its width (lens + visible figure).
  static const double _spotlightHeightPerWidth = 0.58;

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top;
    if (compact) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          top + AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: const _BrandRow(compact: true),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        top + AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool tight = constraints.maxHeight < 300;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BrandRow(compact: false),
              SizedBox(height: tight ? AppSpacing.sm : AppSpacing.lg),
              Text(
                signIn ? 'Welcome back' : 'Create your account',
                style: AppTypography.display.copyWith(letterSpacing: -0.6),
              ),
              if (!tight) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  signIn
                      ? 'Pick up your pelvic floor plan where you left off.'
                      : 'Guided pelvic floor training, a few minutes a day.',
                  maxLines: 2,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    if (box.maxHeight < 90) {
                      return const SizedBox.shrink();
                    }
                    final double width = [
                      box.maxWidth,
                      box.maxHeight / _spotlightHeightPerWidth,
                      short ? 300.0 : 360.0,
                    ].reduce((double a, double b) => a < b ? a : b);
                    return Center(
                      child: SizedBox(
                        width: width,
                        child: const _PelvisSpotlight(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// App mark and name on one line.
class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x221A7D43),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Illustration(
            assetPath: 'assets/images/target.svg',
            semanticLabel: AppConstants.displayName,
            width: 22,
            height: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            AppConstants.displayName,
            style: AppTypography.title.copyWith(letterSpacing: -0.3),
          ),
        ),
        if (!compact)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: AppRadii.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pelvic health',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Soft radial brand glow used as hero decoration.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              AppColors.accent.withValues(alpha: alpha),
              AppColors.accent.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Man lying on his back with a magnifier lens showing the pelvic floor,
/// joined by a dashed pointer to a pulsing marker on his pelvis.
class _PelvisSpotlight extends StatefulWidget {
  const _PelvisSpotlight();

  @override
  State<_PelvisSpotlight> createState() => _PelvisSpotlightState();
}

class _PelvisSpotlightState extends State<_PelvisSpotlight>
    with SingleTickerProviderStateMixin {
  static const String _figure =
      'assets/images/onboarding/cutouts/tutorial_where.png';
  static const String _pelvis = 'assets/images/onboarding/cutouts/pelvis.png';

  /// Cutout is 900x371; the pelvis glow sits at (450, 234).
  static const double _figureAspect = 900 / 371;
  static const Offset _pelvisPoint = Offset(0.5, 0.63);

  /// Lens bottom sits this far down the figure (empty space above the torso).
  static const double _lensBottomOnFigure = 0.30;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.isReduced(context)) {
      _pulse.stop();
      _pulse.value = 0.35;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double figureH = w / _figureAspect;
        final double lens = w * 0.29;
        final double figureTop = lens - figureH * _lensBottomOnFigure;
        final Offset pelvis = Offset(
          w * _pelvisPoint.dx,
          figureTop + figureH * _pelvisPoint.dy,
        );
        final Offset lensBottom = Offset(w * _pelvisPoint.dx, lens);
        return Semantics(
          image: true,
          label: 'Pelvic floor muscles, shown on a man lying on his back',
          child: SizedBox(
            width: w,
            height: figureTop + figureH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: figureTop,
                  height: figureH,
                  child: Image.asset(
                    _figure,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (BuildContext context, Widget? child) {
                      return CustomPaint(
                        painter: _SpotlightPainter(
                          from: lensBottom,
                          to: pelvis,
                          pulse: _pulse.value,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: pelvis.dx - lens / 2,
                  top: 0,
                  width: lens,
                  height: lens,
                  child: Container(
                    padding: EdgeInsets.all(lens * 0.12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.55),
                        width: 2,
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x261A7D43),
                          blurRadius: 18,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      _pelvis,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                Positioned(
                  left: pelvis.dx + lens / 2 + AppSpacing.xs,
                  top: lens * 0.32,
                  child: const _SpotlightLabel(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Pelvic floor" tag beside the lens.
class _SpotlightLabel extends StatelessWidget {
  const _SpotlightLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadii.pillAll,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x331A7D43),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Pelvic floor',
        style: AppTypography.caption.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Dashed pointer from the lens to the pelvis plus expanding pulse rings.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.from,
    required this.to,
    required this.pulse,
  });

  final Offset from;
  final Offset to;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dash = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.75)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const double dashLen = 4;
    const double gap = 4;
    final double total = (to - from).distance - 6;
    final Offset dir = (to - from) / (to - from).distance;
    for (double d = 0; d < total; d += dashLen + gap) {
      final double end = d + dashLen > total ? total : d + dashLen;
      canvas.drawLine(from + dir * d, from + dir * end, dash);
    }

    for (final double phase in <double>[pulse, (pulse + 0.5) % 1]) {
      final Paint ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.accent.withValues(alpha: (1 - phase) * 0.6);
      canvas.drawCircle(to, 6 + phase * 18, ring);
    }
    canvas.drawCircle(to, 6, Paint()..color = AppColors.surface);
    canvas.drawCircle(to, 4, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.pulse != pulse || old.from != from || old.to != to;
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool signIn = mode == AuthMode.signIn;
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: signIn ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TabChip(
                    label: 'Sign in',
                    icon: Icons.login_rounded,
                    selected: signIn,
                    onTap: () => onChanged(AuthMode.signIn),
                  ),
                ),
                Expanded(
                  child: _TabChip(
                    label: 'Create account',
                    icon: Icons.person_add_alt_rounded,
                    selected: !signIn,
                    onTap: () => onChanged(AuthMode.signUp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White "Continue with Google" pill with the official multicolour G.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: PressScale(
        onTap: enabled ? onPressed : null,
        semanticLabel: 'Continue with Google',
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.pillAll,
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/images/google_g.svg',
                  width: 22,
                  height: 22,
                  excludeFromSemantics: true,
                ),
              ),
              Expanded(
                child: Text(
                  'Continue with Google',
                  textAlign: TextAlign.center,
                  style: AppTypography.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main email action: green gradient pill with an icon badge.
class _GradientCta extends StatelessWidget {
  const _GradientCta({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color fg = enabled
        ? AppColors.textOnPrimary
        : AppColors.textDisabledLabel;
    return PressScale(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          color: enabled ? null : AppColors.buttonDisabled,
          gradient: enabled
              ? const LinearGradient(
                  colors: <Color>[AppColors.accent, AppColors.primary],
                )
              : null,
          boxShadow: enabled
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x401A7D43),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Row(
          children: [
            const SizedBox(width: 44),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.button.copyWith(color: fg),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.surface.withValues(alpha: 0.2)
                    : AppColors.surface.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('or use email', style: AppTypography.caption),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.accepted,
    required this.onChanged,
    required this.onTerms,
    required this.onPrivacy,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: accepted,
            onChanged: (bool? v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('I agree to the ', style: AppTypography.caption),
                GestureDetector(
                  onTap: onTerms,
                  child: Text(
                    'Terms',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(' and ', style: AppTypography.caption),
                GestureDetector(
                  onTap: onPrivacy,
                  child: Text(
                    'Privacy Policy',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text, this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: danger ? const Color(0xFFFFF1F4) : AppColors.mint,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Text(
          text,
          style: AppTypography.caption.copyWith(
            color: danger ? const Color(0xFFB42318) : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F4),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusyOverlay extends StatelessWidget {
  const _BusyOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x661A1C2E),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppElevation.level2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Please wait a moment',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckEmailPage extends StatelessWidget {
  const _CheckEmailPage({
    required this.email,
    required this.busy,
    required this.onBack,
    required this.onResend,
  });

  final String email;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Check your inbox', style: AppTypography.display),
              const SizedBox(height: AppSpacing.md),
              Text(
                email.isEmpty
                    ? 'We sent a confirmation link. Open it, then come back and sign in.'
                    : 'We sent a confirmation link to $email. Open it, then come back and sign in.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Back to sign in', onPressed: onBack),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'Resend email',
                enabled: !busy,
                onPressed: onResend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
