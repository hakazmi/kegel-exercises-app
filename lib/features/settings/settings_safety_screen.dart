import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/safety_flags.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/safety_routing.dart';
import '../../core/widgets/widgets.dart';

/// Settings → Safety answers. Same options and routing rules as O3.
class SettingsSafetyScreen extends ConsumerStatefulWidget {
  const SettingsSafetyScreen({super.key});

  @override
  ConsumerState<SettingsSafetyScreen> createState() =>
      _SettingsSafetyScreenState();
}

class _SettingsSafetyScreenState extends ConsumerState<SettingsSafetyScreen> {
  bool _loaded = false;
  bool _pain = false;
  bool _painSexual = false;
  bool _recentSurgery = false;
  bool _catheter = false;
  bool _noneOfThese = true;
  bool _surgeryConfirmed = false;
  bool _saving = false;

  void _ensureLoaded() {
    if (_loaded) {
      return;
    }
    _loaded = true;
    final SafetyFlags flags = ref.read(userProfileProvider).safetyFlags;
    _pain = flags.pain;
    _painSexual = flags.painSexual;
    _recentSurgery = flags.recentSurgery;
    _catheter = flags.catheter;
    _noneOfThese = !flags.pain &&
        !flags.painSexual &&
        !flags.recentSurgery &&
        !flags.catheter;
    _surgeryConfirmed = flags.recentSurgery;
  }

  bool get _hasPain => _pain || _painSexual;

  bool get _canSave =>
      (_noneOfThese || _pain || _painSexual || _recentSurgery || _catheter) &&
      (_catheter || !_recentSurgery || _surgeryConfirmed);

  void _setNone() {
    setState(() {
      _noneOfThese = true;
      _pain = false;
      _painSexual = false;
      _recentSurgery = false;
      _catheter = false;
      _surgeryConfirmed = false;
    });
  }

  void _toggle({
    bool? pain,
    bool? painSexual,
    bool? recentSurgery,
    bool? catheter,
  }) {
    setState(() {
      _noneOfThese = false;
      if (pain != null) {
        _pain = pain;
      }
      if (painSexual != null) {
        _painSexual = painSexual;
      }
      if (recentSurgery != null) {
        _recentSurgery = recentSurgery;
        if (!recentSurgery) {
          _surgeryConfirmed = false;
        }
      }
      if (catheter != null) {
        _catheter = catheter;
      }
    });
  }

  Future<void> _save() async {
    if (!_canSave || _saving) {
      return;
    }
    setState(() => _saving = true);
    final UserProfile profile = ref.read(userProfileProvider);
    final DateTime now = ref.read(appClockProvider).now();
    final SafetyFlags flags = SafetyFlags(
      pain: _pain,
      painSexual: _painSexual,
      recentSurgery: _recentSurgery,
      catheter: _catheter,
    );
    final UserProfile next = SafetyRouting.apply(
      profile: profile,
      flags: flags,
      now: now,
    );
    await ref.read(userProfileProvider.notifier).save(next);
    ref.invalidate(todayPlanProvider);
    if (!mounted) {
      return;
    }
    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final AppLocalizations l10n = AppLocalizations.of(context);
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
        title: Text(l10n.x1SafetyTitle, style: AppTypography.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(
              l10n.o3Subtitle,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            MultiSelectCard(
              title: l10n.o3Pain,
              selected: _pain,
              onChanged: (bool value) => _toggle(pain: value),
            ),
            const SizedBox(height: AppSpacing.xs),
            MultiSelectCard(
              title: l10n.o3PainSexual,
              selected: _painSexual,
              onChanged: (bool value) => _toggle(painSexual: value),
            ),
            const SizedBox(height: AppSpacing.xs),
            MultiSelectCard(
              title: l10n.o3Surgery,
              selected: _recentSurgery,
              onChanged: (bool value) => _toggle(recentSurgery: value),
            ),
            const SizedBox(height: AppSpacing.xs),
            MultiSelectCard(
              title: l10n.o3Catheter,
              selected: _catheter,
              onChanged: (bool value) => _toggle(catheter: value),
            ),
            const SizedBox(height: AppSpacing.xs),
            MultiSelectCard(
              title: l10n.o3None,
              selected: _noneOfThese,
              onChanged: (bool value) {
                if (value) {
                  _setNone();
                }
              },
            ),
            if (_catheter) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.o3CatheterMessage,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ] else if (_hasPain) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.o3PainMessage,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (_recentSurgery && !_catheter) ...[
              const SizedBox(height: AppSpacing.md),
              MultiSelectCard(
                title: l10n.o3SurgeryUnderstand,
                selected: _surgeryConfirmed,
                onChanged: (bool value) =>
                    setState(() => _surgeryConfirmed = value),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.commonConfirm,
              enabled: _canSave && !_saving,
              onPressed: _canSave && !_saving ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
