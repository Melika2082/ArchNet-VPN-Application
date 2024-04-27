import 'package:archnet/textFormFields/password_text_form_field.dart';
import 'package:archnet/textFormFields/email_text_form_field.dart';
import 'package:archnet/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Color passwordColor = Colors.white;
  final Color emailColor = Colors.white;
  final formKey = GlobalKey<FormState>();
  final String errorMessage = '';

  bool inAsyncCallProcess = false;
  bool isApiProcess = false;
  bool obscureText = true;
  bool isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  Future<void> attemptLogin() async {
    setState(() {
      isLoading = true;
    });

    var box = await Hive.openBox('userBox');

    try {
      var res = await http.post(
        Uri.parse(
          'https://hub.archnets.com/api/v2/client/token',
        ),
        headers: {
          'XMPus-API-Token': '15dde8524a8b998932564e11b3bd5fe5',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'email': emailController.text,
            'passwd': passwordController.text,
          },
        ),
      );
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        if (response['status'] == 'success') {
          await box.put(
            'token',
            response['data']['token'],
          );
          await box.put('email', emailController.text);
          await box.put('password', passwordController.text);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const HomeScreen();
                },
              ),
            );
          }
        }
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'خطا در هنگام ورود به حساب کاربری',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'vasir',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              content: const Text(
                'آدرس ایمیل یا رمز عبور اشتباه است',
                style: TextStyle(
                  fontFamily: 'vasir',
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Column(
                      children: [
                        Divider(
                          color: Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'متوجه شدم',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'vasir',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // print('Failed to send HTTP request: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 17, 24, 40),
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 2 / 1.8,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 40),
                EmailTextFormField(emailController, emailColor),
                const SizedBox(height: 20),
                PasswordTextFormField(
                  passwordController,
                  passwordColor,
                  obscureText,
                  _togglePasswordVisibility,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: attemptLogin,
                    child: isLoading
                        ? const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 17, 24, 40),
                              ),
                            ),
                          )
                        : const Text(
                            'ورود به حساب کاربری',
                            style: TextStyle(
                              color: Color.fromARGB(255, 17, 24, 40),
                              fontSize: 18,
                              fontFamily: 'vazir',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: errorMessage == 'ورود به حساب کاربری موفقیت آمیز بود'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
