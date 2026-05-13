import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _controller;
  bool _torchOn = false;
  bool _scanned = false;
  String? _scannedValue;

  // Animation for the scanning line
  late AnimationController _animController;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() {
      _scanned = true;
      _scannedValue = value;
    });

    _controller?.stop();
    _animController.stop();
    _showResultSheet(value);
  }

  void _showResultSheet(String value) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => _ResultSheet(
        value: value,
        onScanAgain: () {
          Navigator.pop(context);
          setState(() {
            _scanned = false;
            _scannedValue = null;
          });
          _controller?.start();
          _animController.repeat(reverse: true);
        },
        onClose: () {
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // close scanner
        },
      ),
    );
  }

  void _toggleTorch() async {
    await _controller?.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    // Scanner overlay cutout size
    final cutoutSize = sw * 0.70;
    final cutoutTop = (sh - cutoutSize) / 2 - sh * 0.05;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── CAMERA FEED ──────────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _controller!,
              onDetect: _onDetect,
            ),
          ),

          // ── DARK OVERLAY WITH CUTOUT ─────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _OverlayPainter(
                cutoutSize: cutoutSize,
                cutoutTop: cutoutTop,
                sw: sw,
                sh: sh,
              ),
            ),
          ),

          // ── SCANNING LINE (animated) ──────────────────
          if (!_scanned)
            Positioned(
              left: (sw - cutoutSize) / 2 + 4,
              top: cutoutTop + 4,
              width: cutoutSize - 8,
              height: cutoutSize - 8,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _scanLineAnim,
                  builder: (_, __) {
                    return Align(
                      alignment: Alignment(0, (_scanLineAnim.value * 2) - 1),
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF52B157).withOpacity(0.8),
                              const Color(0xFF52B157),
                              const Color(0xFF52B157).withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF52B157).withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // ── CORNER BRACKETS ──────────────────────────
          Positioned(
            left: (sw - cutoutSize) / 2,
            top: cutoutTop,
            child: _CornerBrackets(size: cutoutSize),
          ),

          // ── APP BAR ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.043,
                    vertical: sh * 0.012,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: sw * 0.096,
                          height: sw * 0.096,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: sw * 0.056,
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.037),
                      Text(
                        'QR Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.050,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Torch toggle
                      GestureDetector(
                        onTap: _toggleTorch,
                        child: Container(
                          width: sw * 0.096,
                          height: sw * 0.096,
                          decoration: BoxDecoration(
                            color: _torchOn
                                ? const Color(0xFF52B157).withOpacity(0.85)
                                : Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _torchOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: sw * 0.053,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── BOTTOM HINT ───────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: sh * 0.045),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: sw * 0.080,
                      ),
                      SizedBox(height: sh * 0.010),
                      Text(
                        'Point your camera at a QR code',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: sw * 0.037,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: sh * 0.005),
                      Text(
                        'Scanning will happen automatically',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.50),
                          fontSize: sw * 0.032,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OVERLAY PAINTER ────────────────────────────────────
// Draws a semi-transparent overlay with a transparent cutout rectangle.
class _OverlayPainter extends CustomPainter {
  final double cutoutSize;
  final double cutoutTop;
  final double sw;
  final double sh;

  const _OverlayPainter({
    required this.cutoutSize,
    required this.cutoutTop,
    required this.sw,
    required this.sh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.62);

    final cutoutLeft = (sw - cutoutSize) / 2;
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize),
      const Radius.circular(16),
    );

    // Full screen path minus the cutout
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cutoutRect);
    final overlayPath =
    Path.combine(PathOperation.difference, fullPath, cutoutPath);

    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.cutoutSize != cutoutSize || old.cutoutTop != cutoutTop;
}

// ── CORNER BRACKETS ────────────────────────────────────
class _CornerBrackets extends StatelessWidget {
  final double size;
  const _CornerBrackets({required this.size});

