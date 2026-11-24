import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/settings_cubit.dart';
import '../../../../core/enums/settings_group_enum.dart';
import '../widgets/settings_body_section.dart';
import '../widgets/settings_language_card.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        return ListView(
          padding: EdgeInsets.fromLTRB((16).w(context), (12).h(context), (16).w(context), (24).h(context)),
          children: <Widget>[
            for (final SettingsGroup group in SettingsGroup.values) ...<Widget>[
              SettingsBodySection(group: group, state: state),
              SizedBox(height: (26).h(context)),
            ],

            const SettingsLanguageCard(),

            SizedBox(height: (16).h(context)),
          ],
        );
      },
    );
  }
}
