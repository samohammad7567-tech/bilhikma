import 'package:flutter/material.dart';
import 'app_drawer_menu_button.dart';
import 'app_top_bar.dart';

class AppSectionScaffold extends StatelessWidget {
  const AppSectionScaffold({
    required this.title,
    required this.child,
    super.key,
    this.onBack,
    this.showBack = true,
    this.showMenu = false,
    this.onMenuTap,
    this.leading,
    this.trailing,
    this.drawer,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final bool showBack;
  final bool showMenu;
  final VoidCallback? onMenuTap;

  final Widget? leading;

  final Widget? trailing;

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final ScaffoldState? host = Scaffold.maybeOf(context);
    final bool hasHostDrawer = host?.hasDrawer ?? false;
    final bool hasOwnDrawer = drawer != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: drawer,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Builder(
                builder: (BuildContext barContext) => AppTopBar(
                  title: title,
                  onBack: showBack
                      ? onBack ?? () => Navigator.of(barContext).pop()
                      : null,
                  leading:
                      leading ??
                      _menuButton(
                        barContext,
                        hasHostDrawer,
                        hasOwnDrawer,
                        host,
                      ),
                  trailing: trailing,
                ),
              ),
            ),

            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget? _menuButton(
    BuildContext barContext,
    bool hasHostDrawer,
    bool hasOwnDrawer,
    ScaffoldState? host,
  ) {
    if (!showMenu || !(hasHostDrawer || hasOwnDrawer)) return null;

    return AppDrawerMenuButton(
      onTap:
          onMenuTap ??
          (hasOwnDrawer
              ? Scaffold.of(barContext).openDrawer
              : host!.openDrawer),
    );
  }
}
