import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_image_viewer.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'test_audio_button.dart';

class TestQuestionMedia extends StatelessWidget {
  const TestQuestionMedia({super.key, this.imageUrl, this.audioUrl});

  final String? imageUrl;
  final String? audioUrl;

  @override
  Widget build(BuildContext context) {
    final String? image = _present(imageUrl);
    final String? audio = _present(audioUrl);

    if (image == null && audio == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (image != null) _image(context, image),
        if (image != null && audio != null) SizedBox(height: 10.h),
        if (audio != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TestAudioButton(url: audio),
          ),
      ],
    );
  }

  Widget _image(BuildContext context, String url) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => AppImageViewer.open(context, url: url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          color: colors.tertiaryContainer,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AppNetworkImage(
              url: url,
              fit: BoxFit.contain,
              errorWidget: Icon(
                Icons.broken_image_outlined,
                size: 32.r,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
