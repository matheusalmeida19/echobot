import 'package:echobot_application/screens/SignUp.dart';
import 'package:echobot_application/screens/login.dart';
import 'package:flutter/material.dart';

class Auth_Page extends StatefulWidget {
  Auth_Page({super.key});

  @override
  State<Auth_Page> createState() => _Auth_PageState();
}

class _Auth_PageState extends State<Auth_Page> {
  bool a = true;
  void to() {
    setState(() {
      a = !a;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (a) {
      return Login_Screen(show: to);
    } else {
      return SignUp_Screen(to);
    }
  }
}
