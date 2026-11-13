import '../domain/enums.dart';
import '../domain/safety_flags.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';

/// Applies O3-style safety routing to an existing profile (Settings editor).
abstract final class SafetyRouting {
  /// Updates flags and track the same way onboarding Safety check does.
  ///
  /// Pain → relaxation-first. No pain → track from goal. Catheter is stored
  /// and blocks exercises on Today without changing onboardingDone.
  static UserProfile apply({
    required UserProfile profile,
    required SafetyFlags flags,
    required DateTime now,
  }) {
    final TrackId track;
    if (flags.pain || flags.painSexual) {
      track = TrackId.relaxationFirst;
    } else if (profile.goal != null) {
      track = trackForGoal(profile.goal!);
    } else {
      track = TrackId.generalBladder;
    }

    final bool trackChanged = track != profile.track;
    return profile.copyWith(
      safetyFlags: flags,
      track: track,
      level: trackChanged ? 1 : profile.level,
      levelStartedOn: trackChanged ? dateOnly(now) : profile.levelStartedOn,
    );
  }
}
