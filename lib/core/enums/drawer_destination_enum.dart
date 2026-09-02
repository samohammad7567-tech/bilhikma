import 'package:flutter/material.dart';

enum DrawerDestination {
  account(
    label: 'student_account',
    icon: Icons.account_circle_outlined,
    group: 0,
  ),
  learningPaths(
    label: 'my_learning_paths',
    icon: Icons.track_changes_outlined,
    group: 0,
  ),
  saved(label: 'saved_items', icon: Icons.bookmark_border, group: 1),
  pictures(label: 'pictures', icon: Icons.image_outlined, group: 1),
  search(label: 'search_title', icon: Icons.search, group: 1),
  settings(label: 'settings', icon: Icons.settings_outlined, group: 1);

  const DrawerDestination({
    required this.label,
    required this.icon,
    required this.group,
  });
  final String label;

  final IconData icon;
  final int group;
}
