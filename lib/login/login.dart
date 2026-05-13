import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smm_power/service/login_api_service.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:smm_power/login/otp_bottom_sheet.dart';

class Login_Page extends StatefulWidget {
  final String mobileNumber;
  const Login_Page({super.key, required this.mobileNumber});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> with CodeAutoFill {
  final TextEditingController _phoneController = TextEditingController();
  bool get _isPhoneFull => _phoneController.text.trim().length == 10;

  // ── session fields from login API (type:5001) ──
  String _token = '';
  String _uid = '';
  String _cusId = '';
  String _name = '';
  String _roleId = '';

  // ── location / device ──
  String _latitude = '';
  String _longitude = '';
  String _deviceId = '';

  // ── app signature ──
  String _appSignature = '';
  bool _isLoadingOtp = false;

  // ── bottom-sheet lifecycle flags ──
  bool _isBottomSheetOpen = false;

  // ── OTP controllers (held here so codeUpdated() can fill them) ──
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
  List.generate(6, (_) => FocusNode());

  // ── modalSetState handed in by OtpBottomSheet so codeUpdated can rebuild it ──
  void Function(void Function())? _modalSetState;

  // ── prevent double verify ──
  bool _isVerifying = false;

  // ─────────────────────────────────────────────
  //  LIFECYCLE
  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
    _fetchAppSignature();
  }

  @override
  void dispose() {
    cancel(); // CodeAutoFill mixin – cancels SMS listener
    _phoneController.dispose();
    _modalSetState = null;
    for (final c in otpControllers) c.dispose();
    for (final f in otpFocusNodes) f.dispose();
    super.dispose();
  }

  // ── fetch AND store app signature at startup ──
  Future<void> _fetchAppSignature() async {
    final sig = await SmsAutoFill().getAppSignature;
    _appSignature = sig ?? '';
    print('▶ APP SIGNATURE: $_appSignature');
  }

  // ─────────────────────────────────────────────
  //  CodeAutoFill MIXIN ← fires when SMS arrives
  // ─────────────────────────────────────────────

  @override
  void codeUpdated() {
    if (code == null || code!.length != 6) return;
    if (!mounted || !_isBottomSheetOpen) return;

    print('▶ SMS autofill received code: $code');
    for (int i = 0; i < 6; i++) {
      otpControllers[i].text = code![i];
    }

    // Schedule setState AFTER the current frame to avoid !_dirty assertion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isBottomSheetOpen) return;
      _modalSetState?.call(() {});

      // Auto-verify after boxes are painted
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _isBottomSheetOpen && !_isVerifying) {
          // Delegate to the sheet's verify by triggering via shared flag;
          // the sheet listens to _isVerifying and calls its own _verifyOtp.
          // Since verify lives inside OtpBottomSheet, we notify it via
          // the listenForCode callback mechanism (see _showOtpBottomSheet).
          _autoVerifyFromSms();
        }
      });
    });
  }

  // Called from codeUpdated after autofill to trigger verify in the sheet.
  // The sheet exposes its verify through the _externalVerify callback set
  // during _showOtpBottomSheet.
  VoidCallback? _externalVerify;

  void _autoVerifyFromSms() {
    _externalVerify?.call();
  }

  // ─────────────────────────────────────────────
  //  VALIDATION
  // ─────────────────────────────────────────────

  String? _validatePhone(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return 'Please enter your mobile number';
    if (phone.length != 10) return 'Enter valid 10-digit number';
    if (RegExp(r'^(\d)\1{9}$').hasMatch(phone))
      return 'Please enter valid number';
    if (!RegExp(r'^[6-9]').hasMatch(phone)) return 'Please enter valid number';
    return null;
  }

  // ─────────────────────────────────────────────
  //  STEP 1 – SEND OTP  (type:5001)
  // ─────────────────────────────────────────────

  Future<void> _onGetOtp() async {
    final error = _validatePhone(_phoneController.text);
    if (error != null) {
      _showSnackBar(error);
      return;
    }

    setState(() => _isLoadingOtp = true);

    try {
      // Device ID
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;

      // Location check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingOtp = false);
        _showSnackBar('Please enable location services');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingOtp = false);
          _showSnackBar('Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingOtp = false);
        _showSnackBar(
            'Location permission permanently denied. Enable from settings.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Location timeout. Please try again.'),
      );

      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();

      print('Device ID      : $_deviceId');
      print('Latitude       : $_latitude');
      print('Longitude      : $_longitude');
      print('App Signature  : $_appSignature');

      // Persist location + device
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('latitude', _latitude);
      await prefs.setString('longitude', _longitude);
      await prefs.setString('device_id', _deviceId);

      final data = await LoginApiService.sendOtp(
        mobile: _phoneController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        deviceId: _deviceId,
        appSignature: _appSignature,
      );

      if (data['error'] == false) {
        _token = data['token']?.toString() ?? '';
        _uid = data['uid']?.toString() ?? '';
        _cusId = data['cus_id']?.toString() ?? '';
        _name = data['name']?.toString() ?? '';
        _roleId = data['role_id']?.toString() ?? '';

        setState(() => _isLoadingOtp = false);
        listenForCode();

        _showOtpBottomSheet();
      } else {
        setState(() => _isLoadingOtp = false);
        _showSnackBar(data['error_msg'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('ERROR: $e');
      setState(() => _isLoadingOtp = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────
  //  SHOW OTP BOTTOM SHEET
  // ─────────────────────────────────────────────

  void _showOtpBottomSheet() {
    _isBottomSheetOpen = true;
    _isVerifying = false;
    _modalSetState = null;
    _externalVerify = null;
    for (final c in otpControllers) c.clear();

    OtpBottomSheet.show(
      context: context,
      phoneNumber: _phoneController.text.trim(),
      token: _token,
      uid: _uid,
      cusId: _cusId,
      name: _name,
      roleId: _roleId,
      latitude: _latitude,
      longitude: _longitude,
      deviceId: _deviceId,
      onResend: () {
        _isBottomSheetOpen = false;
        _modalSetState = null;
        _onGetOtp();
      },
      // The sheet calls this with its own setState and verify fn so
      // codeUpdated() in this mixin can push digits and trigger verify.
      listenForCode: (setSheetState) {
        _modalSetState = setSheetState;
      },
      onExternalVerifyReady: (verifyFn) {
        _externalVerify = verifyFn;
      },
      otpControllers: otpControllers,
      otpFocusNodes: otpFocusNodes,
    ).whenComplete(() {
      _isBottomSheetOpen = false;
      _modalSetState = null;
      _externalVerify = null;
    });
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

    final fieldWidth = sw * 0.85;
    final fieldHeight = sh * 0.056;
    final buttonHeight = sh * 0.056;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
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
                        'assets/login/smm_logo.jpeg',
                        width: sw * 0.38,
                        height: sh * 0.075,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.06),

                Image.asset(
                  'assets/login/login.png',
                  height: sh * 0.32,
                ),

                SizedBox(height: sh * 0.006),

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

  Widget _buildGetOtpButton(
      double sw, double fieldWidth, double buttonHeight) {
    return GestureDetector(
      onTap: _isLoadingOtp ? null : _onGetOtp,
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
        child: _isLoadingOtp
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(
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
