import 'package:flutter/material.dart';

void navigateTo(BuildContext context, Widget page) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
}