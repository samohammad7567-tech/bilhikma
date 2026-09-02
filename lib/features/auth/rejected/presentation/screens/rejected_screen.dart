import 'package:flutter/material.dart';
import '../refactor/rejected_body.dart';

class RejectedScreen extends StatelessWidget {
  const RejectedScreen({super.key, this.reason, this.onBackToLogin});

  final String? reason;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RejectedBody(reason: reason, onBackToLogin: onBackToLogin),
    );
  }
}
