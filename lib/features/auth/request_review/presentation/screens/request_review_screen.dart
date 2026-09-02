import 'package:flutter/material.dart';
import '../refactor/request_review_body.dart';

class RequestReviewScreen extends StatelessWidget {
  const RequestReviewScreen({
    required this.institution,
    required this.academicLevel,
    required this.phone,
    super.key,
    this.onBackToLogin,
  });

  final String institution;
  final String academicLevel;
  final String phone;

  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RequestReviewBody(
        institution: institution,
        academicLevel: academicLevel,
        phone: phone,
        onBackToLogin: onBackToLogin,
      ),
    );
  }
}
