import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── CONTENT ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              children: const [
                Text(
                  'Allow Location Access',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Aura uses your location to find products that can be delivered to you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── DIVIDER ──
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // ── BUTTON ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // close dialog
                await openAppSettings();     // open real mobile settings
              },
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
              child: const Text(
                'GO TO APP SETTINGS',
                style: TextStyle(
                  color: Color(0xFF4256D3),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showLocationPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => const LocationPermissionDialog(),
  );
}