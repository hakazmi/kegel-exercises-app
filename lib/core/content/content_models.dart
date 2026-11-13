/// Exercise entry from `assets/content/exercises.json`.
class ExerciseContent {
  const ExerciseContent({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });

  final String id;
  final String name;
  final String description;
  final String type;

  factory ExerciseContent.fromJson(Map<String, dynamic> json) {
    return ExerciseContent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
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
    required this.extras,
    required this.dailyBreathingSec,
  });

  final int id;
  final String name;
  final int dayStart;
  final int? dayEnd;
  final Map<String, dynamic> slowHolds;
  final Map<String, dynamic> quickSqueezes;
  final String position;
  final List<String> extras;
  final int dailyBreathingSec;

  factory LevelContent.fromJson(Map<String, dynamic> json) {
    return LevelContent(
      id: json['id'] as int,
      name: json['name'] as String,
      dayStart: json['dayStart'] as int,
      dayEnd: json['dayEnd'] as int?,
      slowHolds: Map<String, dynamic>.from(json['slowHolds'] as Map),
      quickSqueezes: Map<String, dynamic>.from(json['quickSqueezes'] as Map),
      position: json['position'] as String,
      extras: (json['extras'] as List<dynamic>).cast<String>(),
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
  final String bodyMarkdown;

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
          .map(
            (dynamic e) => ArticleSource.fromJson(e as Map<String, dynamic>),
          )
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
  });

  final String id;
  final String name;
  final List<String> setBy;
  final String changes;
  final bool strengthening;
  final int? relaxationOnlyWeeks;

  factory TrackContent.fromJson(Map<String, dynamic> json) {
    return TrackContent(
      id: json['id'] as String,
      name: json['name'] as String,
      setBy: (json['setBy'] as List<dynamic>).cast<String>(),
      changes: json['changes'] as String,
      strengthening: json['strengthening'] as bool? ?? true,
      relaxationOnlyWeeks: json['relaxationOnlyWeeks'] as int?,
    );
  }
}
