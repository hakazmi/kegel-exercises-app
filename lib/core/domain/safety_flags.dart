/// Safety answers from O3 (and later Settings updates).
class SafetyFlags {
  const SafetyFlags({
    this.pain = false,
    this.painSexual = false,
    this.recentSurgery = false,
    this.catheter = false,
  });

  /// Pelvic, groin or genital pain.
  final bool pain;

  /// Pain with erection or ejaculation.
  final bool painSexual;

  /// Surgery in the last 3 months.
  final bool recentSurgery;

  /// Urinary catheter in place right now.
  final bool catheter;

  /// True when either pain option is set (routes to relaxation-first).
  bool get hasPain => pain || painSexual;

  SafetyFlags copyWith({
    bool? pain,
    bool? painSexual,
    bool? recentSurgery,
    bool? catheter,
  }) {
    return SafetyFlags(
      pain: pain ?? this.pain,
      painSexual: painSexual ?? this.painSexual,
      recentSurgery: recentSurgery ?? this.recentSurgery,
      catheter: catheter ?? this.catheter,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pain': pain,
        'painSexual': painSexual,
        'recentSurgery': recentSurgery,
        'catheter': catheter,
      };

  factory SafetyFlags.fromJson(Map<String, dynamic> json) {
    return SafetyFlags(
      pain: json['pain'] as bool? ?? false,
      painSexual: json['painSexual'] as bool? ?? false,
      recentSurgery: json['recentSurgery'] as bool? ?? false,
      catheter: json['catheter'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SafetyFlags &&
        other.pain == pain &&
        other.painSexual == painSexual &&
        other.recentSurgery == recentSurgery &&
        other.catheter == catheter;
  }

  @override
  int get hashCode => Object.hash(pain, painSexual, recentSurgery, catheter);
}
