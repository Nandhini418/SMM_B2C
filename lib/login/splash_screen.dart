import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smm_power/login/login.dart'; // adjust path

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Login_Page(mobileNumber: ''),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/login/logo.png',
          width: sw * 0.55,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}