  @override
  Widget build(BuildContext context) {
    const bracketLen = 28.0;
    const bracketWidth = 3.5;
    const color = Color(0xFF52B157);
    const radius = Radius.circular(4);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              painter: _BracketPainter(
                  corner: _Corner.topLeft,
                  len: bracketLen,
                  width: bracketWidth,
                  color: color,
                  radius: radius),
            ),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              painter: _BracketPainter(
                  corner: _Corner.topRight,
                  len: bracketLen,
                  width: bracketWidth,
                  color: color,
                  radius: radius),
            ),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              painter: _BracketPainter(
                  corner: _Corner.bottomLeft,
                  len: bracketLen,
                  width: bracketWidth,
                  color: color,
                  radius: radius),
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: CustomPaint(
              painter: _BracketPainter(
                  corner: _Corner.bottomRight,
                  len: bracketLen,
                  width: bracketWidth,
                  color: color,
                  radius: radius),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _BracketPainter extends CustomPainter {
  final _Corner corner;
  final double len;
  final double width;
  final Color color;
  final Radius radius;

  const _BracketPainter({
    required this.corner,
    required this.len,
    required this.width,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, len);
        path.lineTo(0, width / 2);
        path.lineTo(len, width / 2);
        break;
      case _Corner.topRight:
        path.moveTo(-len + width, width / 2);
        path.lineTo(0, width / 2);
        path.lineTo(0, len);
        break;
      case _Corner.bottomLeft:
        path.moveTo(0, -len + width);
        path.lineTo(0, 0);
        path.lineTo(len, 0);
        break;
      case _Corner.bottomRight:
        path.moveTo(-len + width, 0);
        path.lineTo(0, 0);
        path.lineTo(0, -len + width);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;

  @override
  Size get preferredSize => Size(len, len);
}

// ── RESULT BOTTOM SHEET ────────────────────────────────
class _ResultSheet extends StatelessWidget {
  final String value;
  final VoidCallback onScanAgain;
  final VoidCallback onClose;

  const _ResultSheet({
    required this.value,
    required this.onScanAgain,
    required this.onClose,
  });

  bool get _isUrl =>
      value.startsWith('http://') || value.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.043),
      padding: EdgeInsets.fromLTRB(
          sw * 0.053, sh * 0.025, sw * 0.053, sh * 0.030),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: sw * 0.107,
            height: 4,
            margin: EdgeInsets.only(bottom: sh * 0.020),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Success icon
          Container(
            width: sw * 0.160,
            height: sw * 0.160,
            decoration: const BoxDecoration(
              color: Color(0xFFEBFFEC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF52B157),
              size: 52,
            ),
          ),

          SizedBox(height: sh * 0.015),

          Text(
            'QR Code Scanned!',
            style: TextStyle(
              fontSize: sw * 0.050,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),

          SizedBox(height: sh * 0.008),

          Text(
            _isUrl ? 'URL detected' : 'Text detected',
            style: TextStyle(
              fontSize: sw * 0.034,
              color: const Color(0xFF888888),
            ),
          ),

          SizedBox(height: sh * 0.020),

          // Scanned value box
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.043, vertical: sh * 0.015),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sw * 0.037,
                color: _isUrl
                    ? const Color(0xFF4256D3)
                    : const Color(0xFF1A1A1A),
                decoration:
                _isUrl ? TextDecoration.underline : TextDecoration.none,
                decorationColor: const Color(0xFF4256D3),
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: sh * 0.025),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onScanAgain,
                  icon: const Icon(Icons.qr_code_scanner,
                      color: Color(0xFF4256D3)),
                  label: const Text(
                    'Scan Again',
                    style: TextStyle(color: Color(0xFF4256D3)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(vertical: sh * 0.016),
                    side:
                    const BorderSide(color: Color(0xFF4256D3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.043),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.done, color: Colors.white),
                  label: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF52B157),
                    padding:
                    EdgeInsets.symmetric(vertical: sh * 0.016),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.010),
        ],
      ),
    );
  }
}