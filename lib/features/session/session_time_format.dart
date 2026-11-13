/// Formats the large phase countdown under the phase word on S3.
///
/// Under 60 seconds: plain seconds (`0`, `9`, `59`).
/// 60 seconds or more: `m:ss` with unpadded minutes (`1:00`, `1:54`, `2:00`),
/// matching the colon style of the top-right elapsed clock.
String formatPhaseSecondsRemaining(int seconds) {
  final int safe = seconds < 0 ? 0 : seconds;
  if (safe < 60) {
    return '$safe';
  }
  final int m = safe ~/ 60;
  final int s = safe % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Formats the top-right elapsed clock as zero-padded `mm:ss`.
String formatSessionElapsed(int seconds) {
  final int safe = seconds < 0 ? 0 : seconds;
  final int m = safe ~/ 60;
  final int s = safe % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
