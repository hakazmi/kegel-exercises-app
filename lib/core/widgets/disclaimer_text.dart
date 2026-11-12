import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Small-print medical / legal disclaimer text.
class DisclaimerText extends StatelessWidget {
  const DisclaimerText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
        height: 1.45,
      ),
    );
  }
}
