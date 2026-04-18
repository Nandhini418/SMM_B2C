import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _pickedLocation = const LatLng(11.0168, 76.9558); // Coimbatore default
  final Set<Marker> _markers = {};
  String _addressPreview = 'Fetching your location...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _updateLocation(LatLng(position.latitude, position.longitude));
    } catch (_) {
      await _updateLocation(_pickedLocation);
    }
  }

  Future<void> _updateLocation(LatLng latLng) async {
    setState(() {
      _pickedLocation = latLng;
      _loading = true;
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('picked'),
        position: latLng,
      ));
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16)),
    );

    try {
      final placemarks = await placemarkFromCoordinates(
          latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _addressPreview =
          '${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}';
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _addressPreview = 'Unable to fetch address';
        _loading = false;
      });
    }
  }

  Future<Map<String, String>> _getAddressDetails() async {
    try {
      final placemarks = await placemarkFromCoordinates(
          _pickedLocation.latitude, _pickedLocation.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return {
          'locality':
          '${p.street ?? ''}, ${p.subLocality ?? ''}'.trim().replaceAll(RegExp(r',\s*$'), ''),
          'city': p.locality ?? '',
          'state': p.administrativeArea ?? '',
          'pincode': p.postalCode ?? '',
        };
      }
    } catch (_) {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 2),
                  blurRadius: 6)
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Color(0xFF1565C0)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Select Location',
                    style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Full screen map
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _pickedLocation, zoom: 15),
            onMapCreated: (c) {
              _mapController = c;
              // Animate to current location after map is ready
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                    CameraPosition(target: _pickedLocation, zoom: 16)),
              );
            },
            markers: _markers,
            onTap: _updateLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
          ),

          // Tap to move hint
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tap anywhere on the map to move the pin',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),

          // Bottom address card + OK button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, -3))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address preview
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFF1565C0), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _loading
                            ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Fetching address...',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey)),
                          ],
                        )
                            : Text(
                          _addressPreview,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // OK button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                        final details =
                        await _getAddressDetails();
                        if (mounted) {
                          Navigator.pop(context, details);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        disabledBackgroundColor:
                        const Color(0xFF1565C0).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'OK — Use this location',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}