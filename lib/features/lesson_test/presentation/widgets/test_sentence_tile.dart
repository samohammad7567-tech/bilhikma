import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import 'test_audio_button.dart';
import 'test_html_text.dart';
import 'test_media_image.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestSentenceTile extends StatelessWidget {
  const TestSentenceTile({
    required this.text,
    required this.index,
    super.key,
    this.imageUrl,
    this.audioUrl,
  });

  final String text;
  final int index;
  final String? imageUrl;
  final String? audioUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? image = _present(imageUrl);
    final String? audio = _present(audioUrl);
    final bool hasText = text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (12).w(context),
        vertical: (12).h(context),
      ),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular((10).r(context)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ReorderableDragStartListener(
              index: index,
              child: Row(
                children: <Widget>[
                  if (image != null) _image(context, image),
                  if (image != null && hasText) SizedBox(width: (10).w(context)),
                  if (hasText)
                    Expanded(
                      child: TestHtmlText(
                        text,
                        style: AppTheme.styles(context)
                            .cardBlurb
                            .copyWith(color: colors.onSurface),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (audio != null) ...<Widget>[
            SizedBox(width: (4).w(context)),
            TestAudioButton(url: audio),
          ],
          SizedBox(width: (8).w(context)),
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: (20).r(context),
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(BuildContext context, String url) => Padding(
        padding: EdgeInsets.symmetric(vertical: (2).h(context)),
        child: SizedBox(
          width: (64).w(context),
          height: (64).h(context),
          child: TestMediaImage(
            url: url,
            radius: 10,
            padding: EdgeInsets.all((3).r(context)),
            elevated: false,
          ),
        ),
      );

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
