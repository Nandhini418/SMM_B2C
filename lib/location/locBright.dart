import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smm_power/location/location_service.dart';

class LocBright extends StatefulWidget {
  final String? initialAddress;
  const LocBright({super.key, this.initialAddress});

  @override
  State<LocBright> createState() => _LocBrightState();
}

class _LocBrightState extends State<LocBright> {
  late String _currentAddress;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.initialAddress ?? 'Search by area , name , street.';
    _searchController = TextEditingController(text: widget.initialAddress);
  }

  void _handleLocation() async {
    await LocationService.handleLocationAction(context, (address) {
      setState(() {
        _currentAddress = address;
        _searchController.text = address;
      });
      // You can also show a success snackbar or navigate to next screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location Found: $address')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Setting the status bar color to #4256D3 to match the screenshot
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF4256D3),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 40,
        title: const Text(
          'Add new address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: ListView(
        children: [
          // Map Area
          Container(
            height: 617, 
            width: double.infinity,
            color: const Color(0xFFF0F2FF), // Light blue background
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Stack(
              children: [
                // Search Bar
                Container(
                  height: 39,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: const Color(0xFF4256D3), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: _currentAddress,
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(bottom: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating "Use current location" button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: _handleLocation,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.my_location, color: Color(0xFF4256D3), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Use current location',
                            style: TextStyle(
                              color: Color(0xFF4256D3),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Info Section
          Container(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
            color: Colors.white,
            child: Column(
              children: [
                Image.asset(
                  'assets/illustration.png', 
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.location_off, size: 80, color: Colors.redAccent);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Unable to pin your location now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'It is taking longer than usual. Please check your internet connection and try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4256D3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
