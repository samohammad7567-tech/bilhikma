import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'info_item.dart';
import 'info_title.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({required this.items, super.key});

  final List<InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (InfoItem item) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: InfoTile(item: item),
                    ),

                    if (item != items.last) ...<Widget>[
                      Divider(
                        height: 1.h,
                        thickness: 1.h,
                        color: colors.onSurface.withValues(alpha: 0.09),
                      ),
                    ],
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
