import 'package:flutter/material.dart';

import '../widgets/drawer_content.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      width: screenWidth * 0.8 > 320 ? 320 : screenWidth * 0.8,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(),
      child: const DrawerContent(),
    );
  }
}
