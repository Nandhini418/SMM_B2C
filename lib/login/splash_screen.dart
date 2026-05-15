import 'package:flutter/material.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smm_power/bottom_navigation/bottom_nav.dart';
import 'package:smm_power/login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // ─────────────────────────────────────────────
  //  APP STARTUP
  // ─────────────────────────────────────────────

  Future<void> _initializeApp() async {

    // Small delay for splash visibility
    await Future.delayed(const Duration(seconds: 2));

    // Check persistent login status
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      // Already logged in → go directly to Home Page
      final String mobileNumber = prefs.getString('mobile') ?? '';

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScaffold(
              mobileNumber: mobileNumber,
            ),
          ),
        );
      }
      return;
    }

    // First time / logged out → ask location permission then go to Login
    await _handleLocationPermission();

    // Navigate to Login Screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Login_Page(
            mobileNumber: '',
          ),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  //  LOCATION PERMISSION
  // ─────────────────────────────────────────────

  Future<void> _handleLocationPermission() async {

    // Check GPS enabled
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {

      // Open location settings
      await Geolocator.openLocationSettings();

      return;
    }

    // Check permission status
    LocationPermission permission =
    await Geolocator.checkPermission();

    // Ask permission
    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {

        _showSnackBar(
          'Location permission denied',
        );

        return;
      }
    }

    // Permanently denied
    if (permission == LocationPermission.deniedForever) {

      _showSnackBar(
        'Enable location permission from app settings',
      );

      await Geolocator.openAppSettings();

      return;
    }
  }

  // ─────────────────────────────────────────────
  //  SNACKBAR
  // ─────────────────────────────────────────────

  void _showSnackBar(String message) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {

    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Image.asset(
          'assets/login/smm.png',
          width: sw * 0.55,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}