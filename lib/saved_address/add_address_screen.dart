import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'address_model.dart';
import 'map_picker_screen.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? existing;
  const AddAddressScreen({super.key, this.existing});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  String _addressType = 'Home';
  bool _makeDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameCtrl.text = e.name;
      _phoneCtrl.text = e.phone;
      _pincodeCtrl.text = e.pincode;
      _cityCtrl.text = e.city;
      _stateCtrl.text = e.state;
      _localityCtrl.text = e.locality;
      _flatCtrl.text = e.flatNo;
      _landmarkCtrl.text = e.landmark;
      _addressType = e.type;
      _makeDefault = e.isDefault;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _phoneCtrl, _pincodeCtrl, _cityCtrl,
      _stateCtrl, _localityCtrl, _flatCtrl, _landmarkCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onUseCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showPermissionDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }

    // Permission granted — go to map picker
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _localityCtrl.text = result['locality'] ?? '';
        _cityCtrl.text = result['city'] ?? '';
        _stateCtrl.text = result['state'] ?? '';
        _pincodeCtrl.text = result['pincode'] ?? '';
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Allow Location Access',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    'Aura uses your location to find products that can be delivered to you',
                    style:
                    TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                AppSettings.openAppSettings(
                    type: AppSettingsType.location);
              },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: const Color(0xFF1565C0),
              ),
              child: const Text(
                'GO TO APP SETTINGS',
                style: TextStyle(
                    fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;

    final address = AddressModel(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      locality: _localityCtrl.text.trim(),
      flatNo: _flatCtrl.text.trim(),
      landmark: _landmarkCtrl.text.trim(),
      type: _addressType,
      isDefault: _makeDefault,
    );

    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

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
                  offset: Offset(0, 2),
                  blurRadius: 6)
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Color(0xFF1565C0)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        isEditing ? 'Edit Address' : 'Add Address',
                        style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Contact Info ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Contact Info'),
                  GestureDetector(
                    onTap: _onUseCurrentLocation,
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, size: 16, color: Color(0xFF11228F)),
                        SizedBox(width: 6),
                        Text(
                          'Use current Location',
                          style: TextStyle(
                            color: Color(0xFF11228F),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(_nameCtrl, 'Name', required: true),
              const SizedBox(height: 16),
              _field(
                _phoneCtrl,
                'Phone Number(+91)',
                required: true,
                inputType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              const SizedBox(height: 28),

              // ── Address Info ──────────────────────────────
              _sectionTitle('Address Info'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _pincodeCtrl,
                      'Pincode',
                      required: true,
                      inputType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _field(_cityCtrl, 'City', required: true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(_stateCtrl, 'State', required: true),
              const SizedBox(height: 16),
              _field(_localityCtrl, 'Locality / Area / Street',
                  required: true),
              const SizedBox(height: 16),
              _field(_flatCtrl, 'Flat no / Building Name',
                  required: true),
              const SizedBox(height: 16),
              _field(_landmarkCtrl, 'Landmark (optional)'),

              const SizedBox(height: 28),

              // ── Type of Address ───────────────────────────
              _sectionTitle('Type of Address'),
              const SizedBox(height: 8),
              Row(
                children: ['Home', 'Office', 'Other'].map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: type,
                          groupValue: _addressType,
                          activeColor: const Color(0xFF1565C0),
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          onChanged: (v) =>
                              setState(() => _addressType = v!),
                        ),
                        Text(type,
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
              ),

              // Make default checkbox
              Row(
                children: [
                  Checkbox(
                    value: _makeDefault,
                    activeColor: const Color(0xFF1565C0),
                    materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    onChanged: (v) =>
                        setState(() => _makeDefault = v!),
                  ),
                  const Text('Make as default address',
                      style: TextStyle(fontSize: 14)),
                ],
              ),

              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Update Address' : 'Save Address',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Colors.black),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label, {
        bool required = false,
        TextInputType inputType = TextInputType.text,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(color: Color(0xFF4C4949),
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF464646),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        counterText: '',
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF999797)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      validator: required
          ? (v) {
        if (v == null || v.trim().isEmpty) {
          return '$label is required';
        }
        if (label.contains('Phone') && v.trim().length < 10) {
          return 'Enter a valid 10-digit number';
        }
        if (label.contains('Pincode') && v.trim().length < 6) {
          return 'Enter a valid 6-digit pincode';
        }
        return null;
      }
          : null,
    );
  }
}