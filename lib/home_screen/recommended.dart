import 'package:flutter/material.dart';
import 'package:smm_power/category/product_details.dart';
import 'package:smm_power/wishlist_state.dart';

class RecommendedCard extends StatefulWidget {
  final String name;
  final int mrp;
  final int price;
  final String unit;
  final String image;
  final int? productId;

  const RecommendedCard({
    super.key,
    required this.name,
    required this.mrp,
    required this.price,
    required this.unit,
    required this.image,
    this.productId,
  });

  @override
  State<RecommendedCard> createState() => RecommendedCardState();
}

class RecommendedCardState extends State<RecommendedCard> {
  late WishlistItem _item;

  @override
  void initState() {
    super.initState();
    _item = WishlistItem(
      name: widget.name,
      mrp: widget.mrp,
      price: widget.price,
      unit: widget.unit,
      image: widget.image,
    );
    wishlistNotifier.addListener(_onWishlistChanged);
  }

  @override
  void dispose() {
    wishlistNotifier.removeListener(_onWishlistChanged);
    super.dispose();
  }

  void _onWishlistChanged() => setState(() {});

  /// Returns true when [image] is a network URL (http/https).
  /// Returns false for local asset paths.
  bool get _isNetworkImage =>
      widget.image.startsWith('http://') || widget.image.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final cardWidth = sw * 0.360;
    final isWishlisted = wishlistNotifier.isWishlisted(_item);

    return GestureDetector(
      onTap: () {
        if (widget.productId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(
                productId: widget.productId!,
                productName: widget.name,
              ),
            ),
          );
        }
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: sw * 0.032),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFC3C3C3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW: cracks icon (left) + wishlist (right) ──
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.013, sh * 0.006, sw * 0.021, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/home/cracks.png',
                    height: sh * 0.033,
                    width: sw * 0.080,
                  ),
                  GestureDetector(
                    onTap: () => wishlistNotifier.toggle(_item),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : const Color(0xFF4256D3),
                      size: sw * 0.053,
                    ),
                  ),
                ],
              ),
            ),

            // ── PRODUCT IMAGE — asset or network ──
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: sh * 0.000),
                child: widget.image.isEmpty
                    ? SizedBox(
                  height: sh * 0.086,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: sw * 0.10,
                      color: const Color(0xFFBDBDBD),
                    ),
                  ),
                )
                    : _isNetworkImage
                    ? Image.network(
                  widget.image,
                  height: sh * 0.086,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) =>
                  progress == null
                      ? child
                      : SizedBox(
                    height: sh * 0.086,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF52B157),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported_outlined,
                    size: sw * 0.10,
                    color: const Color(0xFFBDBDBD),
                  ),
                )
                    : Image.asset(
                  widget.image,
                  height: sh * 0.086,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: sh * 0.016),

            // ── DIVIDER LINE ──
            const Divider(height: 1, thickness: 1, color: Color(0xFFC3C3C3)),

            // ── PRODUCT DETAILS ──
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.021, sh * 0.007, sw * 0.021, sh * 0.010),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      color: const Color(0xFF1A1A1A),
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sh * 0.005),
                  Row(
                    children: [
                      Text(
                        '₹ ',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF373737),
                        ),
                      ),
                      Text(
                        '${widget.mrp}',
                        style: TextStyle(
                          color: const Color(0xFF373737),
                          fontSize: sw * 0.027,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: sw * 0.011),
                      Text(
                        '${widget.price}/${widget.unit}',
                        style: TextStyle(
                          color: const Color(0xFF4256D3),
                          fontSize: sw * 0.029,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/home/cracks.png',
                        height: sh * 0.018,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}