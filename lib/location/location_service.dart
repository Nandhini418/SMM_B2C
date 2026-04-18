import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:smm_power/location/locationPermissionDialog.dart';

class LocationService {
  static Future<void> handleLocationAction(BuildContext context, Function(String) onAddressFound) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services (GPS) are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If GPS is off, ask user to turn it on
      await Geolocator.openLocationSettings();
      return;
    }

    // 2. Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show our custom popup
        if (context.mounted) showLocationPermissionDialog(context);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, show our custom popup
      if (context.mounted) showLocationPermissionDialog(context);
      return;
    } 

    // 3. If we have permission and GPS is on, get the position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // 4. Convert Lat/Long to a real Address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.subLocality}, ${place.locality}";
        onAddressFound(address);
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }
}
