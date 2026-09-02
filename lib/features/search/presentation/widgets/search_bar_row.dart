import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'search_query_field.dart';
import 'search_submit_button.dart';

class SearchBarRow extends StatefulWidget {
  const SearchBarRow({
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<SearchBarRow> createState() => _SearchBarRowState();
}

class _SearchBarRowState extends State<SearchBarRow> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(SearchBarRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SearchQueryField(
            controller: _controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),

        SizedBox(width: 12.w),

        SearchSubmitButton(onPressed: widget.onSubmitted),
      ],
    );
  }
}
