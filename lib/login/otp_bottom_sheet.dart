import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smm_power/bottom_navigation/bottom_nav.dart';
import 'package:smm_power/service/category_api_service.dart';
import 'package:smm_power/service/login_api_service.dart';

/// Shows the OTP bottom sheet and handles the full verify flow.
///
/// Call [OtpBottomSheet.show] after a successful sendOtp API response.
class OtpBottomSheet {
  // ─────────────────────────────────────────────
  //  PUBLIC ENTRY POINT
  // ─────────────────────────────────────────────

  /// Displays the OTP bottom sheet.
  ///
  /// [onResend] is called when the user taps "Resend OTP" so the parent
  /// (LoginPage) can re-invoke the sendOtp flow.
  ///
  /// [otpControllers] and [otpFocusNodes] are owned by LoginPage so that
  /// the CodeAutoFill mixin's [codeUpdated()] can fill them directly when
  /// an SMS arrives.
  ///
  /// [onExternalVerifyReady] receives the sheet's internal [_verifyOtp]
  /// function so LoginPage can trigger auto-verify after SMS autofill.
  static Future<void> show({
    required BuildContext context,
    required String phoneNumber,
    required String token,
    required String uid,
    required String cusId,
    required String name,
    required String roleId,
    required String latitude,
    required String longitude,
    required String deviceId,
    required VoidCallback onResend,
    required void Function(void Function(void Function())) listenForCode,
    required List<TextEditingController> otpControllers,
    required List<FocusNode> otpFocusNodes,
    required void Function(VoidCallback verifyFn) onExternalVerifyReady,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => _OtpSheetContent(
        phoneNumber: phoneNumber,
        token: token,
        uid: uid,
        cusId: cusId,
        name: name,
        roleId: roleId,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        onResend: onResend,
        listenForCode: listenForCode,
        otpControllers: otpControllers,
        otpFocusNodes: otpFocusNodes,
        onExternalVerifyReady: onExternalVerifyReady,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PRIVATE STATEFUL WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _OtpSheetContent extends StatefulWidget {
  final String phoneNumber;
  final String token;
  final String uid;
  final String cusId;
  final String name;
  final String roleId;
  final String latitude;
  final String longitude;
  final String deviceId;
  final VoidCallback onResend;
  final void Function(void Function(void Function())) listenForCode;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> otpFocusNodes;
  final void Function(VoidCallback verifyFn) onExternalVerifyReady;

  const _OtpSheetContent({
    required this.phoneNumber,
    required this.token,
    required this.uid,
    required this.cusId,
    required this.name,
    required this.roleId,
    required this.latitude,
    required this.longitude,
    required this.deviceId,
    required this.onResend,
    required this.listenForCode,
    required this.otpControllers,
    required this.otpFocusNodes,
    required this.onExternalVerifyReady,
  });

  @override
  State<_OtpSheetContent> createState() => _OtpSheetContentState();
}

class _OtpSheetContentState extends State<_OtpSheetContent> {
  // ── OTP boxes — owned by LoginPage, passed in so CodeAutoFill mixin
  //    can fill them directly when an SMS arrives.
  List<TextEditingController> get _otpControllers => widget.otpControllers;
  List<FocusNode> get _otpFocusNodes => widget.otpFocusNodes;

  // ── resend countdown ──
  int _secondsRemaining = 60;
  Timer? _timer;

  // ── prevent double verify ──
  bool _isVerifying = false;

  // ── init guard ──
  bool _started = false;

  @override
  void initState() {
    super.initState();

    // Wire up the modalSetState callback so codeUpdated() can rebuild the sheet.
    widget.listenForCode((fn) => setState(fn));

    // Hand our _verifyOtp function back to LoginPage so codeUpdated()
    // can trigger auto-verify after SMS autofill.
    widget.onExternalVerifyReady(_verifyOtp);
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Controllers and FocusNodes are owned by LoginPage — do NOT dispose here.
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  TIMER
  // ─────────────────────────────────────────────

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining == 0) {
        t.cancel();
      } else {
        _secondsRemaining--;
      }
      if (mounted) setState(() {});
    });
  }

  // ─────────────────────────────────────────────
  //  VERIFY OTP  (type:5002)
  // ─────────────────────────────────────────────

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    final enteredOtp = _otpControllers.map((c) => c.text).join();

    if (enteredOtp.length < 6) {
      _showSnackBar('Please enter the complete 6-digit OTP');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final data = await LoginApiService.verifyOtp(
        mobile: widget.phoneNumber,
        otp: enteredOtp,
        token: widget.token,
        latitude: widget.latitude,
        longitude: widget.longitude,
        deviceId: widget.deviceId,
      );

      if (data['error'] == false) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', widget.token);
        await prefs.setString('uid', widget.uid);
        await prefs.setString('cus_id', widget.cusId);
        await prefs.setString('name', widget.name);
        await prefs.setString('role_id', widget.roleId);
        await prefs.setString('mobile', widget.phoneNumber);
        await prefs.setBool('is_logged_in', true);

        CategoryApiService.preloadAll();

        _timer?.cancel();

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainScaffold(
              mobileNumber: widget.phoneNumber,
            ),
          ),
              (route) => false,
        );
      } else {
        setState(() => _isVerifying = false);
        _showSnackBar(data['message'] ?? 'Invalid OTP. Please try again.');
        for (final c in _otpControllers) c.clear();
        _otpFocusNodes[0].requestFocus();
      }
    } catch (e) {
      print('VERIFY ERROR: $e');
      setState(() => _isVerifying = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final otpBoxWidth = (sw - 80) / 6;

    // One-time initialisation after first frame
    if (!_started) {
      _started = true;
      _startTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _otpFocusNodes[0].canRequestFocus) {
          _otpFocusNodes[0].requestFocus();
        }
      });
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
            // ── Title ──────────────────────────────────────────
            Text(
              'Verify with OTP',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: sw * 0.04,
              ),
            ),

            SizedBox(height: sh * 0.012),

            Center(
              child: Image.asset(
                'assets/login/otp.png',
                height: sh * 0.12,
              ),
            ),

            SizedBox(height: sh * 0.024),

            // ── Sub-text ────────────────────────────────────────
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: const Color(0xff6c6c6c),
                  fontSize: sw * 0.030,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
                children: [
                  const TextSpan(text: "Enter the OTP sent to\n"),
                  TextSpan(
                    text: "+91 ${widget.phoneNumber}",
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

            // ── OTP boxes ───────────────────────────────────────
            AutofillGroup(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: otpBoxWidth,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      autofillHints: index == 0
                          ? const [AutofillHints.oneTimeCode]
                          : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(fontSize: sw * 0.040),
                      decoration: const InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0XFF52B157)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Color(0XFF52B157), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _otpFocusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _otpFocusNodes[index - 1].requestFocus();
                        }
                        setState(() {});

                        // Auto-verify when all 6 filled manually
                        final filled =
                        _otpControllers.map((c) => c.text).join();
                        if (filled.length == 6 && !_isVerifying) {
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) _verifyOtp();
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: sh * 0.010),

            // ── Resend + countdown ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _secondsRemaining == 0
                      ? () {
                    Navigator.pop(context);
                    widget.onResend();
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
                  "00:${_secondsRemaining.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: const Color(0XFF52B157),
                    fontWeight: FontWeight.w400,
                    fontSize: sw * 0.030,
                  ),
                ),
              ],
            ),

            SizedBox(height: sh * 0.024),

            // ── Verify button ───────────────────────────────────
            Center(
              child: SizedBox(
                width: sw * 0.72,
                height: sh * 0.065,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
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
  }
}