import 'package:flutter/material.dart';

void showBanner(BuildContext context, String text, Duration duration) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: duration, content: Text(text)));