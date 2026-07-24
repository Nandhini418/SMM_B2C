import 'package:flutter/material.dart';
import 'package:smm_power/home_screen/qr_scanner.dart';
import 'package:smm_power/home_screen/search_screen.dart';
import 'package:smm_power/service/category_api_service.dart';
import 'package:smm_power/service/product_api_service.dart';
import 'package:smm_power/bottom_navigation/category.dart';
import 'package:smm_power/category/product_details.dart';
import 'package:smm_power/home_screen/notification.dart';
import 'package:smm_power/home_screen/recommended.dart';
import 'package:smm_power/saved_address/saved_address_screen.dart';
import 'package:smm_power/wishlist_state.dart';

class HomeScreen extends StatefulWidget {
  final String mobileNumber;
  final VoidCallback? onAddCartPressed;
  const HomeScreen({super.key, this.onAddCartPressed, required this.mobileNumber});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // ── Categories API state (TYPE 100) ───────────────────
  List<SideCategoryModel> _categories = [];
  bool _isCatLoading = true;

  // ── Best Selling API state ────────────────────────────
  // Fetches sub-category items from a specific category (e.g. Capacitors)
  // and shows the first few as "Best Selling" products.
  List<SubCategoryItemModel> _bestSellingItems = [];
  bool _isBestSellingLoading = true;

  // ── Recommended API state ─────────────────────────────
  // Fetches sub-category items from another category (or same) for recommendations.
  List<SubCategoryItemModel> _recommendedItems = [];
  bool _isRecommendedLoading = true;

  // ─────────────────────────────────────────────────────
  // CONFIGURATION — change these IDs to control which
  // category feeds "Best Selling" and "Recommended".
  // Once CategoryCache is warm these return instantly.
  // ─────────────────────────────────────────────────────

  /// Sub-category id whose products appear in "Best Selling"
  static const int _bestSellingCategoryId = 1; // ← replace with your capacitor category id

  /// Sub-category id whose products appear in "You Might Also Like"
  static const int _recommendedCategoryId = 4; // ← replace with desired category id

  /// How many items to show in Best Selling (horizontal scroll)
  static const int _bestSellingLimit = 6;

