import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool isPassword;
  final bool isPhone;
  final bool isVisible;
  final String? hint;
  final int? maxLength;
  final String? initialValue;
  final IconData? icon;
  final VoidCallback? onIconPressed;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final TextAlign? textAlign;
  final Function(String)? onChanged;
  const BuildTextField({super.key,
    this.icon,
    this.controller,
    this.isPassword = false,
    this.isPhone = false,
    this.initialValue,
    this.isVisible = false,
    this.onIconPressed,
    this.suffixIcon,
    this.textAlign ,
    this.onChanged ,
    this.maxLength ,
    this.keyboardType = TextInputType.text,
  required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxLength,
      onChanged: onChanged,
      controller: controller,
      initialValue: initialValue,
      textAlign: textAlign ?? TextAlign.start ,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)),
        label: Text(hint!),
        prefixIcon: Icon(icon),
        suffixIcon: isPassword ?  IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onIconPressed) : suffixIcon,

      ),
    );
  }
}
