import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/profile_model.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/edit_profile_label.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({required this.profile, super.key});

  final ProfileModel profile;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _name = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.profile.email,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.profile.phone,
  );

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ProfileCubit cubit = context.read<ProfileCubit>();
    final NavigatorState navigator = Navigator.of(context);
    final String email = _email.text.trim();

    final bool isSaved = await cubit.updateProfile(
      fullName: _name.text.trim(),
      email: email.isEmpty ? null : email,
    );
    if (!mounted) return;

    if (isSaved) {
      AppToast.success(context, 'profile_updated'.tr());
      navigator.pop(true);
      return;
    }

    AppToast.error(
      context,
      (cubit.state.errorKey ?? 'something_went_wrong').tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color fill = Theme.of(
      context,
    ).colorScheme.tertiary.withValues(alpha: 0.4);

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: <Widget>[
          EditProfileLabel(text: 'full_name'.tr()),
          CustomTextField(
            controller: _name,
            filled: true,
            fillColour: fill,
            hintText: 'full_name'.tr(),
            validator: (String? value) => (value ?? '').trim().length < 3
                ? 'full_name_too_short'.tr()
                : null,
          ),

          SizedBox(height: 16.h),

          EditProfileLabel(text: 'email'.tr()),
          CustomTextField(
            controller: _email,
            filled: true,
            fillColour: fill,
            hintText: 'email'.tr(),
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),

          SizedBox(height: 16.h),

          EditProfileLabel(text: 'phone'.tr()),
          CustomTextField(
            controller: _phone,
            filled: true,
            fillColour: fill,
            readOnly: true,
            overrideValidator: true,
            textDirection: TextDirection.ltr,
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

          BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (ProfileState previous, ProfileState current) =>
                previous.isSaving != current.isSaving,
            builder: (BuildContext context, ProfileState state) => CustomButton(
              onPressed: _save,
              text: 'save_changes'.tr(),
              width: double.infinity,
              height: 46.h,
              isLoading: state.isSaving,
              threeRadius: 10.r,
              lastRadius: 10.r,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return null;

    return text.contains('@') && text.contains('.')
        ? null
        : 'email_invalid'.tr();
  }
}
