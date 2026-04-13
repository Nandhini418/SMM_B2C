import 'package:flutter/material.dart';
import 'package:smm_power/wishlist_state.dart';
import 'package:smm_power/cart/cart_state.dart';
import 'package:smm_power/cart/add_cart.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  void initState() {
    super.initState();
    wishlistNotifier.addListener(_onWishlistChanged);
  }

  @override
  void dispose() {
    wishlistNotifier.removeListener(_onWishlistChanged);
    super.dispose();
  }

  void _onWishlistChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final items = wishlistNotifier.value;

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
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF1565C0)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Wishlist',
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
      body: items.isEmpty ? _buildEmptyState(sw, sh) : _buildGrid(sw, sh, items),
    );
  }

  Widget _buildEmptyState(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: sw * 0.24, color: const Color(0xFFD0D5F5)),
          SizedBox(height: sh * 0.025),
          Text(
            'No Wishlist Yet',
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: sw * 0.055,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: sh * 0.010),
          Text(
            'Tap the ♡ on any product to save it here.',
            style: TextStyle(color: const Color(0xFF888888), fontSize: sw * 0.037),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(double sw, double sh, List<WishlistItem> items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.040, vertical: sh * 0.016),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (ctx, i) => _WishlistCard(item: items[i], sw: sw, sh: sh),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final double sw;
  final double sh;

  const _WishlistCard({required this.item, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC8C8C8)),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heart (remove from wishlist) ──
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: sh * 0.008, right: sw * 0.027),
              child: GestureDetector(
                onTap: () => wishlistNotifier.toggle(item),
                child: const Icon(Icons.favorite, color: Colors.red, size: 22),
              ),
            ),
          ),

          // ── Product image ──
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sh * 0.006),
              child: Image.asset(
                item.image,
                height: sh * 0.100,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFC3C3C3)),

          // ── Details ──
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.027, sh * 0.007, sw * 0.027, sh * 0.007),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF4256D3),
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: sh * 0.004),
                Row(
                  children: [
                    Text(
                      '₹ ${item.price}',
                      style: TextStyle(
                        color: const Color(0xFF1A1A1A),
                        fontSize: sw * 0.037,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: sw * 0.016),
                    Text(
                      '₹ ${item.mrp}',
                      style: TextStyle(
                        color: const Color(0xFFA8A8A8),
                        fontSize: sw * 0.030,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.010),

                // ── Add to Cart button ──
                SizedBox(
                  width: double.infinity,
                  height: sh * 0.038,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showAddToCartSheet(
                        context,
                        item: CartItemModel(
                          name: item.name,
                          imagePath: item.image,
                          price: item.price.toDouble(),
                          originalPrice: item.mrp.toDouble(),
                          discountPercent:
                          (((item.mrp - item.price) / item.mrp) * 100).round(),
                          deliveryDate: 'Delivery by Mar 14, Sat',
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      size: sw * 0.037,
                      color: const Color(0xFF4256D3),
                    ),
                    label: Text(
                      'Add Cart',
                      style: TextStyle(
                        color: const Color(0xFF4256D3),
                        fontSize: sw * 0.030,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Color(0xFF4256D3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
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