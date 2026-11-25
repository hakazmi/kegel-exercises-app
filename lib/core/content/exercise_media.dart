/// Demo media for each exercise: a short looping video of the man doing it
/// (`assets/videos/exercises/<id>.mp4`) and a still poster frame (`<id>.jpg`).
abstract final class ExerciseMedia {
  static const String _dir = 'assets/videos/exercises';

  /// Exercises that have a demo video.
  static const Set<String> _withVideo = <String>{
    'slow_hold',
    'quick_squeeze',
    'strong_hold',
    'standing_walking_holds',
    'bridge_with_hold',
    'squat_with_coordination',
    'sit_to_stand_squeeze',
    'the_knack',
    'pillow_squeeze_lift',
    'diaphragmatic_breathing',
    'reverse_kegel',
    'childs_pose',
    'happy_baby',
    'supported_back_release',
  };

  /// Exercises built on a pelvic floor squeeze: these also show the 3D
  /// "what happens inside" animation next to the body video.
  static const Set<String> squeezeExercises = <String>{
    'slow_hold',
    'quick_squeeze',
    'strong_hold',
    'standing_walking_holds',
    'bridge_with_hold',
    'squat_with_coordination',
    'sit_to_stand_squeeze',
    'the_knack',
    'pillow_squeeze_lift',
  };

  static bool hasVideo(String id) => _withVideo.contains(id);

  static String? video(String id) => hasVideo(id) ? '$_dir/$id.mp4' : null;

  static String? poster(String id) => hasVideo(id) ? '$_dir/$id.jpg' : null;

  /// Exercise id for a session block's title key (slow holds, quick
  /// squeezes and reverse Kegels use short keys; others use the id).
  static String idForBlock(String titleKey) => switch (titleKey) {
    'slowHolds' => 'slow_hold',
    'quickSqueezes' => 'quick_squeeze',
    'reverseKegel' => 'reverse_kegel',
    'breathing' => 'diaphragmatic_breathing',
    _ => titleKey,
  };

  /// "Where the muscles are" anatomy video for the technique guide.
  static const String whereMuscles = 'assets/videos/where_muscles.mp4';
  static const String whereMusclesPoster = 'assets/videos/where_muscles.jpg';
}
