// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:random_text_reveal/random_text_reveal.dart';

class LoadingText extends StatelessWidget {
  double? fontSize;

  LoadingText({super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    fontSize = 20;

    return Center(
      child: RandomTextReveal(
        text: "Loading",
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }
}
