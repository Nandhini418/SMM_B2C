import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smm_power/bottom_navigation/profile.dart';

class EditProfileScreen extends StatefulWidget {
  final String mobileNumber;
  final String name;
  final String email;
  const EditProfileScreen({super.key,
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

  bool _isNameCleared = false;
  bool _isEmailCleared = false;
  bool _isMobileCleared = false;
  bool _isAddressCleared = false;

  @override
  void initState() {
    super.initState();

    _firstNameController.text = widget.name;
    _emailController.text = widget.email;
    _mobileController.text = widget.mobileNumber;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
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
                color: Color(0x1A000000), // subtle shadow
                offset: Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Back arrow
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF1565C0),
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const Spacer(),

                  // Cart icon with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF1565C0),
                          size: 28,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                offset: Offset(0, -20),
                child: _buildHeader(),
              ),
              const SizedBox(height: 4),

              _buildFigmaField(
                label: "User Name",
                hint: "Enter Name",
                icon: Icons.person_outline,
                controller: _firstNameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                ],

                clearOnTap: true,
                onFirstTap: () {
                  if (!_isNameCleared) {
                    _firstNameController.clear();
                    _isNameCleared = true;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name is required";
                  }
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                    return "Only alphabets allowed";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              _buildFigmaField(
                label: "Email ID",
                hint: "Enter Email Id",
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,

                clearOnTap: true,
                onFirstTap: () {
                  if (!_isEmailCleared) {
                    _emailController.clear();
                    _isEmailCleared = true;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return "Enter valid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              _buildFigmaField(
                label: "Mobile Number",
                hint: "Enter Mobile Number",
                icon: Icons.phone_outlined,
                controller: _mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                clearOnTap: true,
                onFirstTap: () {
                  if (!_isMobileCleared) {
                    _mobileController.clear();
                    _isMobileCleared = true;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mobile number required";
                  }
                  if (value.length != 10) {
                    return "Enter 10 digit number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildFigmaField(
                label: "Address",
                hint: "Enter Your Address",
                icon: Icons.apartment_outlined,
                controller: _addressController,
                maxLines: 3,
                clearOnTap: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Address is required";
                  }
                  return null;
                },
                onFirstTap: () {
                  if (!_isAddressCleared) {
                    _addressController.clear();
                    _isAddressCleared = true;
                  }
                },
              ),

              const SizedBox(height: 30),

              /// 🔵 SUBMIT BUTTON (Figma style)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4256D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
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
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      child: Column(
        children: [

          /// Profile Image with Edit Button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF7B7575),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Color(0xFFC3C3C3),
                    size: 55,
                  ),
                ),
              ),

              /// Edit Button (inside bottom-right)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/edit.png',
                      height: 16,
                      width: 16,
                      fit: BoxFit.contain,
                    )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OTP",
          style: TextStyle(
            color: Colors.green,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 38,
              height: 42,
              child: TextField(
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Color(0xFF4256D3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Color(0xFF4256D3), width: 1.5),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

Widget _buildFigmaField({
  required String label,
  required String hint,
  required IconData icon,
  required TextEditingController controller,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
  String? Function(String?)? validator, // ✅ ADD
  List<TextInputFormatter>? inputFormatters, // ✅ ADD
  bool clearOnTap = false,
  VoidCallback? onFirstTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4256D3),
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),

      TextFormField( // ✅ IMPORTANT (not TextField)
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        validator: validator,
        onTap: () {
          if (clearOnTap && onFirstTap != null) {
            onFirstTap();
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          counterText: "",
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF4256D3)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFFB7B7B7)),
          ),

          // ✅ Focus border
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4256D3)),
          ),

          // ✅ Error border
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4256D3)),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4256D3)),
          ),
        ),
      ),
    ],
  );
}