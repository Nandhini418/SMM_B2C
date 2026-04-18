import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smm_power/profile/profile_store.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String mobileNumber;
  final String name;
  final String email;

  const EditProfileScreen({
    super.key,
    required this.mobileNumber,
    required this.name,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _mobileFocus = FocusNode();

  final ImagePicker _picker = ImagePicker();
  final _profileStore = ProfileStore.instance;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.name;
    _emailController.text = widget.email;
    _mobileController.text = widget.mobileNumber;

    _setupFocusBehavior(
      focusNode: _nameFocus,
      controller: _firstNameController,
      originalValue: widget.name,
    );

    _setupFocusBehavior(
      focusNode: _emailFocus,
      controller: _emailController,
      originalValue: widget.email,
    );

    _setupFocusBehavior(
      focusNode: _mobileFocus,
      controller: _mobileController,
      originalValue: widget.mobileNumber,
    );
  }

  /// Clears field on focus, restores original value on unfocus if empty
  void _setupFocusBehavior({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String originalValue,
  }) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // User tapped the field — clear so hint "Enter Name / Email / Number" shows
        if (controller.text == originalValue || controller.text.trim().isEmpty) {
          controller.clear();
        }
      } else {
        // User left the field — restore original value if nothing was typed
        if (controller.text.trim().isEmpty) {
          controller.text = originalValue;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (photo != null) {
      _profileStore.setImage(File(photo.path));
      setState(() {});
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4256D3)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4256D3)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Color(0xFF4256D3)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined,
                            color: Color(0xFF1565C0), size: 28),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Text('2',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 2),
              Transform.translate(
                offset: const Offset(0, -20),
                child: _buildHeader(),
              ),
              const SizedBox(height: 4),

              // User Name
              _buildFigmaField(
                label: "User Name",
                hint: "Enter Name",
                icon: Icons.person_outline,
                controller: _firstNameController,
                focusNode: _nameFocus,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                ],
                validator: (value) {
                  // During validation, if empty restore original and pass
                  if (value == null || value.isEmpty) return "Name is required";
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                    return "Only alphabets allowed";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              _buildFigmaField(
                label: "Email ID",
                hint: "Enter Email Id",
                icon: Icons.email_outlined,
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email is required";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return "Enter valid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Mobile
              _buildFigmaField(
                label: "Mobile Number",
                hint: "Enter Mobile Number",
                icon: Icons.phone_outlined,
                controller: _mobileController,
                focusNode: _mobileFocus,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mobile number required";
                  }
                  if (value.length != 10) return "Enter 10 digit number";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Address — OPTIONAL
              _buildFigmaField(
                label: "Address (Optional)",
                hint: "Enter Your Address",
                icon: Icons.apartment_outlined,
                controller: _addressController,
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4256D3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Before validating, restore originals for empty fields
                    if (_firstNameController.text.trim().isEmpty) {
                      _firstNameController.text = widget.name;
                    }
                    if (_emailController.text.trim().isEmpty) {
                      _emailController.text = widget.email;
                    }
                    if (_mobileController.text.trim().isEmpty) {
                      _mobileController.text = widget.mobileNumber;
                    }

                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, {
                        "name": _firstNameController.text.trim(),
                        "mobile": _mobileController.text.trim(),
                        "email": _emailController.text.trim(),
                      });
                    }
                  },
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final profileImage = _profileStore.profileImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF7B7575), width: 1),
                  ),
                  child: ClipOval(
                    child: profileImage != null
                        ? Image.file(profileImage,
                        width: 90, height: 90, fit: BoxFit.cover)
                        : const Center(
                      child: Icon(Icons.person,
                          color: Color(0xFFC3C3C3), size: 55),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    padding: const EdgeInsets.all(6),
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
                      height: 16,
                      width: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable field widget ─────────────────────────────────────────────────────

Widget _buildFigmaField({
  required String label,
  required String hint,
  required IconData icon,
  required TextEditingController controller,
  FocusNode? focusNode,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFF4256D3),
          fontWeight: FontWeight.w600,
          fontSize: 16
        ),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
          color: Color(0xFF817979),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
            color: Color(0xFF817979),
          ),
          counterText: "",
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF4256D3)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4256D3)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    ],
  );
}