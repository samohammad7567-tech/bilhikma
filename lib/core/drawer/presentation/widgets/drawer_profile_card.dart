import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/ornamented_card.dart';
import 'drawer_profile_monogram.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class DrawerProfileCard extends StatelessWidget {
  const DrawerProfileCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.secondaryContainer;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular((14).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: OrnamentedCard(
          radius: 14,
          padding: EdgeInsets.symmetric(
            horizontal: (6).w(context),
            vertical: (6).h(context),
          ),
          child: Row(
            children: <Widget>[
              const DrawerProfileMonogram(avatarUrl: ''),

              SizedBox(width: (12).w(context)),

              Expanded(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  buildWhen: (ProfileState previous, ProfileState current) =>
                      previous.profile.name != current.profile.name,
                  builder: (BuildContext context, ProfileState state) => Text(
                    state.profile.name,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.styles(context).cardTitle.copyWith(
                      color: accent,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dashed,
                      decorationColor: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
