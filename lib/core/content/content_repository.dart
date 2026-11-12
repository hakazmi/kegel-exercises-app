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

  Future<Map<String, dynamic>> _loadMap(String path) async {
    final String raw = await _bundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
