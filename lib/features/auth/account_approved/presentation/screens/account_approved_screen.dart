import 'package:flutter/material.dart';
import '../refactor/account_approved_body.dart';

class AccountApprovedScreen extends StatelessWidget {
  const AccountApprovedScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AccountApprovedBody(onContinue: onContinue),
    );
  }
}
