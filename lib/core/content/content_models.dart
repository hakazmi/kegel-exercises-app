/// Exercise entry from `assets/content/exercises.json`.
class ExerciseContent {
  const ExerciseContent({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.illustration,
    this.cues = const <String>[],
    this.defaultReps = 1,
    this.holdSec = 0,
    this.positions = const <String>[],
    this.contraindications = const <String>[],
  });

  final String id;
  final String name;
  final String description;

  /// strength | function | relaxation | habit | activity
  final String type;
  final String? illustration;
  final List<String> cues;
  final int defaultReps;
  final int holdSec;
  final List<String> positions;
  final List<String> contraindications;

  bool get isHabit => type == 'habit';
  bool get isActivity => type == 'activity';
  bool get isTimed =>
      type == 'strength' || type == 'function' || type == 'relaxation';

  factory ExerciseContent.fromJson(Map<String, dynamic> json) {
    return ExerciseContent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      illustration: json['illustration'] as String?,
      cues: (json['cues'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      defaultReps: json['defaultReps'] as int? ?? 1,
      holdSec: json['holdSec'] as int? ?? 0,
      positions: (json['positions'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      contraindications:
          (json['contraindications'] as List<dynamic>? ?? const <dynamic>[])
              .cast<String>(),
    );
  }
}

/// Level definition from `assets/content/levels.json`.
class LevelContent {
  const LevelContent({
    required this.id,
    required this.name,
    required this.dayStart,
    required this.dayEnd,
    required this.slowHolds,
    required this.quickSqueezes,
    required this.position,
    required this.bodyCard,
    required this.kegelExtras,
    required this.dailyBreathingSec,
  });

  final int id;
  final String name;
  final int dayStart;
  final int? dayEnd;
  final Map<String, dynamic> slowHolds;
  final Map<String, dynamic> quickSqueezes;
  final String position;

  /// Track id → exercise ids for the Body and function card.
  final Map<String, List<String>> bodyCard;

  /// Track id → extra kegel block exercise ids (e.g. strong_hold).
  final Map<String, List<String>> kegelExtras;
  final int dailyBreathingSec;

  /// Legacy helper: any body exercises listed for any track.
  List<String> get extras {
    final Set<String> all = <String>{};
    for (final List<String> ids in bodyCard.values) {
      all.addAll(ids);
    }
    return all.toList();
  }

  List<String> bodyExercisesForTrack(String trackId) =>
      List<String>.from(bodyCard[trackId] ?? const <String>[]);

  List<String> kegelExtrasForTrack(String trackId) =>
      List<String>.from(kegelExtras[trackId] ?? const <String>[]);

  factory LevelContent.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> parseTrackLists(String key) {
      final Object? raw = json[key];
      if (raw is Map) {
        return raw.map(
          (Object? k, Object? v) => MapEntry(
            k.toString(),
            (v as List<dynamic>? ?? const <dynamic>[]).cast<String>(),
          ),
        );
      }
      // Backward compat: old `extras` list → empty bodyCard.
      if (key == 'bodyCard' && raw is List) {
        return <String, List<String>>{};
      }
      return <String, List<String>>{};
    }

    return LevelContent(
      id: json['id'] as int,
      name: json['name'] as String,
      dayStart: json['dayStart'] as int,
      dayEnd: json['dayEnd'] as int?,
      slowHolds: Map<String, dynamic>.from(json['slowHolds'] as Map),
      quickSqueezes: Map<String, dynamic>.from(json['quickSqueezes'] as Map),
      position: json['position'] as String,
      bodyCard: parseTrackLists('bodyCard'),
      kegelExtras: parseTrackLists('kegelExtras'),
      dailyBreathingSec: json['dailyBreathingSec'] as int,
    );
  }
}

/// One source link shown under an article.
class ArticleSource {
  const ArticleSource({required this.title, required this.url});

  final String title;
  final String url;

  factory ArticleSource.fromJson(Map<String, dynamic> json) {
    return ArticleSource(
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}

/// One item in an article gallery: looping video, still photo, or GIF.
class ArticleMedia {
  const ArticleMedia({
    required this.poster,
    required this.caption,
    this.video,
    this.exerciseId,
  });

  /// Optional looping video. When null, [poster] is shown (jpg/png/gif).
  final String? video;
  final String poster;
  final String caption;

  /// Exercise detail to open from this clip, if any.
  final String? exerciseId;

  bool get isVideo => video != null && video!.isNotEmpty;

  factory ArticleMedia.fromJson(Map<String, dynamic> json) {
    final String? video = json['video'] as String?;
    return ArticleMedia(
      video: (video == null || video.isEmpty) ? null : video,
      poster: (json['poster'] as String?) ?? (json['image'] as String),
      caption: json['caption'] as String,
      exerciseId: json['exerciseId'] as String?,
    );
  }
}

/// Article entry from `assets/content/articles.json` plus loaded Markdown body.
class ArticleContent {
  const ArticleContent({
    required this.id,
    required this.title,
    required this.minutes,
    required this.image,
    required this.featured,
    required this.opensTutorial,
    required this.bodyAsset,
    required this.sources,
    this.cover,
    this.media = const <ArticleMedia>[],
    this.bodyMarkdown = '',
  });

  final String id;
  final String title;
  final int minutes;
  final String image;
  final bool featured;
  final bool opensTutorial;
  final String bodyAsset;
  final List<ArticleSource> sources;

  /// Photo/GIF cover shown instead of the [image] icon when present.
  final String? cover;

  /// Demo clips, stills or GIFs shown at the top of the article.
  final List<ArticleMedia> media;
  final String bodyMarkdown;

  /// List/detail gallery (videos, photos or GIFs).
  bool get hasMedia => media.isNotEmpty;

  /// At least one looping video clip.
  bool get hasVideo => media.any((ArticleMedia m) => m.isVideo);

  /// Best list thumbnail: cover, first media poster, else SVG [image].
  String get thumbAsset => cover ?? (media.isEmpty ? image : media.first.poster);

  bool get hasPhotoThumb {
    final String path = thumbAsset.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp');
  }

  ArticleContent copyWith({String? bodyMarkdown}) {
    return ArticleContent(
      id: id,
      title: title,
      minutes: minutes,
      image: image,
      featured: featured,
      opensTutorial: opensTutorial,
      bodyAsset: bodyAsset,
      sources: sources,
      cover: cover,
      media: media,
      bodyMarkdown: bodyMarkdown ?? this.bodyMarkdown,
    );
  }

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      id: json['id'] as String,
      title: json['title'] as String,
      minutes: json['minutes'] as int,
      image: json['image'] as String,
      featured: json['featured'] as bool? ?? false,
      opensTutorial: json['opensTutorial'] as bool? ?? false,
      bodyAsset: json['bodyAsset'] as String,
      sources: (json['sources'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic e) => ArticleSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      cover: json['cover'] as String?,
      media: (json['media'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic e) => ArticleMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Track definition from `assets/content/tracks.json`.
class TrackContent {
  const TrackContent({
    required this.id,
    required this.name,
    required this.setBy,
    required this.changes,
    required this.strengthening,
    required this.relaxationOnlyWeeks,
    this.blockedWithCatheter = false,
    this.gentlerHolds = false,
    this.gentleHold,
    this.breatheCard = const <String>[],
    this.restDayBreatheCard = const <String>[],
    this.habits = const <String>[],
    this.weeklyActivity,
    this.weeklyActivityOptional = true,
  });

  final String id;
  final String name;
  final List<String> setBy;
  final String changes;
  final bool strengthening;
  final int? relaxationOnlyWeeks;
  final bool blockedWithCatheter;
  final bool gentlerHolds;
  final Map<String, dynamic>? gentleHold;
  final List<String> breatheCard;
  final List<String> restDayBreatheCard;
  final List<String> habits;
  final String? weeklyActivity;
  final bool weeklyActivityOptional;

  factory TrackContent.fromJson(Map<String, dynamic> json) {
    return TrackContent(
      id: json['id'] as String,
      name: json['name'] as String,
      setBy: (json['setBy'] as List<dynamic>).cast<String>(),
      changes: json['changes'] as String,
      strengthening: json['strengthening'] as bool? ?? true,
      relaxationOnlyWeeks: json['relaxationOnlyWeeks'] as int?,
      blockedWithCatheter: json['blockedWithCatheter'] as bool? ?? false,
      gentlerHolds: json['gentlerHolds'] as bool? ?? false,
      gentleHold: json['gentleHold'] is Map
          ? Map<String, dynamic>.from(json['gentleHold'] as Map)
          : null,
      breatheCard: (json['breatheCard'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      restDayBreatheCard:
          (json['restDayBreatheCard'] as List<dynamic>? ?? const <dynamic>[])
              .cast<String>(),
      habits: (json['habits'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      weeklyActivity: json['weeklyActivity'] as String?,
      weeklyActivityOptional: json['weeklyActivityOptional'] as bool? ?? true,
    );
  }
}
