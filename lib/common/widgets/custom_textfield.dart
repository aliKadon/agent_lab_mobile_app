import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


import '../../utils/constants/app_enums.dart';
import '../../utils/constants/pallete.dart';

class CustomTextfield extends StatefulHookConsumerWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final InputDecoration? inputDecoration;
  final TextDirection? textDirection;
  final bool hasError;
  final bool showTextFieldBorder;
  final bool? readOnly;
  final FocusNode? focusNode;
  final String errorText;
  final TextInputType? textInputType;
  final double? radius;
  final double? maxHeight;
  final double? minHeight;
  final bool enabled;
  final bool obscureText;
  final bool isPasswordField;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final String? label;
  final Color? color;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? borderColor;
  final EdgeInsetsGeometry? contentPadding;
  final Function(PointerDownEvent)? onTapOutside;

  const CustomTextfield({
    super.key,
    this.controller,
    this.textDirection,
    this.inputDecoration,
    this.hintText,
    this.hintStyle,
    this.readOnly,
    this.onChanged,
    this.hasError = false,
    this.showTextFieldBorder = false,
    this.errorText = '',
    this.textInputType,
    this.enabled = true,
    this.obscureText = false,
    this.isPasswordField = false,
    this.focusNode,
    this.validator,
    this.label,
    this.color,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.maxHeight,
    this.minHeight,
    this.borderColor,
    this.radius,
    this.minLines,
    this.contentPadding,
    this.onTapOutside,
  });

  @override
  ConsumerState<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends ConsumerState<CustomTextfield> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final darkMode = true;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? 120.h,
        minHeight: widget.minHeight ?? 45.h,
      ),
      child: TextFormField(
        focusNode: widget.focusNode,
        onTapOutside: widget.onTapOutside ??
            (event) {
              widget.focusNode?.unfocus();
            },
        onChanged: (value) {
          // setState(() {
          // widget.controller!.text = value;
          // });
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        autofocus: false,
        readOnly: widget.readOnly ?? false,
        cursorColor:Pallete.dividerColor ,
        decoration: widget.inputDecoration ?? InputDecoration(
          filled: true,
          fillColor: widget.color ?? (Pallete.grey05 ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 30.r),
              borderSide: BorderSide(color: widget.borderColor ?? (widget.showTextFieldBorder ? Pallete.borderColor : Colors.transparent), width: widget.showTextFieldBorder ? 1 : 0)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 30.r),
              borderSide: BorderSide(color: widget.borderColor ?? (widget.showTextFieldBorder ? Pallete.borderColor : Colors.transparent), width: widget.showTextFieldBorder ? 1 : 0)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 50.r),
              borderSide: BorderSide(color: widget.borderColor ?? (widget.showTextFieldBorder ? Pallete.borderColor : Colors.transparent), width: widget.showTextFieldBorder ? 1 : 0)),
          hintStyle: widget.hintStyle ?? TextStyle(
            fontSize: 14.sp,
            color: Pallete.grey50,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          hintText: widget.hintText,
          labelText: widget.label,
          errorText: widget.hasError ? widget.errorText : null,
          suffixIcon: widget.suffixIcon,
          prefixIcon: widget.prefixIcon ?? const SizedBox.shrink(),
          prefixIconConstraints: BoxConstraints(
            minWidth: 18.w,
            minHeight: 18.h,
          ),
        ),
        textDirection: widget.textDirection ?? TextDirection.ltr,
        style: TextStyle(
          fontSize: 15.sp,
          color:  Pallete.dividerColor,
          fontWeight: FontWeight.w500,
        ),
        enabled: widget.enabled,
        controller: widget.controller,
        keyboardType: widget.textInputType,
        obscureText: widget.isPasswordField ? obscureText : widget.obscureText,
        validator: widget.validator,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
      ),
    );
  }
}
