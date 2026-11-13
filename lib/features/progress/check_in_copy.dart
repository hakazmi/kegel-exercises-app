import '../../app/l10n/app_localizations.dart';
import '../../core/domain/enums.dart';
import '../../core/plan/check_in_scoring.dart';

/// Goal-matched check-in question and on-screen option labels (ARB-backed).
abstract final class CheckInCopy {
  static String question(AppLocalizations l10n, Goal goal) {
    switch (goal) {
      case Goal.bladderControl:
        return l10n.g2QuestionBladder;
      case Goal.erectionSupport:
        return l10n.g2QuestionErection;
      case Goal.ejaculationControl:
        return l10n.g2QuestionEjaculation;
      case Goal.recoveryAfterProstateSurgery:
        return l10n.g2QuestionSurgery;
      case Goal.generalPelvicHealth:
        return l10n.g2QuestionGeneral;
    }
  }

  /// Labels top-to-bottom as shown on G2 (bladder keeps Never at the top).
  static List<String> options(AppLocalizations l10n, Goal goal) {
    switch (goal) {
      case Goal.bladderControl:
        return <String>[
          l10n.g2OptionBladder1,
          l10n.g2OptionBladder2,
          l10n.g2OptionBladder3,
          l10n.g2OptionBladder4,
          l10n.g2OptionBladder5,
        ];
      case Goal.erectionSupport:
        return <String>[
          l10n.g2OptionErection1,
          l10n.g2OptionErection2,
          l10n.g2OptionErection3,
          l10n.g2OptionErection4,
          l10n.g2OptionErection5,
        ];
      case Goal.ejaculationControl:
        return <String>[
          l10n.g2OptionEjaculation1,
          l10n.g2OptionEjaculation2,
          l10n.g2OptionEjaculation3,
          l10n.g2OptionEjaculation4,
          l10n.g2OptionEjaculation5,
        ];
      case Goal.recoveryAfterProstateSurgery:
        return <String>[
          l10n.g2OptionSurgery1,
          l10n.g2OptionSurgery2,
          l10n.g2OptionSurgery3,
          l10n.g2OptionSurgery4,
          l10n.g2OptionSurgery5,
        ];
      case Goal.generalPelvicHealth:
        return <String>[
          l10n.g2OptionGeneral1,
          l10n.g2OptionGeneral2,
          l10n.g2OptionGeneral3,
          l10n.g2OptionGeneral4,
          l10n.g2OptionGeneral5,
        ];
    }
  }

  /// Label for a stored normalised score (1 = worst, 5 = best).
  static String labelForScore(
    AppLocalizations l10n,
    Goal goal,
    int score,
  ) {
    final List<String> labels = options(l10n, goal);
    final int index = CheckInScoring.optionIndexFromScore(goal, score);
    return labels[index];
  }

  static String comparisonLine(
    AppLocalizations l10n, {
    required int week,
    required int score,
    required Goal goal,
  }) {
    return l10n.g2ComparisonLine(
      week,
      score,
      CheckInScoring.maxScore,
      labelForScore(l10n, goal, score),
    );
  }
}
