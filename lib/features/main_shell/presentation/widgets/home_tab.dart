import 'package:bilhikma/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (NotificationsState previous, NotificationsState current) =>
          previous.unreadCount != current.unreadCount,
      builder: (BuildContext context, NotificationsState state) => HomeScreen(
        unreadNotifications: state.unreadCount,
        onViewAllSubjects: () =>
            Navigator.of(context).pushNamed(AppRoutes.bookPreview),

        onRefreshNotifications: context.read<NotificationsCubit>().refresh,
      ),
    );
  }
}