  /// How many items to show in Recommended (horizontal scroll)
  static const int _recommendedLimit = 6;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBestSelling();
    _loadRecommended();
  }

  // ── Load sidebar categories (TYPE 100) ───────────────
  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryApiService.fetchSideCategories();
      if (mounted) setState(() { _categories = cats; _isCatLoading = false; });
    } catch (e) {
      print('Home categories error: $e');
      if (mounted) setState(() => _isCatLoading = false);
    }
  }

  // ── Load Best Selling products (TYPE 101) ─────────────
  Future<void> _loadBestSelling() async {
    try {
      final items = await CategoryApiService.fetchSubCategoryItems(_bestSellingCategoryId);
      if (mounted) {
        setState(() {
          // Take up to _bestSellingLimit items
          _bestSellingItems = items.take(_bestSellingLimit).toList();
          _isBestSellingLoading = false;
        });
      }
    } catch (e) {
      print('Best Selling load error: $e');
      if (mounted) setState(() => _isBestSellingLoading = false);
    }
  }

  // ── Load Recommended products (TYPE 101) ──────────────
  Future<void> _loadRecommended() async {
    try {
      final items = await CategoryApiService.fetchSubCategoryItems(_recommendedCategoryId);
      if (mounted) {
        setState(() {
          // Take up to _recommendedLimit items
          _recommendedItems = items.take(_recommendedLimit).toList();
          _isRecommendedLoading = false;
        });
      }
    } catch (e) {
      print('Recommended load error: $e');
      if (mounted) setState(() => _isRecommendedLoading = false);
    }
  }

  // ── Navigate to CategoryScreen pre-selecting a category ──
  void _openCategory(SideCategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          initialCategoryId: cat.id,
        ),
      ),
    );
  }

  // ── Navigate to ProductDetailsScreen from a SubCategoryItemModel ──
  void _openProductFromItem(SubCategoryItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: item.id,
          productName: item.productName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAppHeader(sw, sh),
                Positioned(
                  bottom: -(sh * 0.172),
                  left: 0,
                  right: 0,
                  child: _buildHeroBanner(sw, sh),
                ),
              ],
            ),

            SizedBox(height: sh * 0.203),
            _buildCategoriesSection(sw, sh),
            SizedBox(height: sh * 0.025),
            _buildBestSellingSection(sw, sh),
            SizedBox(height: sh * 0.025),
            _buildPromoBanner(sw),
            SizedBox(height: sh * 0.025),
            _buildRecommendedSection(sw, sh),
            SizedBox(height: sh * 0.025),
          ],
        ),
      ),
    );
  }

  // ── TOP GREEN HEADER ──────────────────────────────────
  Widget _buildAppHeader(double sw, double sh) {
    return Container(
      height: sh * 0.259,
      decoration: const BoxDecoration(
        color: Color(0xFF52B157),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(sw * 0.048, sh * 0.015, sw * 0.048, sh * 0.025),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.027, vertical: sh * 0.005),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Image.asset('assets/login/smm.png', height: sh * 0.034),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QrScannerScreen())),
                    child: _HeaderIcon(icon: Icons.qr_code_scanner_rounded, sw: sw, sh: sh),
                  ),
                  SizedBox(width: sw * 0.027),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SavedAddressScreen())),
                    child: _HeaderIcon(icon: Icons.location_on_outlined, sw: sw, sh: sh),
                  ),
                  SizedBox(width: sw * 0.027),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen())),
                    child: _HeaderIcon(icon: Icons.notifications_outlined, sw: sw, sh: sh),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.017),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: AbsorbPointer(
                  child: Container(
                    height: sh * 0.057,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF293896)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: sw * 0.032),
                        Icon(Icons.search, color: const Color(0xFFC3C3C3), size: sw * 0.058),
                        SizedBox(width: sw * 0.021),
                        Expanded(child: Text('Search Product here', style: TextStyle(color: const Color(0xFF555555), fontSize: sw * 0.037))),
                        Icon(Icons.mic_none_rounded, color: const Color(0xFF4256D3), size: sw * 0.058),
                        SizedBox(width: sw * 0.027),
                        Container(width: 1, height: sh * 0.034, color: const Color(0xFFACACAC)),
                        SizedBox(width: sw * 0.027),
                        Icon(Icons.image_search_outlined, color: const Color(0xFFC3C3C3), size: sw * 0.058),
                        SizedBox(width: sw * 0.032),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HERO BANNER ───────────────────────────────────────
  Widget _buildHeroBanner(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.061),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: sh * 0.222,
          width: double.infinity,
          child: Stack(
            children: [
              Image.asset("assets/home/banner.png", width: double.infinity, height: sh * 0.222, fit: BoxFit.cover),
              Positioned(
                top: sh * 0.020, left: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.021, vertical: sh * 0.004),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Image.asset('assets/login/smm.png', height: sh * 0.025),
                ),
              ),
              Positioned(
                bottom: sh * 0.020, left: sw * 0.043,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEA00),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.027, vertical: sh * 0.005),
                    minimumSize: const Size(8, 0),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text("Buy Now", style: TextStyle(fontSize: sw * 0.027, fontWeight: FontWeight.w400)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CATEGORIES SECTION — API-driven, horizontal scroll ─
  Widget _buildCategoriesSection(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.043),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryScreen()),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF4256D3),
                    color: const Color(0xFF4256D3),
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.017),

          SizedBox(
            height: sh * 0.123,
            child: _isCatLoading
                ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.027),
              itemBuilder: (_, __) => _ShimmerCategoryCard(sw: sw, sh: sh),
            )
                : _categories.isEmpty
                ? Center(child: Text('No categories', style: TextStyle(color: Colors.grey, fontSize: sw * 0.035)))
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.027),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () => _openCategory(cat),
                  child: _ApiCategoryCard(cat: cat, sw: sw, sh: sh),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── BEST SELLING — API-driven ─────────────────────────
  Widget _buildBestSellingSection(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best Selling',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: sh * 0.017),

          SizedBox(
            height: sh * 0.220,
            child: _isBestSellingLoading

            // ── Loading shimmer ──
                ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.02),
              itemBuilder: (_, __) => _ShimmerBestSellerCard(sw: sw, sh: sh),
            )

            // ── Empty fallback ──
                : _bestSellingItems.isEmpty
                ? Center(
              child: Text(
                'No products',
                style: TextStyle(color: Colors.grey, fontSize: sw * 0.035),
              ),
            )

            // ── Real API data ──
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: sw * 0.027),
              itemCount: _bestSellingItems.length,
              itemBuilder: (ctx, i) {
                final item = _bestSellingItems[i];
                // Mark the first item as "Best Seller" badge
                final isBestSeller = i == 0;
                return Padding(
                  padding: EdgeInsets.only(right: sw * 0.02),
                  child: SizedBox(
                    width: sw * 0.427,
                    child: _ApiBestSellerCard(
                      item: item,
                      isBestSeller: isBestSeller,
                      sw: sw,
                      sh: sh,
                      onTap: () => _openProductFromItem(item),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── PROMO BANNER ──────────────────────────────────────
  Widget _buildPromoBanner(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.043),
      child: Image.asset('assets/home/percent_banner.png'),
    );
  }

  // ── RECOMMENDED PRODUCTS — API-driven ────────────────
  Widget _buildRecommendedSection(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Text(
            'You Might Also like',
            style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: sh * 0.02),

        SizedBox(
          height: sh * 0.210,
          child: _isRecommendedLoading

          // ── Loading shimmer ──
              ? ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.043),
            itemCount: 4,
            separatorBuilder: (_, __) => SizedBox(width: sw * 0.032),
            itemBuilder: (_, __) => _ShimmerRecommendedCard(sw: sw, sh: sh),
          )

          // ── Empty fallback ──
              : _recommendedItems.isEmpty
              ? Center(
            child: Text(
              'No recommendations',
              style: TextStyle(color: Colors.grey, fontSize: sw * 0.035),
            ),
          )

          // ── Real API data ──
          // RecommendedCard is reused unchanged — we just pass the real
          // productId (item.id) and productName from the API.
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.043),
            itemCount: _recommendedItems.length,
            itemBuilder: (ctx, i) {
              final item = _recommendedItems[i];
              return RecommendedCard(
                name: item.productName,
                // price/mrp are not in SubCategoryItemModel — they come
                // from the product detail API (TYPE 1018).  We show 0
                // here as a placeholder; the detail screen shows the
                // real price once the user taps through.
                mrp: 0,
                price: 0,
                unit: 'piece',
                // Use network image from SubCategoryItemModel when
                // available; fall back to a placeholder asset.
                image: item.hasImage ? item.productImage! : '',
                productId: item.id,   // ← real id from API, same logic as before
              );
            },
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
//  API BEST SELLER CARD
//  Mirrors _BestSellerCard but uses SubCategoryItemModel
//  (network image, real product name, navigates by item.id).
// ══════════════════════════════════════════════════════
class _ApiBestSellerCard extends StatefulWidget {
  final SubCategoryItemModel item;
  final bool isBestSeller;
  final VoidCallback onTap;
  final double sw;
  final double sh;

  const _ApiBestSellerCard({
    required this.item,
    required this.isBestSeller,
    required this.onTap,
    required this.sw,
    required this.sh,
  });

  @override
  State<_ApiBestSellerCard> createState() => _ApiBestSellerCardState();
}

class _ApiBestSellerCardState extends State<_ApiBestSellerCard> {
  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC8C8C8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──
            SizedBox(
              height: sh * 0.155,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: sh * 0.020),
                      child: widget.item.hasImage
                          ? Image.network(
                        widget.item.productImage!,
                        height: sh * 0.100,
                        width: sw * 0.240,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) =>
                        progress == null
                            ? child
                            : Container(
                          color: const Color(0xFFF8F8F8),
                          height: sh * 0.100,
                          width: sw * 0.240,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF52B157),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported_outlined,
                          size: sw * 0.12,
                          color: const Color(0xFFBDBDBD),
                        ),
                      )
                          : Icon(
                        Icons.image_not_supported_outlined,
                        size: sw * 0.12,
                        color: const Color(0xFFBDBDBD),
                      ),
                    ),
                  ),

                  // "Best Seller" badge on first card
                  if (widget.isBestSeller)
                    Positioned(
                      top: 0, left: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.027,
                          vertical: sh * 0.005,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4256D3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Best Seller",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * 0.027,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist heart button
                  Positioned(
                    top: sh * 0.008,
                    right: sw * 0.027,
                    child: ValueListenableBuilder<List<WishlistItem>>(
                      valueListenable: wishlistNotifier,
                      builder: (context, wishlist, _) {
                        final wItem = WishlistItem(
                          name: widget.item.productName,
                          mrp: 0,
                          price: 0,
                          unit: 'piece',
                          image: widget.item.productImage ?? '',
                        );
                        final isWishlisted = wishlistNotifier.isWishlisted(wItem);
                        return GestureDetector(
                          onTap: () => wishlistNotifier.toggle(wItem),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(isWishlisted),
                              color: isWishlisted ? Colors.red : const Color(0xFF4256D3),
                              size: sw * 0.067,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Product name + price placeholder ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                sw * 0.027, sh * 0.001, sw * 0.027, sh * 0.010,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF4256D3),
                      fontSize: sw * 0.037,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  // Price is loaded on the detail screen via TYPE 1018.
                  // Show "View Price" hint to keep the card clean.
                  Text(
                    'Tap to view price',
                    style: TextStyle(
                      color: const Color(0xFFA8A8A8),
                      fontSize: sw * 0.029,
                      fontWeight: FontWeight.w400,
                    ),
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

// ══════════════════════════════════════════════════════
//  SHIMMER PLACEHOLDERS
// ══════════════════════════════════════════════════════

class _ShimmerBestSellerCard extends StatelessWidget {
  final double sw;
  final double sh;
  const _ShimmerBestSellerCard({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.427,
      height: sh * 0.220,
      margin: EdgeInsets.only(left: sw * 0.027),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _ShimmerRecommendedCard extends StatelessWidget {
  final double sw;
  final double sh;
  const _ShimmerRecommendedCard({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.360,
      height: sh * 0.210,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ── API CATEGORY CARD ─────────────────────────────────
class _ApiCategoryCard extends StatelessWidget {
  final SideCategoryModel cat;
  final double sw;
  final double sh;

  const _ApiCategoryCard({required this.cat, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.240,
      height: sh * 0.123,
      padding: EdgeInsets.symmetric(vertical: sh * 0.015, horizontal: sw * 0.016),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: sh * 0.059,
            width: sw * 0.160,
            child: cat.image.isNotEmpty
                ? Image.network(
              cat.image,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.category_outlined,
                size: sw * 0.09,
                color: const Color(0xFF4256D3),
              ),
            )
                : Icon(Icons.category_outlined, size: sw * 0.09, color: const Color(0xFF4256D3)),
          ),
          SizedBox(height: sh * 0.006),
          Text(
            cat.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF4256D3),
              fontSize: sw * 0.027,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SHIMMER CATEGORY PLACEHOLDER ──────────────────────
class _ShimmerCategoryCard extends StatelessWidget {
  final double sw;
  final double sh;
  const _ShimmerCategoryCard({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.240,
      height: sh * 0.123,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

// ── HEADER ICON ───────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final double sw;
  final double sh;
  const _HeaderIcon({required this.icon, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.096,
      height: sw * 0.096,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Colors.white, size: sw * 0.067),
    );
  }
}