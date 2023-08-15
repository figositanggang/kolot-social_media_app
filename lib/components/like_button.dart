import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final void Function()? onTap;
  LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Icon(
          color: isLiked ? Colors.pink : Colors.grey,
          isLiked ? Icons.favorite : Icons.favorite_border,
          size: 30,
        ));
  }
}
