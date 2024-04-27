import 'package:flutter/material.dart';

class EmailTextFormField extends StatelessWidget {
  final TextEditingController emailController;
  final Color emailColor;

  const EmailTextFormField(this.emailController, this.emailColor, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: emailController,
      decoration: InputDecoration(
        suffixIcon: const Icon(
          Icons.email,
          color: Colors.white,
        ),
        labelText: ' آدرس ایمیل ',
        labelStyle: TextStyle(
          color: emailColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          borderSide: BorderSide(
            color: emailColor,
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
            color: emailColor,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(
        color: emailColor,
      ),
      validator: (value) {
        if (value == null || !value.contains('@')) {
          return 'آدرس ایمیل معتبر نمی باشد.';
        }
        return null;
      },
    );
  }
}
