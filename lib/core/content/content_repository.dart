import 'dart:convert';

import 'package:flutter/services.dart';

import 'content_models.dart';

/// Loads exercise / level / track JSON from assets.
class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  bool? _exercisesReviewed;
  bool? _levelsReviewed;
  bool? _tracksReviewed;

  List<ExerciseContent>? _exercises;
  List<LevelContent>? _levels;
  List<TrackContent>? _tracks;
  List<ArticleContent>? _articles;

  bool get exercisesReviewedByPhysio => _exercisesReviewed ?? false;
  bool get levelsReviewedByPhysio => _levelsReviewed ?? false;
  bool get tracksReviewedByPhysio => _tracksReviewed ?? false;

  Future<List<ExerciseContent>> loadExercises() async {
    if (_exercises != null) {
      return _exercises!;
    }
    final Map<String, dynamic> json = await _loadMap('assets/content/exercises.json');
    _exercisesReviewed = json['reviewedByPhysio'] as bool? ?? false;
    _exercises = (json['exercises'] as List<dynamic>)
        .map((dynamic e) => ExerciseContent.fromJson(e as Map<String, dynamic>))
        .toList();
    return _exercises!;
  }

  Future<List<LevelContent>> loadLevels() async {
    if (_levels != null) {
      return _levels!;
    }
    final Map<String, dynamic> json = await _loadMap('assets/content/levels.json');
    _levelsReviewed = json['reviewedByPhysio'] as bool? ?? false;
    _levels = (json['levels'] as List<dynamic>)
        .map((dynamic e) => LevelContent.fromJson(e as Map<String, dynamic>))
        .toList();
    return _levels!;
  }

  Future<List<TrackContent>> loadTracks() async {
    if (_tracks != null) {
      return _tracks!;
    }
    final Map<String, dynamic> json = await _loadMap('assets/content/tracks.json');
    _tracksReviewed = json['reviewedByPhysio'] as bool? ?? false;
    _tracks = (json['tracks'] as List<dynamic>)
        .map((dynamic e) => TrackContent.fromJson(e as Map<String, dynamic>))
        .toList();
    return _tracks!;
  }

  /// Article index from JSON; Markdown bodies load on demand via [loadArticleBody].
  Future<List<ArticleContent>> loadArticles() async {
    if (_articles != null) {
      return _articles!;
    }
    final Map<String, dynamic> json =
        await _loadMap('assets/content/articles.json');
    _articles = (json['articles'] as List<dynamic>)
        .map((dynamic e) => ArticleContent.fromJson(e as Map<String, dynamic>))
        .toList();
    return _articles!;
  }

  /// Loads Markdown body for [article] from its asset path.
  Future<ArticleContent> loadArticleBody(ArticleContent article) async {
    if (article.bodyMarkdown.isNotEmpty) {
      return article;
    }
    final String body = await _bundle.loadString(article.bodyAsset);
    return article.copyWith(bodyMarkdown: body);
  }

  Future<ArticleContent?> loadArticleById(String id) async {
    final List<ArticleContent> all = await loadArticles();
    ArticleContent? match;
    for (final ArticleContent article in all) {
      if (article.id == id) {
        match = article;
        break;
      }
    }
    if (match == null) {
      return null;
    }
    return loadArticleBody(match);
  }

  Future<Map<String, dynamic>> _loadMap(String path) async {
    final String raw = await _bundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
