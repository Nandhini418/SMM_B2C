import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

import 'package:smm_power/bottom_navigation/bottom_nav.dart';

class Login_Page extends StatefulWidget {
  final String mobileNumber;
  const Login_Page({super.key, required this.mobileNumber});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  final TextEditingController _phoneController = TextEditingController();

  bool get _isPhoneFull => _phoneController.text.trim().length == 10;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    timer?.cancel();
    for (var c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validatePhone(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return 'Please enter your mobile number';
    if (phone.length != 10) return 'Enter valid 10-digit number';
    if (RegExp(r'^(\d)\1{9}$').hasMatch(phone)) return 'Please enter valid number';
    if (!RegExp(r'^[6-9]').hasMatch(phone)) return 'Please enter valid number';
    return null;
  }

  void _onGetOtp() {
    final error = _validatePhone(_phoneController.text);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text(error, style: const TextStyle(color: Colors.white)),
        ),
      );
      return;
    }
    showOtpBottomSheet();
  }

  bool otpStarted = false;
  String generatedOtp = '';
  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  int secondsRemaining = 60;
  Timer? timer;

  void generateOtp() {
    final random = Random();
    generatedOtp = (100000 + random.nextInt(900000)).toString();
    for (int i = 0; i < 6; i++) {
      otpControllers[i].text = generatedOtp[i];
    }
  }

  void startTimer(VoidCallback updateUI) {
    secondsRemaining = 60;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining == 0) {
        t.cancel();
      } else {
        secondsRemaining--;
        updateUI();
      }
    });
  }

  void showOtpBottomSheet() {
    otpStarted = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final mq = MediaQuery.of(context);
        final sw = mq.size.width;
        final sh = mq.size.height;

        // 6 OTP boxes with equal spacing
        final otpBoxWidth = (sw - 80) / 6;

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!otpStarted) {
              otpStarted = true;
              startTimer(() => setModalState(() {}));
              generateOtp();
            }

            return Padding(
              padding: EdgeInsets.only(
                left: sw * 0.04,
                right: sw * 0.04,
                top: sh * 0.02,
                bottom: mq.viewInsets.bottom + sh * 0.02,
              ),
              child: SizedBox(
                height: sh * 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Verify with Otp',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: sw * 0.04,
                      ),
                    ),

                    SizedBox(height: sh * 0.012),

                    // OTP image
                    Center(
                      child: Image.asset(
                        'assets/login/otp.png',
                        height: sh * 0.12,
                      ),
                    ),

                    SizedBox(height: sh * 0.024),

                    // Info RichText
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: const Color(0xff6c6c6c),
                          fontSize: sw * 0.030,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          const TextSpan(
                              text:
                              "Waiting to automatically detect an OTP sent to\n"),
                          TextSpan(
                            text: "+91 ${_phoneController.text}",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: sw * 0.030,
                              color: const Color(0XFF5B5656),
                            ),
                          ),
                          const TextSpan(text: ". "),
                          TextSpan(
                            text: "Wrong Number?",
                            style: TextStyle(
                              color: const Color(0xff0A8378),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              fontSize: sw * 0.030,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.024),

                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: otpBoxWidth,
                          child: TextField(
                            controller: otpControllers[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: sw * 0.040),
                            decoration: const InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0XFF52B157)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0XFF52B157), width: 2),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: sh * 0.010),

                    // Resend + timer row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: secondsRemaining == 0
                              ? () {
                            startTimer(() => setModalState(() {}));
                          }
                              : null,
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: const Color(0XFF52B157),
                              fontSize: sw * 0.035,
                            ),
                          ),
                        ),
                        Text(
                          "00:${secondsRemaining.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: const Color(0XFF52B157),
                            fontWeight: FontWeight.w400,
                            fontSize: sw * 0.030,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.024),

                    // Verify button
                    Center(
                      child: SizedBox(
                        width: sw * 0.72,
                        height: sh * 0.065,
                        child: ElevatedButton(
                          // ✅ NEW CODE — clears entire stack
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => MainScaffold(
                                  mobileNumber: _phoneController.text.trim(),
                                ),
                              ),
                                  (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Verify",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.040,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    // Field sizing: ~85% of screen width, consistent height
    final fieldWidth = sw * 0.85;
    final fieldHeight = sh * 0.056;
    final buttonHeight = sh * 0.056;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Diagonal green header background
          ClipPath(
            clipper: DiagonalClipper(),
            child: Container(
              height: sh * 0.37,
              width: double.infinity,
              color: const Color(0xFF52B157),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: sh * 0.10),

                // Logo card
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: sw * 0.48,
                      height: sh * 0.091,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Positioned(
                      top: -2,
                      child: Image.asset(
                        'assets/login/logo.png',
                        width: sw * 0.38,
                        height: sh * 0.086,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.06),

                // Login illustration
                Image.asset(
                  'assets/login/login.png',
                  height: sh * 0.32,
                ),

                SizedBox(height: sh * 0.006),

                // Title
                Text(
                  'Enter Your Mobile Number',
                  style: TextStyle(
                    fontSize: sw * 0.053,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Prata',
                  ),
                ),

                SizedBox(height: sh * 0.025),
                _buildPhoneField(sw, sh, fieldWidth, fieldHeight),

                SizedBox(height: sh * 0.025),
                _buildGetOtpButton(sw, fieldWidth, buttonHeight),

                SizedBox(height: sh * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.10),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sw * 0.032,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                        children: const [
                          TextSpan(text: "By Continuing you agree to our\n"),
                          TextSpan(
                            text: "Terms and Conditions",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.049),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Phone field widget ──
  Widget _buildPhoneField(
      double sw, double sh, double fieldWidth, double fieldHeight) {
    return Container(
      width: fieldWidth,
      height: fieldHeight,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.027),
      decoration: BoxDecoration(
        color: const Color(0xffEEEEEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            '+91',
            style: TextStyle(
              fontSize: sw * 0.043,
              fontWeight: FontWeight.w400,
              color: const Color(0XFF454545),
            ),
          ),
          SizedBox(width: sw * 0.021),
          Container(
            height: sh * 0.031,
            width: 1,
            color: const Color(0XFF7C348D),
          ),
          SizedBox(width: sw * 0.021),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: sw * 0.038),
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'Your 10-Digit Mobile Number',
                hintStyle: TextStyle(
                  color: const Color(0XFF9D9B9B),
                  fontWeight: FontWeight.w400,
                  fontSize: sw * 0.032,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Get OTP button widget ──
  Widget _buildGetOtpButton(
      double sw, double fieldWidth, double buttonHeight) {
    return GestureDetector(
      onTap: _onGetOtp,
      child: Container(
        width: fieldWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: _isPhoneFull
              ? const Color(0xFF4CAF50)
              : Colors.green.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          'Get OTP',
          style: TextStyle(
            color: Colors.white,
            fontSize: sw * 0.043,
          ),
        ),
      ),
    );
  }
}

// ── Diagonal Clipper (unchanged) ──
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.50);
    path.lineTo(size.width * 0.20, size.height * 0.92);
    path.quadraticBezierTo(0, size.height, 0, size.height * 0.82);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}