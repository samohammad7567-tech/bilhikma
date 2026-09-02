import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/educational_path_text.dart';
import '../../../../core/widgets/ornamented_card.dart';

class InstitutionCard extends StatelessWidget {
  const InstitutionCard({
    required this.institution,
    this.path = const <String>[],
    super.key,
  });

  final String institution;

  /// The educational path, outermost first — stage, then any classes between,
  /// then the current semester. A single entry renders as plain text, which is
  /// the fallback when only the class name is known.
  final List<String> path;

  @override
  Widget build(BuildContext context) {
    return OrnamentedCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              institution,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bannerTitle,
            ),

            if (path.isNotEmpty) ...<Widget>[
              SizedBox(height: 4.h),
              EducationalPathText(segments: path),
            ],
          ],
        ),
      ),
    );
  }
}
