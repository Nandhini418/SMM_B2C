import 'package:flutter/material.dart';
import 'cart_state.dart';
import 'cart.dart';
import 'package:smm_power/navigation_source.dart';

/// Call this from ProductDetailsScreen when user taps "Add Cart"
Future<void> showAddToCartSheet(
    BuildContext parentContext, {
      required CartItemModel item,
    }) async {
  final nav = Navigator.of(parentContext);
  final overlay = Overlay.of(parentContext);

  await showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddToCartSheet(
      item: item,
      nav: nav,
      overlay: overlay,
    ),
  );
}

class _AddToCartSheet extends StatelessWidget {
  final CartItemModel item;
  final NavigatorState nav;
  final OverlayState overlay;

  const _AddToCartSheet({
    required this.item,
    required this.nav,
    required this.overlay,
  });

  /// Renders the product image — supports both network URLs and local assets,
  /// with a fallback icon if loading fails or the path is empty.
  Widget _buildProductImage(double sw) {
    final path = item.imagePath.trim();

    if (path.isEmpty) {
      return _fallbackIcon(sw);
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4256D3),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _fallbackIcon(sw),
      );
    }

    // Local asset
    return Image.asset(
      path,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _fallbackIcon(sw),
    );
  }

  Widget _fallbackIcon(double sw) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: sw * 0.107,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(sw * 0.053, sh * 0.025, sw * 0.053, sh * 0.035),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── drag handle ──
          Container(
            width: sw * 0.107,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: sh * 0.025),

          // ── product row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sw * 0.213,
                height: sw * 0.213,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF897F7F)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: _buildProductImage(sw),
                ),
              ),
              SizedBox(width: sw * 0.040),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: sw * 0.043,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Row(children: [
                      Text(
                        '₹${item.price.toInt()}',
                        style: TextStyle(
                          fontSize: sw * 0.048,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(width: sw * 0.016),
                      if (item.originalPrice != item.price)
                        Text(
                          '₹${item.originalPrice.toInt()}',
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: const Color(0xFF999999),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ]),
                    SizedBox(height: sh * 0.005),
                    if (item.discountPercent > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.016,
                          vertical: sh * 0.003,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.discountPercent}% OFF',
                          style: TextStyle(
                            color: const Color(0xFF2E7D32),
                            fontSize: sw * 0.029,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.025),
          const Divider(color: Color(0xFFEEEEEE)),
          SizedBox(height: sh * 0.020),

          // ── delivery info ──
          Row(children: [
            const Icon(Icons.local_shipping_outlined,
                color: Color(0xFF4256D3), size: 20),
            SizedBox(width: sw * 0.021),
            Text(
              item.deliveryDate ?? 'Delivery by Mar 14, Sat',
              style: TextStyle(
                  fontSize: sw * 0.035, color: const Color(0xFF333333)),
            ),
          ]),

          SizedBox(height: sh * 0.025),

          // ── action buttons ──
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: sh * 0.017),
                  side: const BorderSide(color: Color(0xFF4256D3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: const Color(0xFF4256D3),
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: sw * 0.040),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  cartNotifier.addItem(item);
                  Navigator.pop(context);
                  _showToast(sw, sh);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283897),
                  padding: EdgeInsets.symmetric(vertical: sh * 0.017),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ]),

          SizedBox(height: mq.viewInsets.bottom),
        ],
      ),
    );
  }

  void _showToast(double sw, double sh) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _CartToast(
        sw: sw,
        sh: sh,
        onGoToCart: () {
          entry.remove();
          nav.push(
            MaterialPageRoute(
              builder: (_) => CartPage(source: NavigationSource.addCart),
            ),
          );
        },
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      if (entry.mounted) entry.remove();
    });
  }
}

// ── Custom toast widget ───────────────────────────────
class _CartToast extends StatefulWidget {
  final double sw;
  final double sh;
  final VoidCallback onGoToCart;
  final VoidCallback onDismiss;

  const _CartToast({
    required this.sw,
    required this.sh,
    required this.onGoToCart,
    required this.onDismiss,
  });

  @override
  State<_CartToast> createState() => _CartToastState();
}

class _CartToastState extends State<_CartToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;

    return Positioned(
      bottom: sh * 0.040,
      left: sw * 0.040,
      right: sw * 0.040,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.040,
              vertical: sh * 0.014,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF52B157), size: 20),
                SizedBox(width: sw * 0.021),
                Expanded(
                  child: Text(
                    'Item added to cart!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onGoToCart,
                  child: Text(
                    'Go to Cart',
                    style: TextStyle(
                      color: const Color(0xFFFFCC00),
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}