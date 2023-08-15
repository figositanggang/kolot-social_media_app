import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kolot/components/text_button.dart';
import 'package:kolot/components/text_field.dart';
import 'package:kolot/pages/register_page.dart';

import 'package:kolot/resources/auth_method.dart';
import 'package:line_icons/line_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final key = GlobalKey<FormState>();
  bool isLoading = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void signIn() async {
    setState(() {
      isLoading = true;
    });

    if (key.currentState!.validate()) {
      await AuthMethods.signIn(
        context,
        email: email.text,
        password: password.text,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeListMethod("TextInput.hide");
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Icon(
                    LineIcons.twitter,
                    size: 100,
                  ),

                  SizedBox(height: 20),

                  // Email & Password
                  Column(
                    children: [
                      MyTextField(
                        controller: email,
                        hintText: "Email",
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => EmailValidator.validate(value!)
                            ? null
                            : "Masukkan email yang valid",
                      ),
                      SizedBox(height: 10),
                      MyTextField(
                        controller: password,
                        hintText: "Password",
                        obscureText: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Button
                  MyTextButton(
                    child: Center(
                      child:
                          isLoading ? LinearProgressIndicator() : Text("Login"),
                    ),
                    onTap: signIn,
                    padding: EdgeInsets.all(18),
                  ),

                  SizedBox(height: 10),

                  // New Member
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Belum Punya Akun?"),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            )),
                        child: Text(
                          " Daftar Sekarang",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
