// ignore_for_file: must_be_immutable, body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kolot/provider/text_field_provider.dart';
import 'package:provider/provider.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  bool obscureText;
  String? Function(String?)? validator = (a) {};
  TextInputType? keyboardType;
  List<TextInputFormatter>? inputFormatters;

  MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final obscureProv = Provider.of<TextFieldProvider>(context);

    return TextFormField(
      keyboardType: keyboardType ?? null,
      validator: validator,
      controller: controller,
      maxLines: obscureText == false ? null : 1,
      style: TextStyle(color: Colors.white),
      obscureText: obscureText == true ? obscureProv.obscure : obscureText,
      decoration: InputDecoration(
        errorMaxLines: 3,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        labelText: hintText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(.5)),
        focusColor: Colors.blue,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        suffixIcon: obscureText == true
            ? IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: obscureProv.obscure == false
                      ? Colors.blue
                      : const Color.fromARGB(255, 15, 68, 112),
                ),
                onPressed: () {
                  obscureProv.obscure = !obscureProv.obscure;
                },
              )
            : null,
      ),
      inputFormatters: inputFormatters ?? [],
      textCapitalization: TextCapitalization.none,
    );
  }
}
