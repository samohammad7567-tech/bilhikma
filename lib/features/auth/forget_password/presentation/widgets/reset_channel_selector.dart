import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/enums/reset_channel_enum.dart';
import 'reset_channel_tile.dart';

class ResetChannelSelector extends StatelessWidget {
  const ResetChannelSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ResetChannel selected;
  final ValueChanged<ResetChannel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ResetChannelTile(
          labelKey: 'via_email',
          isSelected: selected.isEmail,
          onTap: () => onChanged(ResetChannel.email),
        ),

        SizedBox(height: 10.h),

        ResetChannelTile(
          labelKey: 'via_sms',
          isSelected: !selected.isEmail,
          onTap: () => onChanged(ResetChannel.sms),
        ),
      ],
    );
  }
}
