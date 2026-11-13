import '../../app/l10n/app_localizations.dart';
import '../../core/content/content_models.dart';
import '../../core/domain/enums.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';

/// Shared copy helpers for H1 / H2 (track names, durations, level labels).
abstract final class HomeCopy {
  static String trackName(AppLocalizations l10n, TrackId track) {
    switch (track) {
      case TrackId.generalBladder:
        return l10n.o6TrackGeneralBladder;
      case TrackId.erectionSupport:
        return l10n.o6TrackErection;
      case TrackId.ejaculationControl:
        return l10n.o6TrackEjaculation;
      case TrackId.afterProstateSurgery:
        return l10n.o6TrackSurgery;
      case TrackId.relaxationFirst:
        return l10n.o6TrackRelaxation;
    }
  }

  static String levelName(AppLocalizations l10n, int levelId) {
    switch (levelId) {
      case 1:
        return l10n.h2LevelNameStart;
      case 2:
        return l10n.h2LevelNameBuild;
      case 3:
        return l10n.h2LevelNameSteady;
      case 4:
        return l10n.h2LevelNameDeep;
      case 5:
        return l10n.h2LevelNameMaintain;
      default:
        return l10n.h2LevelNameStart;
    }
  }

  /// Calendar days spanned by a level definition (Level 5 stays open-ended).
  static int daysInLevel(LevelContent level) {
    if (level.dayEnd == null) {
      return PlanRules.levelUnlockWindowDays;
    }
    return (level.dayEnd! - level.dayStart + 1).clamp(1, 365);
  }

  /// Total days shown on Today / Levels for the active plan segment.
  static int planTotalDays({
    required TrackId track,
    LevelContent? level,
  }) {
    if (track == TrackId.relaxationFirst) {
      return PlanRules.relaxationFirstDays;
    }
    if (level == null) {
      return PlanRules.levelUnlockWindowDays;
    }
    return daysInLevel(level);
  }

  static String formatDuration(AppLocalizations l10n, int seconds) {
    if (seconds >= 60) {
      final int minutes = (seconds / 60).round().clamp(1, 999);
      return l10n.h1DurationMinutes(minutes);
    }
    return l10n.h1DurationSeconds(seconds);
  }

  static String itemTitle(AppLocalizations l10n, TodayItem item) {
    switch (item.kind) {
      case SessionKind.strengthening:
        return l10n.h1SessionLabel(item.sessionNumber ?? 1);
      case SessionKind.breathing:
        return l10n.h1BreathingLabel;
      case SessionKind.relaxation:
        return l10n.h1ReverseLabel;
    }
  }

  static String itemMeta(AppLocalizations l10n, TodayItem item) {
    final String duration = formatDuration(l10n, item.durationSeconds);
    if (item.done) {
      return l10n.h1ItemDoneMeta(duration);
    }
    return l10n.h1ItemPendingMeta(duration);
  }

  static String holdsLabel(AppLocalizations l10n, LevelContent level) {
    final int? fixed = level.slowHolds['holdSec'] as int?;
    final int? min = level.slowHolds['holdSecMin'] as int?;
    final int? max = level.slowHolds['holdSecMax'] as int?;
    if (fixed != null) {
      return l10n.h2HoldsFixed(fixed);
    }
    if (min != null && max != null) {
      return l10n.h2HoldsRange(min, max);
    }
    return l10n.h2HoldsFixed(min ?? 3);
  }

  static String positionShort(AppLocalizations l10n, LevelContent level) {
    if (level.extras.isNotEmpty) {
      return l10n.h2PositionExtras;
    }
    switch (level.position) {
      case 'lying_or_sitting':
        return l10n.h2PositionLyingOrSitting;
      case 'sitting':
        return l10n.h2PositionSitting;
      case 'sitting_and_standing':
        return l10n.h2PositionSittingAndStanding;
      case 'standing':
        return l10n.h2PositionStanding;
      case 'any':
        return l10n.h2PositionAny;
      default:
        return l10n.h2PositionLyingOrSitting;
    }
  }

  static String levelRange(AppLocalizations l10n, LevelContent level) {
    if (level.dayEnd == null) {
      return l10n.h2DayOnward(level.dayStart);
    }
    return l10n.h2DayRange(level.dayStart, level.dayEnd!);
  }

  static String levelMeta(AppLocalizations l10n, LevelContent level) {
    return l10n.h2LevelMeta(
      levelRange(l10n, level),
      holdsLabel(l10n, level),
      positionShort(l10n, level),
    );
  }
}
