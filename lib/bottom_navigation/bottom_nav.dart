import 'package:flutter/material.dart';
import 'package:smm_power/bottom_navigation/category.dart';
import 'package:smm_power/bottom_navigation/profile.dart';
import 'package:smm_power/cart/cart.dart';
import 'package:smm_power/home_screen/home.dart';

class MainScaffold extends StatefulWidget {
  final String mobileNumber;
  final int initialTabIndex;
  const MainScaffold({super.key, required this.mobileNumber, this.initialTabIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  void switchToHome() => setState(() => _selectedIndex = 0);
  void switchToCart() => setState(() => _selectedIndex = 2);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(mobileNumber: widget.mobileNumber, onAddCartPressed: switchToCart),
      CategoryScreen(onBack: switchToHome),
      CartPage(onBack: switchToHome),
      ProfileScreen(mobileNumber: widget.mobileNumber),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.grid_view_rounded, 'label': 'Category'},
      {'icon': Icons.shopping_cart_rounded, 'label': 'Cart'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF293896),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: sh * 0.079, // ~64
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final selected = _selectedIndex == index;
              return _BottomNavItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                index: index,
                selected: selected,
                onTap: () => setState(() => _selectedIndex = index),
                sw: sw,
                sh: sh,
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final double sw;
  final double sh;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // Active indicator bar at top
            Container(
              height: sh * 0.007,  // ~6
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: selected ? const Color(0xFFFFFFFF) : Colors.transparent,
              ),
            ),

            const Spacer(),

            Icon(
              icon,
              color: selected ? const Color(0xFFFFFFFF) : const Color(0xFFC3C3C3),
              size: sw * 0.069, // ~26
            ),

            SizedBox(height: sh * 0.004),

            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: sw * 0.032,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}