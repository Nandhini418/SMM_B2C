import 'package:flutter/material.dart';
import 'address_model.dart';
import 'address_store.dart';
import 'add_address_screen.dart';

class SavedAddressScreen extends StatefulWidget {
  const SavedAddressScreen({super.key});

  @override
  State<SavedAddressScreen> createState() => _SavedAddressScreenState();
}

class _SavedAddressScreenState extends State<SavedAddressScreen> {
  final _store = AddressStore.instance;

  Future<void> _goToAddAddress() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (result != null) {
      await _store.add(result);
      setState(() {});
    }
  }

  Future<void> _deleteAddress(int index) async {
    await _store.delete(index);
    setState(() {});
  }

  Future<void> _markDefault(int index) async {
    await _store.markDefault(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final addresses = _store.addresses;

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
                  offset: Offset(0, 6),
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
                        color: Color(0xFF4256D3)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Save Address',
                    style: TextStyle(
                        color: Color(0xFF4256D3),
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add New button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: _goToAddAddress,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child: Row(
                      children: const [
                        Icon(Icons.add, size: 20, color: Color(0xFF4256D3)),
                        SizedBox(width: 4),
                        Text('Add New',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4256D3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // List or empty state
            Expanded(
              child: addresses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  return _AddressCard(
                    address: addr,
                    onDelete: () => _deleteAddress(index),
                    onEdit: () async {
                      final result =
                      await Navigator.push<AddressModel>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddAddressScreen(existing: addr),
                        ),
                      );
                      if (result != null) {
                        await _store.update(index, result);
                        setState(() {});
                      }
                    },
                    onMarkDefault: addr.isDefault
                        ? null
                        : () => _markDefault(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 70, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No saved addresses',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          Text(
            'Tap "Add New" to add your first address',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onMarkDefault;

  const _AddressCard({
    required this.address,
    required this.onDelete,
    required this.onEdit,
    this.onMarkDefault,
  });

  String _formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFFB7B7B7)
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name row + DEFAULT badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/home.png',
                  height: 16,
                  width: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  address.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A832A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
        
            const SizedBox(height: 6),
        
            // Address details indented
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.shortAddress,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF555555), height: 1.4),
                ),
                const SizedBox(height: 3),
                Text(
                  '+91 ${_formatPhone(address.phone)}',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0XFF555555)),
                ),
                const SizedBox(height: 5),
                const Divider(
                  color: Color(0xFF999797),
                  thickness: 1,
                ),

                Row(
                  children: [
                    const SizedBox(width: 10),
                    _actionBtn('Delete', Color(0xFFDD0B0B), onDelete,),
                    const SizedBox(width: 50),
                    _actionBtn('Edit', const Color(0xFF0E1FD4), onEdit),
                    if (onMarkDefault != null) ...[
                      const SizedBox(width: 50),
                      _actionBtn('Mark default',
                          const Color(0xFF0D928B), onMarkDefault!),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }
}