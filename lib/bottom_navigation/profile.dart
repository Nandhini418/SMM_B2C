import 'package:flutter/material.dart';
import 'package:smm_power/home_screen/notification.dart';
import 'package:smm_power/login/login.dart';
import 'package:smm_power/my_order/my_order.dart';
import 'package:smm_power/profile/edit_profile.dart';
import 'package:smm_power/saved_address/saved_address_screen.dart';
import 'package:smm_power/profile/wish_list.dart';
import 'package:smm_power/profile/profile_store.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:smm_power/smm_support/customer_support.dart';

class ProfileScreen extends StatefulWidget {
  final String mobileNumber;
  const ProfileScreen({super.key, required this.mobileNumber});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Smart!";
  String email = "abc@gmail.com";
  late String mobileNumber;

  final ImagePicker _picker = ImagePicker();
  final _profileStore = ProfileStore.instance;

  String formatNumber(String number) {
    if (number.isEmpty) return "";
    if (number.length <= 5) return number;
    return "${number.substring(0, 5)} ${number.substring(5)}";
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must click button
      builder: (context) {
        final sw = MediaQuery.of(context).size.width;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // 🔹 Title
                Text(
                  "Are you sure want to Logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sw * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Buttons Row
                Row(
                  children: [

                    // ❌ NO Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.black54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "NO",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ✅ YES Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Login_Page(mobileNumber: ''),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4256D3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "YES",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    mobileNumber = widget.mobileNumber;
    _profileStore.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _profileStore.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() => setState(() {});

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4256D3)),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (photo != null) {
                    _profileStore.setImage(File(photo.path));
                  }
                },
              ),
              ListTile(
                leading:
                const Icon(Icons.photo_library, color: Color(0xFF4256D3)),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (photo != null) {
                    _profileStore.setImage(File(photo.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _LanguageSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(sw, sh),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: sh * 0.001),
                  _buildMenuItems(context, sw, sh),
                  SizedBox(height: sh * 0.05),
                  _buildLogoutButton(sw, sh),
                  SizedBox(height: sh * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double sw, double sh) {
    final profileImage = _profileStore.profileImage;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: sh * 0.074,
        bottom: sh * 0.025,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: sw * 0.240,
                height: sw * 0.240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7B7575), width: 1),
                ),
                child: ClipOval(
                  child: profileImage != null
                      ? Image.file(
                    profileImage,
                    width: sw * 0.240,
                    height: sw * 0.240,
                    fit: BoxFit.cover,
                  )
                      : Center(
                    child: Icon(Icons.person,
                        color: const Color(0xFFC3C3C3),
                        size: sw * 0.147),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(sw * 0.016),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2)
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/edit.png',
                      height: sw * 0.043,
                      width: sw * 0.043,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'Hi $userName!',
            style: TextStyle(
              color: const Color(0xFF4256D3),
              fontSize: sw * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: sh * 0.005),
          Text(
            formatNumber(mobileNumber),
            style: TextStyle(
                color: const Color(0xFF4256D3), fontSize: sw * 0.04 ),
          ),
          SizedBox(height: sh * 0.025),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sw * 0.053),
            height: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, double sw, double sh) {
    final items = [
      {
        'title': 'Edit Profile',
        'screen': EditProfileScreen(
          mobileNumber: mobileNumber,
          name: userName,
          email: email,
        ),
      },
      {'title': 'My Orders', 'screen': MyOrdersPage()},
      {'title': 'Wishlist', 'screen': WishListScreen()},
      {'title': 'Saved Addresses', 'screen': SavedAddressScreen()},
      {'title': 'Notification Settings', 'screen': NotificationScreen()},
      {'title': 'Language', 'onTap': () => _showLanguageBottomSheet(context)},
      {'title': 'Help & Feedback', 'screen': CustomerSupportPage()},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.043),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    if (item['title'] == 'Language') {
                      _showLanguageBottomSheet(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => item['screen'] as Widget),
                    ).then((result) {
                      if (result != null) {
                        setState(() {
                          userName = result["name"];
                          mobileNumber = result["mobile"];
                          email = result["email"];
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.043, vertical: sh * 0.02),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: sw * 0.043,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: const Color(0xFF4256D3), size: sw * 0.059),
                      ],
                    ),
                  ),
                ),
                if (index != items.length - 1)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: sw * 0.043),
                    height: 1,
                    color: const Color(0xFFC5C5C5),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.043),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _showLogoutDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE71212),
            padding: EdgeInsets.symmetric(vertical: sh * 0.015),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            elevation: 0,
          ),
          child: Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.043,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Language Sheet ────────────────────────────────────────────────────────────

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet();

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  String selectedLanguage = "English";

  final List<Map<String, String>> languages = [
    {"title": "தமிழ்", "sub": "Tamil"},
    {"title": "తెలుగు", "sub": "Telugu"},
    {"title": "ಕನ್ನಡ", "sub": "Kannada"},
    {"title": "বাংলা", "sub": "Bengali"},
    {"title": "മലയാളം", "sub": "Malayalam"},
    {"title": "English", "sub": "English"},
    {"title": "ગુજરાતી", "sub": "Gujarati"},
    {"title": "हिन्दी", "sub": "Hindi"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = selectedLanguage == lang["sub"];
              return GestureDetector(
                onTap: () => setState(() => selectedLanguage = lang["sub"]!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4256D3)
                          : Colors.grey,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4256D3)
                                : Colors.grey,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4256D3),
                            ),
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang["title"]!,
                              style: const TextStyle(fontSize: 13)),
                          Text(lang["sub"]!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedLanguage),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                backgroundColor: const Color(0xFF4256D3),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}