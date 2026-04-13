import 'package:flutter/material.dart';
import 'package:smm_power/home_screen/notification.dart';
import 'package:smm_power/my_order/my_order.dart';
import 'package:smm_power/profile/edit_profile.dart';
import 'package:smm_power/profile/saved_address.dart';
import 'package:smm_power/profile/wish_list.dart';

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

  String formatNumber(String number) {
    if (number.isEmpty) return "";
    if (number.length <= 5) return number;
    return "${number.substring(0, 5)} ${number.substring(5)}";
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _LanguageSheet();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    mobileNumber = widget.mobileNumber;
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
                  SizedBox(height: sh * 0.07), // ~200
                  _buildLogoutButton(sw, sh),
                  SizedBox(height: sh * 0.062), // ~50
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double sw, double sh) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: sh * 0.074,   // ~60
        bottom: sh * 0.025, // ~20
      ),
      child: Column(
        children: [
          // Profile image with edit button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: sw * 0.240,   // ~90
                height: sw * 0.240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7B7575),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFFC3C3C3),
                    size: sw * 0.147, // ~55
                  ),
                ),
              ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(sw * 0.016),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/edit.png',
                    height: sw * 0.043, // ~16
                    width: sw * 0.043,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.015), // ~12

          // Name
          Text(
            'Hi $userName!',
            style: TextStyle(
              color: const Color(0xFF4256D3),
              fontSize: sw * 0.037,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: sh * 0.005), // ~4

          // Mobile Number
          Text(
            formatNumber(mobileNumber),
            style: TextStyle(
              color: const Color(0xFF4256D3),
              fontSize: sw * 0.037,
            ),
          ),

          SizedBox(height: sh * 0.025), // ~20

          // Divider
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
      {
        'title': 'Language',
        'onTap': () => _showLanguageBottomSheet(context),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.043), // ~16
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
                // Menu item
                InkWell(
                  onTap: () {
                    if (item['title'] == 'Language') {
                      _showLanguageBottomSheet(context);
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => item['screen'] as Widget,
                      ),
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
                      horizontal: sw * 0.043, // ~16
                      vertical: sh * 0.022,   // ~18
                    ),
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
                        Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF4256D3),
                          size: sw * 0.059,
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider (except last item)
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE71212),
            padding: EdgeInsets.symmetric(vertical: sh * 0.022), // ~18
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Grid
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
                onTap: () {
                  setState(() {
                    selectedLanguage = lang["sub"]!;
                  });
                },
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

                      // 📝 Text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang["title"]!,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            lang["sub"]!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 🔵 Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedLanguage);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)
                ),
                backgroundColor: const Color(0xFF4256D3),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}