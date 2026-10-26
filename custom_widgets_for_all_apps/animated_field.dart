/// A form field with a label above it, an animated focus border, and an error
/// that slides in without shoving the layout.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Colours fall back to the ambient [ColorScheme], so it looks native in any
/// theme without being coupled to one. Pairs with the other
/// `animated_*.dart` widgets in this folder.
///
/// It is a real [FormField], so it works inside a [Form] exactly as
/// [TextFormField] does — same `validator`, same `inputFormatters`, same
/// `GlobalKey<FormState>().validate()`:
///
/// ```dart
/// AnimatedField(
///   controller: emailController,
///   label: context.translate(LangKeys.email),
///   hint: context.translate(LangKeys.emailHint),
///   prefixIcon: Icons.alternate_email_rounded,
///   keyboardType: TextInputType.emailAddress,
///   validator: (String? value) => AppRegex.isEmailValid(value ?? '')
///       ? null
///       : context.translate(LangKeys.invalidEmail),
/// )
/// ```
///
/// A password, with the visibility toggle built in:
///
/// ```dart
/// AnimatedField(
///   controller: passwordController,
///   label: context.translate(LangKeys.password),
///   obscure: true,
///   prefixIcon: Icons.lock_outline_rounded,
///   validator: ...,
/// )
/// ```
///
/// A search box that can be cleared:
///
/// ```dart
/// AnimatedField(
///   hint: context.translate(LangKeys.search),
///   prefixIcon: Icons.search_rounded,
///   clearable: true,
///   onChanged: context.read<SearchCubit>().query,
/// )
/// ```
///
/// A read-only field that opens a picker, rather than a keyboard:
///
/// ```dart
/// AnimatedField(
///   controller: dateController,
///   label: context.translate(LangKeys.birthDate),
///   readOnly: true,
///   suffixIcon: Icons.calendar_today_rounded,
///   onTap: cubit.pickDate,
/// )
/// ```
///
/// ## Notes
///
/// * **Every string is passed in translated.** Labels, hints, helpers and the
///   strings a `validator` returns — the widget never translates, so the keys
///   stay in `LangKeys`.
/// * **The error does not shove the layout.** It fades in under the field
///   inside an [AnimatedSize], so the field below it glides rather than jumps.
/// * **Validation is Material's.** This hosts a [FormField], so
///   [AnimatedField.validator], `onSaved`, `reset()` and
///   [AutovalidateMode.onUserInteraction] behave exactly as on
///   [TextFormField] — but the error text is drawn here instead of by
///   [InputDecorator], which is what allows the label-above layout.
/// * **Owns nothing it was given.** A [AnimatedField.controller] or
///   [AnimatedField.focusNode] you pass in is yours to dispose; one it has to
///   create, it disposes itself.
/// * **RTL comes for free.** Label, prefix, text and suffix all sit in
///   direction-aware rows, so the layout mirrors itself in Arabic.
/// * Honours the platform "reduce motion" setting: focus and error transitions
///   become instant.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A labelled, validating text field. See the library docs above for usage.
class AnimatedField extends StatefulWidget {
  const AnimatedField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscure = false,
    this.clearable = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onSaved,
    this.onTap,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.radius = 14,
    this.fillColor,
    this.borderColor,
    this.focusColor,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
    this.duration = const Duration(milliseconds: 180),
    this.respectReducedMotion = true,
  });

  /// External controller. Yours to dispose. Omit it and the field keeps one of
  /// its own, seeded from [initialValue].
  final TextEditingController? controller;

  /// Starting text, when no [controller] is given.
  final String? initialValue;

  /// Label above the field. Pass an already-translated string.
  final String? label;

  /// Placeholder inside the field. Pass an already-translated string.
  final String? hint;

  /// Hint line under the field, shown while there is no error. Pass an
  /// already-translated string.
  final String? helper;

  /// Icon at the leading edge, tinted to match the focus state.
  final IconData? prefixIcon;

  /// Icon at the trailing edge. Overridden by the toggle [obscure] adds and by
  /// the button [clearable] adds.
  final IconData? suffixIcon;

  /// Tap handler for [suffixIcon].
  final VoidCallback? onSuffixTap;

  /// Whether the text starts hidden, with a visibility toggle in the suffix.
  final bool obscure;

  /// Whether a clear button appears in the suffix while there is text.
  final bool clearable;

  /// Returns a translated error message, or null when the value is valid.
  final String? Function(String?)? validator;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard action is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Called by [FormState.save].
  final void Function(String?)? onSaved;

  /// Tap handler for the field itself. With [readOnly] true, this is how you
  /// open a picker instead of a keyboard.
  final VoidCallback? onTap;

  /// When to validate. [AutovalidateMode.onUserInteraction] is the humane
  /// default: nothing is red until the user has had a go.
  final AutovalidateMode autovalidateMode;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Auto-capitalisation behaviour.
  final TextCapitalization textCapitalization;

  /// Input formatters — digit-only, length caps, masks.
  final List<TextInputFormatter>? inputFormatters;

  /// Autofill hints, so the platform can offer saved values.
  final Iterable<String>? autofillHints;

  /// External focus node. Yours to dispose.
  final FocusNode? focusNode;

  /// Whether the field accepts input. A disabled field is flattened and muted.
  final bool enabled;

  /// Whether the text can be selected but not edited.
  final bool readOnly;

  /// Whether the field takes focus when it first appears. Use sparingly — it
  /// throws up the keyboard before the user has looked at the screen.
  final bool autofocus;

  /// Maximum visible lines. Pass null for an unbounded multi-line field.
  final int? maxLines;

  /// Minimum visible lines, for a multi-line field.
  final int? minLines;

  /// Character cap. Shows a counter under the field and stops further input.
  final int? maxLength;

  /// Corner radius of the field.
  final double radius;

  /// Field background. Defaults to a faint tint of [ColorScheme.onSurface].
  final Color? fillColor;

  /// Resting border colour. Defaults to [ColorScheme.outlineVariant].
  final Color? borderColor;

  /// Focused border colour. Defaults to [ColorScheme.primary].
  final Color? focusColor;

  /// Padding inside the field, around the text.
  final EdgeInsetsGeometry contentPadding;

  /// Length of the focus and error transitions.
  final Duration duration;

  /// When true (the default), the platform "reduce motion" setting makes the
  /// transitions instant.
  final bool respectReducedMotion;

  @override
  State<AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<AnimatedField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;

  /// Captured in [build] so the controller listener can push programmatic
  /// text changes into the form's value, the way [TextFormField] does.
  FormFieldState<String>? _fieldState;

  late bool _obscured = widget.obscure;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialValue));

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(AnimatedField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(
        _handleControllerChanged,
      );
      _controller.addListener(_handleControllerChanged);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(
        _handleFocusChanged,
      );
      _focusNode.addListener(_handleFocusChanged);
      _focused = _focusNode.hasFocus;
    }

    if (widget.obscure != oldWidget.obscure) _obscured = widget.obscure;
  }

  @override
  void dispose() {
    // Only the listeners come off what was handed in; only what was created
    // here is disposed.
    (widget.controller ?? _ownedController)?.removeListener(
      _handleControllerChanged,
    );
    (widget.focusNode ?? _ownedFocusNode)?.removeListener(_handleFocusChanged);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted || _focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  /// Keeps the form's value in step with the text, including when a Cubit sets
  /// the text directly. The guard also filters out selection-only
  /// notifications, which fire far more often than edits.
  void _handleControllerChanged() {
    final FormFieldState<String>? state = _fieldState;
    if (state == null || state.value == _controller.text) return;
    state.didChange(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller?.text ?? widget.initialValue ?? '',
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      enabled: widget.enabled,
      builder: (FormFieldState<String> state) {
        _fieldState = state;
        return _layout(context, state);
      },
    );
  }

  Widget _layout(BuildContext context, FormFieldState<String> state) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final Duration duration =
        widget.respectReducedMotion && MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.duration;

    final bool hasError = state.hasError;
    final Color accent = widget.focusColor ?? scheme.primary;
    final Color resting = widget.borderColor ?? scheme.outlineVariant;

    final Color border = !widget.enabled
        ? scheme.outlineVariant
        : hasError
        ? scheme.error
        : _focused
        ? accent
        : resting;

    final String? label = widget.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          AnimatedDefaultTextStyle(
            duration: duration,
            curve: Curves.easeOut,
            style:
                theme.textTheme.labelLarge?.copyWith(
                  // The label leans into the accent while the field is focused,
                  // which is what ties the two together without a floating
                  // label's layout gymnastics.
                  color: hasError
                      ? scheme.error
                      : _focused
                      ? accent
                      : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ) ??
                const TextStyle(),
            child: Text(label),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: duration,
          curve: Curves.easeOut,
          padding: widget.contentPadding,
          decoration: BoxDecoration(
            color: widget.fillColor ?? _fill(scheme),
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: border,
              width: _focused || hasError ? 1.6 : 1,
            ),
          ),
          child: _row(theme, scheme, state, duration, border),
        ),
        _footer(theme, scheme, state, duration),
      ],
    );
  }

  Color _fill(ColorScheme scheme) => Color.alphaBlend(
    scheme.onSurface.withValues(alpha: widget.enabled ? 0.04 : 0.07),
    scheme.surface,
  );

  Widget _row(
    ThemeData theme,
    ColorScheme scheme,
    FormFieldState<String> state,
    Duration duration,
    Color border,
  ) {
    final IconData? prefix = widget.prefixIcon;
    final Widget? suffix = _suffix(scheme);
    final bool multiline = widget.maxLines != 1;

    return Row(
      // Icons sit beside the first line of a multi-line field, not beside its
      // middle.
      crossAxisAlignment: multiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: <Widget>[
        if (prefix != null) ...<Widget>[
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: widget.enabled
                  ? (state.hasError
                        ? scheme.error
                        : _focused
                        ? border
                        : scheme.onSurfaceVariant)
                  : scheme.outline,
            ),
            duration: duration,
            builder: (BuildContext context, Color? color, Widget? child) =>
                Icon(prefix, size: 20, color: color),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(child: _input(theme, scheme)),
        if (suffix != null) ...<Widget>[const SizedBox(width: 6), suffix],
      ],
    );
  }

  Widget _input(ThemeData theme, ColorScheme scheme) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscured,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      // An obscured field is always a single line; honouring maxLines here
      // would assert.
      maxLines: _obscured ? 1 : widget.maxLines,
      minLines: _obscured ? null : widget.minLines,
      maxLength: widget.maxLength,
      cursorColor: widget.focusColor ?? scheme.primary,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: widget.enabled ? scheme.onSurface : scheme.onSurfaceVariant,
      ),
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        // The container above draws the border, the padding and the fill, so
        // the input itself has to contribute none of its own.
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        // Counter and errors are drawn under the field by [_footer].
        counterText: '',
      ),
    );
  }

  Widget? _suffix(ColorScheme scheme) {
    if (widget.obscure) {
      return _iconButton(
        _obscured ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        () => setState(() => _obscured = !_obscured),
        scheme,
      );
    }

    if (widget.clearable && widget.enabled && _controller.text.isNotEmpty) {
      return _iconButton(Icons.close_rounded, () {
        _controller.clear();
        widget.onChanged?.call('');
      }, scheme);
    }

    final IconData? icon = widget.suffixIcon;
    if (icon == null) return null;

    final VoidCallback? onTap = widget.onSuffixTap;
    if (onTap == null) {
      return Icon(icon, size: 20, color: scheme.onSurfaceVariant);
    }

    return _iconButton(icon, onTap, scheme);
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, ColorScheme scheme) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      color: scheme.onSurfaceVariant,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      // Reachable without stretching the field's height.
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  Widget _footer(
    ThemeData theme,
    ColorScheme scheme,
    FormFieldState<String> state,
    Duration duration,
  ) {
    final String? error = state.errorText;
    final String? message = error ?? widget.helper;
    final int? maxLength = widget.maxLength;

    final Widget? counter = maxLength == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 6, left: 8, right: 8),
            child: Text(
              '${_controller.text.length}/$maxLength',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          );

    final Widget line = message == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: error != null ? scheme.error : scheme.onSurfaceVariant,
              ),
            ),
          );

    // Animating the height is what keeps the fields below from jumping as an
    // error appears and clears — but only when there is a duration to animate
    // over: a zero-length AnimatedSize re-dirties itself during its own
    // performLayout and throws.
    final Widget text = duration == Duration.zero
        ? line
        : AnimatedSize(
            duration: duration,
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child: line,
          );

    if (counter == null) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: text),
        counter,
      ],
    );
  }
}
