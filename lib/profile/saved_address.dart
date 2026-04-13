import 'package:flutter/material.dart';
import 'package:smm_power/home_screen/location1.dart';

class SavedAddressScreen extends StatefulWidget {
  const SavedAddressScreen({super.key});

  @override
  State<SavedAddressScreen> createState() => _SavedAddressScreenState();
}

class _SavedAddressScreenState extends State<SavedAddressScreen> {

  List<Map<String, String>> _addresses = [
    {
      "name": "Akhil",
      "address": "Irugur, Coimbatore",
      'number': '+91 9876543210'
    },
  ];

  int _selectedIndex = 0;

  void _showCustomMenu(BuildContext context, Offset position, int index) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: Colors.white, // ✅ white background
      elevation: 6,
      items: [
        PopupMenuItem(
          value: "edit",
          padding: EdgeInsets.zero,
          child: _menuItem(
            icon: Icons.edit,
            text: "Edit",
            color: Colors.black,
          ),
        ),

        // 🔥 Divider
        const PopupMenuDivider(height: 1),

        PopupMenuItem(
          value: "delete",
          padding: EdgeInsets.zero,
          child: _menuItem(
            icon: Icons.delete_outline,
            text: "Delete",
            color: Colors.red,
          ),
        ),
      ],
    );

    if (selected == "delete") {
      setState(() {
        _addresses.removeAt(index);

        if (_selectedIndex >= _addresses.length) {
          _selectedIndex = _addresses.length - 1;
        }
      });
    }

    if (selected == "edit") {
      // TODO: edit action
    }
  }

  Widget _menuItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.location_off_outlined,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            "No results found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
                offset: Offset(0, 2),
                blurRadius: 6,
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
                        color: Color(0xFF1565C0)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Saved Address',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ✅ BODY STARTS HERE
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocDark(),
                      ),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.add,
                          size: 20, color: Color(0xFF1565C0)),
                      SizedBox(width: 4),
                      Text(
                        "Add New",
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Expanded(
              child: _addresses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final addr = _addresses[index];

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 12,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.home_outlined, size: 22, color: Color(0xFF555555),),

                                    const SizedBox(width: 10),
                                    Text(
                                      addr["name"]!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    if (index == _selectedIndex)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE3F2FD),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          "Currently selected",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  addr["address"]!,
                                  style: const TextStyle(fontSize: 13),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  addr["number"]!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTapDown: (details) {
                              _showCustomMenu(context, details.globalPosition, index);
                            },
                            child: const Icon(Icons.more_horiz),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}