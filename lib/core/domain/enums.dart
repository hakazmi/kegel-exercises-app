/// Goal chosen at onboarding (O2).
enum Goal {
  bladderControl,
  erectionSupport,
  ejaculationControl,
  recoveryAfterProstateSurgery,
  generalPelvicHealth,
}

/// Kegel experience (O4).
enum Experience { none, unsure, confident }

/// Assigned training track.
enum TrackId {
  generalBladder,
  erectionSupport,
  ejaculationControl,
  afterProstateSurgery,
  relaxationFirst,
}

/// How the user felt after a session (S4).
enum SessionFeel { fine, mildDiscomfort, pain }

/// Timed session kinds on Today (habits are tick-only, not [SessionKind]).
enum SessionKind { strengthening, body, breathing, relaxation }

/// Today plan surface state for H1.
enum TodayPlanState {
  normal,
  allDone,
  restDay,
  dailyCapReached,
  catheterBlocked,
}

/// Maps a [Goal] to the default [TrackId] before safety overrides.
TrackId trackForGoal(Goal goal) {
  switch (goal) {
    case Goal.bladderControl:
    case Goal.generalPelvicHealth:
      return TrackId.generalBladder;
    case Goal.erectionSupport:
      return TrackId.erectionSupport;
    case Goal.ejaculationControl:
      return TrackId.ejaculationControl;
    case Goal.recoveryAfterProstateSurgery:
      return TrackId.afterProstateSurgery;
  }
}

/// Wire-format helpers for persistence.
extension GoalX on Goal {
  String get storageValue => name;
  static Goal parse(String value) => Goal.values.byName(value);
}

extension ExperienceX on Experience {
  String get storageValue => name;
  static Experience parse(String value) => Experience.values.byName(value);
}

extension TrackIdX on TrackId {
  String get storageValue => name;

  /// Id used in `tracks.json` / `levels.json` bodyCard maps.
  String get contentId {
    switch (this) {
      case TrackId.generalBladder:
        return 'general_bladder';
      case TrackId.erectionSupport:
        return 'erection_support';
      case TrackId.ejaculationControl:
        return 'ejaculation_control';
      case TrackId.afterProstateSurgery:
        return 'after_prostate_surgery';
      case TrackId.relaxationFirst:
        return 'relaxation_first';
    }
  }

  static TrackId parse(String value) => TrackId.values.byName(value);
}

extension SessionFeelX on SessionFeel {
  String get storageValue => name;
  static SessionFeel? tryParse(String? value) {
    if (value == null) {
      return null;
    }
    return SessionFeel.values.byName(value);
  }
}

extension SessionKindX on SessionKind {
  String get storageValue => name;
  static SessionKind parse(String value) => SessionKind.values.byName(value);
}
