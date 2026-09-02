import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/profile_model.dart';
import '../../data/repos/profile_repo.dart';
import '../../../../core/widgets/app_toast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.profile, super.key});

  final ProfileModel profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfileRepo _repo = const ProfileRepo();

  late final TextEditingController _name = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.profile.email,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.profile.phone,
  );

  bool _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;

    setState(() => _isSaving = true);

    String messageKey;
    bool ok = false;

    try {
      await _repo.updateProfile(
        fullName: _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      );
      messageKey = 'profile_updated';
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

    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionScaffold(
      title: context.tr('edit_information'),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: <Widget>[
            _Label(text: 'full_name'.tr()),
            CustomTextField(
              controller: _name,
              filled: true,
              fillColour: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.4),
              hintText: 'full_name'.tr(),
              validator: (String? value) => (value ?? '').trim().length < 3
                  ? 'full_name_too_short'.tr()
                  : null,
            ),

            SizedBox(height: 16.h),

            _Label(text: 'email'.tr()),
            CustomTextField(
              controller: _email,
              filled: true,
              fillColour: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.4),
              hintText: 'email'.tr(),
              keyboardType: TextInputType.emailAddress,
              validator: (String? value) {
                final String text = (value ?? '').trim();
                if (text.isEmpty) return null;

                return text.contains('@') && text.contains('.')
                    ? null
                    : 'email_invalid'.tr();
              },
            ),

            SizedBox(height: 16.h),

            _Label(text: 'phone'.tr()),
            CustomTextField(
              controller: _phone,
              filled: true,
              fillColour: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.4),
              readOnly: true,
              overrideValidator: true,
              suffixIcon: Icon(Icons.lock_outline, size: 18.w),
            ),

            SizedBox(height: 6.h),
            Text(
              'phone_not_editable'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 28.h),

            CustomButton(
              onPressed: _save,
              text: 'save_changes'.tr(),
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
