import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'info_item.dart';
import '../../../../../core/themes/app_theme.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({required this.item, super.key});

  final InfoItem item;

  @override
  Widget build(BuildContext context) {
    final double iconSize = 34.w;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      child: Row(
        children: <Widget>[
          Image.asset(
            item.iconAsset,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 27.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '${item.title}  ',
                    style: AppTheme.styles(context).bodyStrong.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  TextSpan(text: item.value),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
