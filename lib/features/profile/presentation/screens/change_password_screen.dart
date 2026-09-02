import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/repos/profile_repo.dart';
import '../../../../core/widgets/app_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfileRepo _repo = const ProfileRepo();

  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _isSaving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;

    setState(() => _isSaving = true);

    String messageKey;
    bool ok = false;

    try {
      await _repo.changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      messageKey = 'password_changed';
      ok = true;
    } on AppException catch (error) {
      messageKey = error.key;
    } catch (error) {
      messageKey = ErrorMapper.map(error);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      AppToast.success(context, messageKey.tr());
    } else {
      AppToast.error(context, messageKey.tr());
    }

    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionScaffold(
      title: context.tr('change_password'),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: <Widget>[
            _Label(text: 'current_password'.tr()),
            CustomTextField(
              controller: _current,
              filled: true,
              fillColour: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.4),
              obscureText: _obscure,
              hintText: 'current_password'.tr(),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: 18.w,
                ),
              ),
              validator: (String? value) =>
                  (value ?? '').isEmpty ? 'field_required'.tr() : null,
            ),

            SizedBox(height: 16.h),

            _Label(text: 'new_password'.tr()),
            CustomTextField(
              controller: _next,
              filled: true,
              fillColour: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.4),
              obscureText: _obscure,
              hintText: 'new_password'.tr(),
              validator: (String? value) {
                final String text = value ?? '';
                if (text.length < 8) return 'password_too_short'.tr();
                if (text == _current.text) return 'password_must_differ'.tr();
                return null;
              },
            ),

            SizedBox(height: 16.h),

            _Label(text: 'confirm_new_password'.tr()),
            CustomTextField(
              controller: _confirm,
              filled: true,
              fillColour: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.4),
              obscureText: _obscure,
              hintText: 'confirm_new_password'.tr(),
              validator: (String? value) =>
                  value != _next.text ? 'passwords_do_not_match'.tr() : null,
            ),

            SizedBox(height: 28.h),

            CustomButton(
              onPressed: _save,
              text: 'change_password'.tr(),
              width: double.infinity,
              height: 46.h,
              isLoading: _isSaving,
              threeRadius: 10.r,
              lastRadius: 10.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
