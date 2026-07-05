import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final bool loading;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: SizedBox(
        height: 44,
        child: Center(
          child: loading ? CircularProgressIndicator(color: Colors.white) : Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
