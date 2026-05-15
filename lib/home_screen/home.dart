import 'package:flutter/material.dart';
import 'package:smm_power/home_screen/qr_scanner.dart';
import 'package:smm_power/home_screen/search_screen.dart';
import 'package:smm_power/service/category_api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryApiService.fetchSideCategories();
      if (mounted) setState(() { _categories = cats; _isCatLoading = false; });
    } catch (e) {
      print('Home categories error: $e');
      if (mounted) setState(() => _isCatLoading = false);
    }
  }

  // ── Navigate to CategoryScreen pre-selecting a category ──
  void _openCategory(SideCategoryModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          initialCategoryId: cat.id,   // ← tells CategoryScreen which to select
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
            _buildCategoriesSection(sw, sh),   // ← now API-driven
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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w700)),
              GestureDetector(
                // "View All" → opens CategoryScreen at first category (default)
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

          // ── Horizontally scrollable category cards ──
          SizedBox(
            height: sh * 0.123, // matches original card height
            child: _isCatLoading

            // Loading shimmer row
                ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.027),
              itemBuilder: (_, __) => _ShimmerCategoryCard(sw: sw, sh: sh),
            )

            // Empty fallback
                : _categories.isEmpty
                ? Center(child: Text('No categories', style: TextStyle(color: Colors.grey, fontSize: sw * 0.035)))

            // Real data
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.027),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () => _openCategory(cat), // ← navigate with id
                  child: _ApiCategoryCard(cat: cat, sw: sw, sh: sh),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── BEST SELLING ──────────────────────────────────────
  Widget _buildBestSellingSection(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Best Selling', style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
          SizedBox(height: sh * 0.017),
          SizedBox(
            height: sh * 0.220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: sw * 0.027),
                SizedBox(
                  width: sw * 0.427,
                  child: _BestSellerCard(
                    name: 'Solar Wall Light W02', price: 5000, mrp: 7000,
                    isBestSeller: true, image: 'assets/home/solar_wall.png', sw: sw, sh: sh,
                    screen: ProductDetailsScreen(productId: 197),
                  ),
                ),
                SizedBox(width: sw * 0.02),
                SizedBox(
                  width: sw * 0.427,
                  child: _BestSellerCard(
                    name: 'Solar Wall Light W09', price: 5000, mrp: 7000,
                    isBestSeller: false, image: 'assets/items/solar_wall_light_2.jpg', sw: sw, sh: sh,
                    screen: ProductDetailsScreen(productId: 204),
                  ),
                ),
                SizedBox(width: sw * 0.027),
              ],
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

  // ── RECOMMENDED PRODUCTS ──────────────────────────────
  Widget _buildRecommendedSection(double sw, double sh) {
    final products = [
      {'name': 'Solar Wall Light 3', 'mrp': 2000, 'price': 1550, 'unit': 'piece', 'image': 'assets/home/image_1.png', 'productId': 197},
      {'name': 'Solar Wall Light 3', 'mrp': 2000, 'price': 1000, 'unit': 'piece', 'image': 'assets/home/bollard.png', 'productId': 197},
      {'name': 'Solar Wall Light 3', 'mrp': 2000, 'price': 1550, 'unit': 'piece', 'image': 'assets/home/image_3.png', 'productId': 197},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Text('You Might Also like', style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: sh * 0.02),
        SizedBox(
          height: sh * 0.210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.043),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final p = products[i];
              return RecommendedCard(
                name: p['name'] as String, mrp: p['mrp'] as int,
                price: p['price'] as int, unit: p['unit'] as String, image: p['image'] as String,
                productId: p['productId'] as int?,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── API CATEGORY CARD ─────────────────────────────────
// Mirrors the original _CategoryCard but uses network image from the API.
class _ApiCategoryCard extends StatelessWidget {
  final SideCategoryModel cat;
  final double sw;
  final double sh;

  const _ApiCategoryCard({required this.cat, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.240,             // fixed width so cards are uniform
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
          // ── Category image (network) ──
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

          // ── Category label ──
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

// ── SHIMMER PLACEHOLDER CARD (while loading) ──────────
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

// ── BEST SELLER CARD ──────────────────────────────────
class _BestSellerCard extends StatefulWidget {
  final String name;
  final int price;
  final int mrp;
  final bool isBestSeller;
  final String image;
  final Widget? screen;
  final double sw;
  final double sh;

  const _BestSellerCard({
    required this.name, required this.price, required this.mrp,
    required this.isBestSeller, required this.image,
    required this.sw, required this.sh, this.screen,
  });

  @override
  State<_BestSellerCard> createState() => _BestSellerCardState();
}

class _BestSellerCardState extends State<_BestSellerCard> {
  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (widget.screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => widget.screen!));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC8C8C8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: sh * 0.155,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: sh * 0.020),
                      child: Image.asset(widget.image, height: sh * 0.100, width: sw * 0.240, fit: BoxFit.contain),
                    ),
                  ),
                  if (widget.isBestSeller)
                    Positioned(
                      top: 0, left: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.027, vertical: sh * 0.005),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4256D3),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomRight: Radius.circular(10)),
                        ),
                        child: Text("Best Seller", style: TextStyle(color: Colors.white, fontSize: sw * 0.027, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  Positioned(
                    top: sh * 0.008, right: sw * 0.027,
                    child: ValueListenableBuilder<List<WishlistItem>>(
                      valueListenable: wishlistNotifier,
                      builder: (context, wishlist, _) {
                        final item = WishlistItem(name: widget.name, mrp: widget.mrp, price: widget.price, unit: 'piece', image: widget.image);
                        final isWishlisted = wishlistNotifier.isWishlisted(item);
                        return GestureDetector(
                          onTap: () => wishlistNotifier.toggle(item),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
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
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.027, sh * 0.001, sw * 0.027, sh * 0.010),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name, style: TextStyle(color: const Color(0xFF4256D3), fontSize: sw * 0.037, fontWeight: FontWeight.w600)),
                  SizedBox(height: sh * 0.005),
                  Row(
                    children: [
                      Text('₹ ', style: TextStyle(fontFamily: 'Lato', fontSize: sw * 0.04, fontWeight: FontWeight.w400)),
                      Text('${widget.price}', style: TextStyle(fontSize: sw * 0.037, fontWeight: FontWeight.w400)),
                      SizedBox(width: sw * 0.016),
                      Text('₹ ', style: TextStyle(fontFamily: 'Lato', fontSize: sw * 0.04, color: const Color(0xFFA8A8A8))),
                      Text(
                        '${widget.mrp}',
                        style: TextStyle(
                          color: const Color(0xFFA8A8A8), fontSize: sw * 0.032,
                          decoration: TextDecoration.lineThrough, decorationColor: const Color(0xFFA8A8A8),
                        ),
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
