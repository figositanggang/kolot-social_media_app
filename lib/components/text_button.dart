// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final Widget child;
  final Function()? onTap;
  EdgeInsetsGeometry? padding;
  MyTextButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.black.withOpacity(.5),
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue,
        ),
        padding: padding ?? EdgeInsets.all(0),
        child: child,
      ),
    );
  }
}
