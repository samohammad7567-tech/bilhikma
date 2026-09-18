import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/educational_path_text.dart';
import '../../../../core/enums/profile_field_enum.dart';
import '../../data/models/profile_field_value.dart';
import '../../data/models/profile_model.dart';
import '../../../../core/themes/app_theme.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({required this.field, required this.profile, super.key});

  final ProfileField field;
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        children: <Widget>[
          AppIcon(asset: field.imagePath, size: 26.w, padding: EdgeInsets.zero),

          SizedBox(width: 10.w),

          Text(
            field.label.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).rowValue,
          ),

          SizedBox(width: 12.w),
          Expanded(
            child: _FieldValue(field: field, profile: profile),
          ),
        ],
      ),
    );
  }
}

class _FieldValue extends StatelessWidget {
  const _FieldValue({required this.field, required this.profile});

  final ProfileField field;
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final AppTextStyles styles = AppTheme.styles(context);
    final List<String> path = field.pathOf(profile);
    if (path.length > 1) {
      return EducationalPathText(
        segments: path,
        ancestorStyle: styles.rowValue,
        currentStyle: styles.rowTitle,
      );
    }

    return Text(
      path.isNotEmpty ? path.first : field.valueOf(profile),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: styles.rowTitle,
    );
  }
}
