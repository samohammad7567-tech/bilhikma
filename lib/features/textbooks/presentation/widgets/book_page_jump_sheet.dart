import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/sheet_handle.dart';

class BookPageJumpSheet extends StatefulWidget {
  const BookPageJumpSheet({
    required this.pageCount,
    required this.currentPage,
    required this.onSubmit,
    super.key,
  });

  final int pageCount;
  final int currentPage;
  final ValueChanged<int> onSubmit;

  @override
  State<BookPageJumpSheet> createState() => _BookPageJumpSheetState();
}

class _BookPageJumpSheetState extends State<BookPageJumpSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.currentPage}',
  );

  String? _errorKey;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final int? page = int.tryParse(_controller.text.trim());

    if (page == null || page < 1 || page > widget.pageCount) {
      setState(() => _errorKey = 'reader_page_out_of_range');
      return;
    }

    Navigator.of(context).pop();
    widget.onSubmit(page);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SheetHandle(),

        SizedBox(height: 12.h),

        Text(
          'reader_jump_to_page'.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppTheme.styles(context).cardTitle,
        ),

        SizedBox(height: 14.h),

        CustomTextField(
          controller: _controller,
          hintText: 'reader_page_range'.tr(
            namedArgs: <String, String>{'total': '${widget.pageCount}'},
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onFieldSubmitted: (_) => _submit(),
        ),

        if (_errorKey != null) ...<Widget>[
          SizedBox(height: 8.h),

          Text(
            _errorKey!.tr(
              namedArgs: <String, String>{'total': '${widget.pageCount}'},
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTheme.styles(context).cardCaption
                .copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],

        SizedBox(height: 16.h),

        CustomButton(
          onPressed: _submit,
          text: 'reader_go'.tr(),
          width: double.infinity,
          height: 46.h,
          threeRadius: 8.r,
          lastRadius: 8.r,
          elevation: 0,
        ),
      ],
    );
  }
}
