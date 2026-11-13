import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

/// Debug-only gallery that exercises every shared widget state.
class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key});

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  bool _selected = true;
  bool _multiA = true;
  bool _multiB = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.devGalleryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SectionHeader(
            title: 'Buttons',
            subtitle: 'Primary, secondary and text link',
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Primary enabled', onPressed: () {}),
          const SizedBox(height: AppSpacing.xs),
          const PrimaryButton(label: 'Primary disabled', onPressed: null),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(label: 'Secondary', onPressed: () {}),
          const SizedBox(height: AppSpacing.xs),
          const SecondaryButton(label: 'Secondary disabled', onPressed: null),
          TextLinkButton(label: 'Text link', onPressed: () {}),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Progress header'),
          const SizedBox(height: AppSpacing.sm),
          ProgressHeader(
            step: 2,
            total: 6,
            onBack: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Cards'),
          const SizedBox(height: AppSpacing.sm),
          SelectableCard(
            title: 'Selectable selected',
            subtitle: 'Single-select state',
            selected: _selected,
            leading: const Icon(Icons.water_drop),
            iconBackground: AppColors.goalBladderBg,
            iconForeground: AppColors.goalBladderFg,
            onTap: () => setState(() => _selected = true),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableCard(
            title: 'Selectable idle',
            selected: !_selected,
            leading: const Icon(Icons.favorite),
            iconBackground: AppColors.goalGeneralBg,
            iconForeground: AppColors.goalGeneralFg,
            onTap: () => setState(() => _selected = false),
          ),
          const SizedBox(height: AppSpacing.xs),
          MultiSelectCard(
            title: 'Multi A',
            selected: _multiA,
            onChanged: (bool value) => setState(() => _multiA = value),
          ),
          const SizedBox(height: AppSpacing.xs),
          MultiSelectCard(
            title: 'Multi B',
            selected: _multiB,
            onChanged: (bool value) => setState(() => _multiB = value),
          ),
          const SizedBox(height: AppSpacing.xs),
          const AppCard(
            child: Text('AppCard content', style: AppTypography.body),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Section header',
            subtitle: 'Optional supporting sentence',
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'SectionHeader is the title block above each gallery group.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Stat tile'),
          const SizedBox(height: AppSpacing.sm),
          const StatTile(
            value: '3',
            label: 'Day streak',
            icon: Icons.local_fire_department,
            iconBackground: AppColors.streakBg,
            iconForeground: AppColors.streakFg,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Week strip'),
          const SizedBox(height: AppSpacing.sm),
          const WeekStrip(
            days: <WeekDayItem>[
              WeekDayItem(label: 'Mon', dayNumber: '9', completed: true),
              WeekDayItem(label: 'Tue', dayNumber: '10', completed: true),
              WeekDayItem(
                label: 'Wed',
                dayNumber: '11',
                isToday: true,
                completed: true,
              ),
              WeekDayItem(label: 'Thu', dayNumber: '12'),
              WeekDayItem(label: 'Fri', dayNumber: '13'),
              WeekDayItem(label: 'Sat', dayNumber: '14'),
              WeekDayItem(label: 'Sun', dayNumber: 'Rest', isRest: true),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Illustration'),
          const SizedBox(height: AppSpacing.sm),
          const Center(
            child: Illustration(
              assetPath: 'assets/images/target.svg',
              semanticLabel: 'Target icon',
              width: 64,
              height: 64,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Disclaimer'),
          const SizedBox(height: AppSpacing.sm),
          const DisclaimerText(
            text:
                'This app is not a medical device and does not diagnose, treat, cure or prevent any medical condition.',
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Confirm dialog'),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: 'Show confirm dialog',
            onPressed: () {
              ConfirmDialog.show(
                context,
                title: 'Leave session?',
                message: 'A partial session is not counted.',
                confirmLabel: 'Leave',
                cancelLabel: 'Stay',
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Session ring'),
          const SizedBox(height: AppSpacing.sm),
          const ColoredBox(
            color: AppColors.sessionBackground,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  SessionRing(
                    phase: SessionPhase.squeeze,
                    duration: Duration(seconds: 3),
                    progress: 0.4,
                    size: 140,
                    child: Text(
                      'Squeeze',
                      style: TextStyle(color: AppColors.sessionText),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SessionRing(
                    phase: SessionPhase.hold,
                    duration: Duration(seconds: 3),
                    progress: 0.7,
                    size: 140,
                    child: Text(
                      'Hold',
                      style: TextStyle(color: AppColors.sessionText),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SessionRing(
                    phase: SessionPhase.relax,
                    duration: Duration(seconds: 3),
                    progress: 0.55,
                    size: 140,
                    child: Text(
                      'Relax',
                      style: TextStyle(color: AppColors.sessionText),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SessionRing(
                    phase: SessionPhase.rest,
                    duration: Duration(seconds: 3),
                    progress: 0.25,
                    size: 140,
                    child: Text(
                      'Rest',
                      style: TextStyle(color: AppColors.sessionText),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Bottom tab bar'),
          const SizedBox(height: AppSpacing.sm),
          BottomTabBar(
            current: AppTab.today,
            todayLabel: l10n.tabToday,
            progressLabel: l10n.tabProgress,
            learnLabel: l10n.tabLearn,
            onSelect: (_) {},
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
