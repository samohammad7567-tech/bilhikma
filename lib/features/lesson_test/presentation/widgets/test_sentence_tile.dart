import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import 'test_audio_button.dart';
import 'test_html_text.dart';
import 'test_media_image.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ReorderableDragStartListener(
              index: index,
              child: Row(
                children: <Widget>[
                  if (image != null) _image(image),
                  if (image != null && hasText) SizedBox(width: 10.w),
                  if (hasText)
                    Expanded(
                      child: TestHtmlText(
                        text,
                        style: AppTheme.styles(
                          context,
                        ).cardBlurb.copyWith(color: colors.onSurface),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (audio != null) ...<Widget>[
            SizedBox(width: 4.w),
            TestAudioButton(url: audio),
          ],

          SizedBox(width: 8.w),

          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 20.w,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(String url) => Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h),
    child: SizedBox(
      width: 64.w,
      height: 64.w,
      child: TestMediaImage(
        url: url,
        radius: 10,
        padding: EdgeInsets.all(3.w),
        elevated: false,
      ),
    ),
  );

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
