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

  /// Puts a drawer button in the start corner. Set it on the shell tabs: a tab
  /// is a destination, so its corner belongs to the drawer, while a pushed
  /// screen is a drill-down and its corner belongs to the back button.
  ///
  /// Ignored when no drawer is reachable, so a screen can ask for the button
  /// without first knowing how it was opened.
  final bool showMenu;

  /// Overrides what the drawer button does. Left null it opens whichever
  /// drawer is in reach — this screen's own, or the shell's.
  final VoidCallback? onMenuTap;

  final Widget? leading;

  final Widget? trailing;

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    // Resolved before our own Scaffold exists, so this finds the shell's — the
    // one actually holding the drawer when this screen is a tab.
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
              // Builder so Scaffold.of below resolves to the Scaffold above,
              // which is the one carrying `drawer` when the screen owns it.
              child: Builder(
                builder: (BuildContext barContext) => AppTopBar(
                  title: title,
                  onBack: showBack
                      ? onBack ?? () => Navigator.of(barContext).pop()
                      : null,
                  leading:
                      leading ??
                      _menuButton(barContext, hasHostDrawer, hasOwnDrawer, host),
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
