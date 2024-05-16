import 'package:flutter/material.dart';

void showBanner(BuildContext context, String text, Duration duration) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      duration: duration, 
      content: Center(child: Text(text),)
    )
  );
}