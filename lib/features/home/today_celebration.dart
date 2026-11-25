import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Id of the Today item the user just finished, set by S4 before it returns
/// to Today. H1 plays the completion animation for it once, then clears it.
class TodayCelebration extends Notifier<String?> {
  @override
  String? build() => null;

  /// Marks [itemId] as just completed.
  void mark(String itemId) => state = itemId;

  /// Clears the pending celebration.
  void clear() => state = null;
}

/// Pending "just completed" Today item, or null.
final todayCelebrationProvider = NotifierProvider<TodayCelebration, String?>(
  TodayCelebration.new,
);
