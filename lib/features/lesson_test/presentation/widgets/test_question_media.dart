import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_image_viewer.dart';
import 'test_audio_button.dart';
import 'test_media_image.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: GestureDetector(
        onTap: () => AppImageViewer.open(context, url: url),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: TestMediaImage(url: url, padding: EdgeInsets.all(8.w)),
        ),
      ),
    );
  }

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
