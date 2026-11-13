import '../domain/enums.dart';

/// Maps on-screen option order to a normalised score (1 = worst, 5 = best).
abstract final class CheckInScoring {
  static const int minScore = 1;
  static const int maxScore = 5;
  static const int optionCount = 5;

  /// [optionIndex] is 0 at the top of the list (as shown on screen).
  static int normalisedFromOptionIndex(Goal goal, int optionIndex) {
    assert(optionIndex >= 0 && optionIndex < optionCount);
    if (goal == Goal.bladderControl) {
      // Never (top) = 5 best … Every day (bottom) = 1 worst.
      return maxScore - optionIndex;
    }
    // Other goals: top option is worst (1).
    return optionIndex + 1;
  }

  /// Inverse of [normalisedFromOptionIndex].
  static int optionIndexFromScore(Goal goal, int score) {
    assert(score >= minScore && score <= maxScore);
    if (goal == Goal.bladderControl) {
      return maxScore - score;
    }
    return score - 1;
  }
}
