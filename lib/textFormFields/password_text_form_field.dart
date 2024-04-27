import 'package:flutter/material.dart';

class PasswordTextFormField extends StatelessWidget {
  final TextEditingController passwordController;
  final Color passwordColor;
  final bool obscureText;
  final Function _togglePasswordVisibility;

  const PasswordTextFormField(
    this.passwordController,
    this.passwordColor,
    this.obscureText,
    this._togglePasswordVisibility, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      controller: passwordController,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: ' رمز عبور ',
        labelStyle: TextStyle(
          color: passwordColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          borderSide: BorderSide(
            color: passwordColor,
            width: 2,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          borderSide: BorderSide(
            color: passwordColor,
            width: 2,
          ),
        ),
        suffixIcon: const Icon(
          Icons.lock,
          color: Colors.white,
        ),
        prefixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: passwordColor,
          ),
          onPressed: () => _togglePasswordVisibility(),
        ),
      ),
      style: TextStyle(
        color: passwordColor,
      ),
      validator: (value) {
        if (value == null || value.length < 3) {
          return 'رمز عبور باید حداقل سه رقم باشد.';
        }
        return null;
      },
    );
  }
}
