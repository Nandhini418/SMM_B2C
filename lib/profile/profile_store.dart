import 'dart:io';
import 'package:flutter/material.dart';

/// Shared in-memory store for profile data.
/// Lives as long as the app process — cleared on app kill.
class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  File? profileImage;

  void setImage(File image) {
    profileImage = image;
    notifyListeners();
  }

  void clearImage() {
    profileImage = null;
    notifyListeners();
  }
}