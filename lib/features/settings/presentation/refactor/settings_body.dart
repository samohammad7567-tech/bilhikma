import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/settings_cubit.dart';
import '../../../../core/enums/settings_group_enum.dart';
import '../widgets/settings_body_section.dart';
import '../widgets/settings_language_card.dart';
import '../widgets/settings_theme_card.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: <Widget>[
            for (final SettingsGroup group in SettingsGroup.values) ...<Widget>[
              SettingsBodySection(group: group, state: state),
              SizedBox(height: 26.h),
            ],

            const SettingsLanguageCard(),

            SizedBox(height: 16.h),

            const SettingsThemeCard(),
          ],
        );
      },
    );
  }
}
