import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Minimal Markdown renderer for Learn articles (headings, paragraphs, bullets).
///
/// Not a full Markdown engine — enough for draft and final clinical copy under
/// 150 words. Links in the body are plain text; Sources use [url_launcher].
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

  static List<_Block> _parse(String source) {
    final List<String> lines = source.replaceAll('\r\n', '\n').split('\n');
    final List<_Block> blocks = <_Block>[];
    final List<String> paragraph = <String>[];
    final List<String> bullets = <String>[];

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

    for (final String raw in lines) {
      final String line = raw.trimRight();
      final String trimmed = line.trim();
      if (trimmed.isEmpty) {
        flushBullets();
        flushParagraph();
        continue;
      }
      if (trimmed.startsWith('### ')) {
        flushBullets();
        flushParagraph();
        blocks.add(_HeadingBlock(trimmed.substring(4), 3));
        continue;
      }
      if (trimmed.startsWith('## ')) {
        flushBullets();
        flushParagraph();
        blocks.add(_HeadingBlock(trimmed.substring(3), 2));
        continue;
      }
      if (trimmed.startsWith('# ')) {
        flushBullets();
        flushParagraph();
        blocks.add(_HeadingBlock(trimmed.substring(2), 1));
        continue;
      }
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        flushParagraph();
        bullets.add(trimmed.substring(2).trim());
        continue;
      }
      flushBullets();
      paragraph.add(trimmed);
    }
    flushBullets();
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
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
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
        for (final String item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: Text(
                    _stripInline(item),
                    style: AppTypography.body,
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
      .replaceAllMapped(
        RegExp(r'\*\*(.+?)\*\*'),
        (Match m) => m.group(1) ?? '',
      )
      .replaceAllMapped(
        RegExp(r'\*(.+?)\*'),
        (Match m) => m.group(1) ?? '',
      );
}
