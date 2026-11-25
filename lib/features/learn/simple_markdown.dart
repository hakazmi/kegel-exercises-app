import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Minimal Markdown renderer for Learn articles (headings, paragraphs,
/// bullets and numbered lists).
///
/// Not a full Markdown engine — enough for clinical copy under 150 words.
/// Links in the body are plain text; Sources use [url_launcher].
class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final List<_Block> blocks = _parse(source);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final _Block block in blocks) ...[
          block.build(),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  static final RegExp _numbered = RegExp(r'^(\d+)\.\s+(.*)$');

  static List<_Block> _parse(String source) {
    final List<String> lines = source.replaceAll('\r\n', '\n').split('\n');
    final List<_Block> blocks = <_Block>[];
    final List<String> paragraph = <String>[];
    final List<String> bullets = <String>[];
    final List<String> numbered = <String>[];

    void flushParagraph() {
      if (paragraph.isEmpty) {
        return;
      }
      blocks.add(_ParagraphBlock(paragraph.join(' ').trim()));
      paragraph.clear();
    }

    void flushBullets() {
      if (bullets.isEmpty) {
        return;
      }
      blocks.add(_BulletBlock(List<String>.from(bullets)));
      bullets.clear();
    }

    void flushNumbered() {
      if (numbered.isEmpty) {
        return;
      }
      blocks.add(_NumberedBlock(List<String>.from(numbered)));
      numbered.clear();
    }

    for (final String raw in lines) {
      final String line = raw.trimRight();
      final String trimmed = line.trim();
      if (trimmed.isEmpty) {
        flushBullets();
        flushNumbered();
        flushParagraph();
        continue;
      }
      if (trimmed.startsWith('### ')) {
        flushBullets();
        flushNumbered();
        flushParagraph();
        blocks.add(_HeadingBlock(trimmed.substring(4), 3));
        continue;
      }
      if (trimmed.startsWith('## ')) {
        flushBullets();
        flushNumbered();
        flushParagraph();
        blocks.add(_HeadingBlock(trimmed.substring(3), 2));
        continue;
      }
      if (trimmed.startsWith('# ')) {
        flushBullets();
        flushNumbered();
        flushParagraph();
        blocks.add(_HeadingBlock(trimmed.substring(2), 1));
        continue;
      }
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        flushNumbered();
        flushParagraph();
        bullets.add(trimmed.substring(2).trim());
        continue;
      }
      final Match? numberedMatch = _numbered.firstMatch(trimmed);
      if (numberedMatch != null) {
        flushBullets();
        flushParagraph();
        numbered.add(numberedMatch.group(2)!.trim());
        continue;
      }
      flushBullets();
      flushNumbered();
      paragraph.add(trimmed);
    }
    flushBullets();
    flushNumbered();
    flushParagraph();
    return blocks;
  }
}

abstract class _Block {
  Widget build();
}

class _HeadingBlock implements _Block {
  _HeadingBlock(this.text, this.level);

  final String text;
  final int level;

  @override
  Widget build() {
    final TextStyle style = level <= 1
        ? AppTypography.title
        : AppTypography.body.copyWith(fontWeight: FontWeight.w700);
    return Text(_stripInline(text), style: style);
  }
}

class _ParagraphBlock implements _Block {
  _ParagraphBlock(this.text);

  final String text;

  @override
  Widget build() {
    return Text(
      _stripInline(text),
      style: AppTypography.body.copyWith(
        color: AppColors.textPrimary,
        height: 1.45,
      ),
    );
  }
}

class _BulletBlock implements _Block {
  _BulletBlock(this.items);

  final List<String> items;

  @override
  Widget build() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == items.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '•',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _stripInline(items[i]),
                    style: AppTypography.body.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NumberedBlock implements _Block {
  _NumberedBlock(this.items);

  final List<String> items;

  @override
  Widget build() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == items.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _stripInline(items[i]),
                      style: AppTypography.body.copyWith(height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _stripInline(String input) {
  return input
      .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (Match m) => m.group(1) ?? '')
      .replaceAllMapped(RegExp(r'\*(.+?)\*'), (Match m) => m.group(1) ?? '');
}
