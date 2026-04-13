import 'package:flutter/material.dart';
import 'package:smm_power/wishlist_state.dart';
import 'package:smm_power/cart/order_summary_category.dart';
import 'package:smm_power/home_screen/recommended.dart';
import 'package:smm_power/my_order/review_product.dart';
import 'package:smm_power/navigation_source.dart';
import 'package:smm_power/cart/cart_state.dart';
import 'package:smm_power/cart/add_cart.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String mobileNumber;
  const ProductDetailsScreen({super.key, required this.mobileNumber});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  late TabController _tabController;
  final int _imageCount = 4;
  List<Map<String, dynamic>> _userReviews = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToCart() {
    showAddToCartSheet(
      context,
      item: CartItemModel(
        name: 'Flying Crane Product 1',
        imagePath: 'assets/home/flying_crane.png',
        price: 5000,
        originalPrice: 7000,
        discountPercent: 27,
        deliveryDate: 'Delivery by Mar 14, Sat',
      ),
    );
  }

  void _buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Order_Summary_Category(source: NavigationSource.buyNow)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(sw, sh),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(sw, sh),
                  _buildProductInfo(sw, sh),
                  _buildSpecsBanner(sw, sh),
                  SizedBox(height: sh * 0.010),
                  const Divider(thickness: 2, color: Color(0xFFC3C3C3)),
                  _buildTabSection(sw, sh),
                  _buildDeliveryDetails(sw, sh),
                  _buildRecommendedSection(sw, sh),
                  _buildRatingsSection(sw, sh),
                  _buildTrustBadges(sw, sh),
                  SizedBox(height: sh * 0.099),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(sw, sh),
    );
  }

  // ── APP BAR ───────────────────────────────────────
  Widget _buildAppBar(double sw, double sh) {
    return Container(
      color: const Color(0xFF52B157),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.043,
            vertical: sh * 0.017,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Icon(Icons.arrow_back, color: Colors.white, size: sw * 0.064),
              ),
              SizedBox(width: sw * 0.037),
              Text(
                'Product Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sw * 0.048,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── IMAGE CAROUSEL ────────────────────────────────
  Widget _buildImageCarousel(double sw, double sh) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: sh * 0.345, // ~280
                width: double.infinity,
                child: PageView.builder(
                  itemCount: _imageCount,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (_, __) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(sw * 0.064),
                      child: Image.asset(
                        'assets/home/flying_crane.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.image_outlined, size: sw * 0.24, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: sh * 0.037,
                right: sw * 0.053,
                child: Column(
                  children: [
                    ValueListenableBuilder<List<WishlistItem>>(
                      valueListenable: wishlistNotifier,
                      builder: (context, wishlist, _) {
                        final item = WishlistItem(
                          name: 'Flying Crane',
                          mrp: 7000,
                          price: 5000,
                          unit: 'piece',
                          image: 'assets/home/flying_crane.png',
                        );
                        final isWishlisted = wishlistNotifier.isWishlisted(item);
                        return _floatingBtn(
                          icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : const Color(0xFF929292),
                          onTap: () => wishlistNotifier.toggle(item),
                          sw: sw,
                        );
                      },
                    ),
                    SizedBox(height: sh * 0.018),
                    _floatingBtn(
                      icon: Icons.share_outlined,
                      color: const Color(0xFF929292),
                      onTap: () {},
                      sw: sw,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.012),

          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_imageCount, (i) {
              final active = i == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: sw * 0.008),
                width: active ? sw * 0.053 : sw * 0.019,
                height: sh * 0.009,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: active ? const Color(0xFF4256D3) : const Color(0xFFCECECE),
                  ),
                  color: active ? const Color(0xFF4256D3) : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          SizedBox(height: sh * 0.015),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.032),
            child: const Divider(height: 1.5, color: Color(0xFFC3C3C3)),
          ),
        ],
      ),
    );
  }

  Widget _floatingBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double sw,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sw * 0.101,  // ~38
        height: sw * 0.101,
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAFA),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: color, size: sw * 0.053),
      ),
    );
  }

  // ── PRODUCT INFO ──────────────────────────────────
  Widget _buildProductInfo(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.053, sh * 0.025, sw * 0.053, sh * 0.010),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flying Crane Product 1',
            style: TextStyle(
              fontSize: sw * 0.048,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF000000),
              height: 1.2,
            ),
          ),
          SizedBox(height: sh * 0.007),
          Text(
            'Streets, parks, gardens.',
            style: TextStyle(
              fontSize: sw * 0.037,
              color: const Color(0xFF373737),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: sh * 0.010),
          Row(children: [
            Image.asset(
              'assets/images/eco.png',
              width: sw * 0.040,
              height: sw * 0.040,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.eco, color: const Color(0xFF046B09), size: sw * 0.040),
            ),
            SizedBox(width: sw * 0.011),
            Text(
              '100% Pure Brass.',
              style: TextStyle(
                fontSize: sw * 0.037,
                color: const Color(0xFF046B09),
                fontWeight: FontWeight.w400,
              ),
            ),
          ]),
          SizedBox(height: sh * 0.010),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              'Price  ',
              style: TextStyle(
                fontSize: sw * 0.037,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              '₹5000',
              style: TextStyle(
                fontSize: sw * 0.053,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(width: sw * 0.021),
            Text(
              '₹7000',
              style: TextStyle(
                fontSize: sw * 0.037,
                color: const Color(0xFF9F9F9F),
                decorationColor: const Color(0xFF9F9F9F),
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ]),
          SizedBox(height: sh * 0.002),
          Text(
            '27% OFF',
            style: TextStyle(
              fontSize: sw * 0.035,
              color: const Color(0xFF52B157),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: sh * 0.010),
          Row(children: [
            ...List.generate(
              5,
                  (_) => Icon(Icons.star, color: const Color(0xFFCEC01D), size: sw * 0.048),
            ),
            SizedBox(width: sw * 0.016),
            Text(
              '4.3 (128 reviews)',
              style: TextStyle(fontSize: sw * 0.035, color: const Color(0xFF000000)),
            ),
          ]),
          SizedBox(height: sh * 0.017),
          Row(children: [
            Expanded(
              child: _chip(
                'Sensors: Light',
                borderColor: const Color(0xFF41A900),
                bgColor: const Color(0xFFEBFFEC),
                textColor: const Color(0xFF41A900),
                sw: sw,
                sh: sh,
              ),
            ),
            SizedBox(width: sw * 0.027),
            Expanded(
              child: _chip(
                'anti-rust coating.',
                borderColor: const Color(0xFF4256D3),
                bgColor: const Color(0xFFF4F5FF),
                textColor: const Color(0xFF4256D3),
                sw: sw,
                sh: sh,
              ),
            ),
          ]),
          SizedBox(height: sh * 0.017),
          Text(
            'Handcrafted brass bird figurines representing grace, longevity, and harmony, made by Indian artisans. Available in two sizes: Small Set (three 8-inch/20cm birds) and Big Set (three 12-inch/30cm birds). \nColor: Antique.',
            style: TextStyle(
              fontSize: sw * 0.037,
              color: const Color(0xFF000000),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
      String label, {
        required Color borderColor,
        required Color bgColor,
        required Color textColor,
        required double sw,
        required double sh,
      }) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: sh * 0.012),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: sw * 0.037,
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ── SPECS BANNER ──────────────────────────────────
  Widget _buildSpecsBanner(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.053, vertical: sh * 0.012),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(sw * 0.032, sh * 0.043, sw * 0.032, sh * 0.020),
            decoration: BoxDecoration(
              color: const Color(0xFF52B157),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              _specItem('Table', 'centerpiece \nor home \ndecor accent.', sw, sh),
              Container(width: 1, height: sh * 0.074, color: Colors.white),
              _specItem('Price', '11,500 INR to\n25,000 INR', sw, sh),
              Container(width: 1, height: sh * 0.074, color: Colors.white),
              _specItem('Battery', 'Built-in LiFePO4\nbattery', sw, sh),
            ]),
          ),
          Positioned(
            top: -sh * 0.012,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _topIcon('assets/icon/table.png', sw),
                _topIcon('assets/icon/price.png', sw),
                _topIcon('assets/icon/battery.png', sw),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specItem(String title, String subtitle, double sw, double sh) => Expanded(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: sw * 0.037,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: sh * 0.005),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: sw * 0.032, height: 1.4),
      ),
    ]),
  );

  Widget _topIcon(String path, double sw) => Container(
    width: sw * 0.096,
    height: sw * 0.096,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Padding(
      padding: EdgeInsets.all(sw * 0.016),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.circle, size: sw * 0.053, color: Colors.grey),
      ),
    ),
  );

  // ── TAB SECTION ───────────────────────────────────
  Widget _buildTabSection(double sw, double sh) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: Color(0xFF52B157)),
            insets: EdgeInsets.symmetric(horizontal: 0),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFF52B157),
          unselectedLabelColor: const Color(0xFF888888),
          labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: sw * 0.037),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: sw * 0.037),
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Description')],
        ),
        Divider(height: 0.5, color: Colors.grey[100]),
        Column(children: [
          _infoRow('Product Name', 'Flying Crane Product 1', sw, sh, isGrey: false),
          _infoRow('Brand', 'SMM', sw, sh, isGrey: true),
          _infoRow('Category', 'Flying Crane', sw, sh),
          _infoRow('Technical Content', '', sw, sh, isGrey: true),
          _infoRow('Classification', 'Pure Brass', sw, sh),
          _infoRow('Toxicity', 'Black', sw, sh, isGrey: true),
        ]),
      ],
    );
  }

  Widget _infoRow(String title, String value, double sw, double sh, {bool isGrey = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.043, vertical: sh * 0.010),
      color: isGrey ? const Color(0xFFD9D9D9) : Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: sw * 0.373, // ~140
          child: Text(
            title,
            style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.w400),
          ),
        ),
      ]),
    );
  }

  // ── DELIVERY DETAILS ──────────────────────────────
  Widget _buildDeliveryDetails(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(sw * 0.053, sh * 0.025, sw * 0.043, sh * 0.010),
          child: Text(
            'Delivery Details',
            style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w700),
          ),
        ),
        _deliveryTile('assets/icon/home.png', 'Delivery to - Coimbatore, 641 005',
            sw: sw, sh: sh, hasArrow: true),
        SizedBox(height: sh * 0.005),
        _deliveryTile('assets/icon/truck.png', 'Delivery by 14 Mar, Sat', sw: sw, sh: sh),
      ],
    );
  }

  Widget _deliveryTile(String imagePath, String text,
      {required double sw, required double sh, bool hasArrow = false}) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F2F2),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.043, vertical: sh * 0.017),
        child: Row(children: [
          Image.asset(
            imagePath,
            width: sw * 0.053,
            height: sw * 0.053,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.home_outlined, size: sw * 0.053),
          ),
          SizedBox(width: sw * 0.027),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: sw * 0.037, fontWeight: FontWeight.w500),
            ),
          ),
          if (hasArrow)
            Icon(Icons.chevron_right, color: const Color(0xFF4256D3), size: sw * 0.053),
        ]),
      ),
    );
  }

  // ── RECOMMENDED SECTION ───────────────────────────
  Widget _buildRecommendedSection(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.053, sh * 0.025, sw * 0.043, sh * 0.010),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You might also like',
            style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: sh * 0.015),
          SizedBox(
            height: sh * 0.222, // ~180
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                RecommendedCard(
                  name: 'Flying Crane 1', mrp: 2000, price: 1550,
                  unit: 'piece', image: 'assets/category/flying_crane_1.png',
                ),
                RecommendedCard(
                  name: 'Flying Crane 2', mrp: 2000, price: 1000,
                  unit: 'piece', image: 'assets/category/flying_crane_2.png',
                ),
                RecommendedCard(
                  name: 'Flying Crane 3', mrp: 2000, price: 1550,
                  unit: 'piece', image: 'assets/category/flying_crane_3.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── RATINGS SECTION ───────────────────────────────
  Widget _buildRatingsSection(double sw, double sh) {
    const bars = [
      _RatingBar(stars: 5, pct: 0.65, label: '65%'),
      _RatingBar(stars: 4, pct: 0.22, label: '22%'),
      _RatingBar(stars: 3, pct: 0.07, label: '7%'),
      _RatingBar(stars: 2, pct: 0.04, label: '4%'),
      _RatingBar(stars: 1, pct: 0.02, label: '2%'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.053, sh * 0.012, sw * 0.043, sh * 0.010),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ratings and reviews',
            style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: sh * 0.010),
          Row(children: [
            ...List.generate(5,
                    (_) => Icon(Icons.star, color: const Color(0xFFCEC01D), size: sw * 0.053)),
            SizedBox(width: sw * 0.016),
            Text('4.3 (128 reviews)', style: TextStyle(fontSize: sw * 0.035)),
          ]),
          SizedBox(height: sh * 0.012),

          // Rating bars
          ...bars.map((b) => Padding(
            padding: EdgeInsets.only(bottom: sh * 0.012),
            child: Row(children: [
              Text(
                '${b.stars}',
                style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: sw * 0.011),
              Icon(Icons.star, size: sw * 0.043, color: const Color(0xFFCEC01D)),
              SizedBox(width: sw * 0.027),
              Expanded(
                child: SizedBox(
                  height: sh * 0.010,
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: b.stars == 5
                          ? 0.6
                          : b.stars == 4
                          ? 0.4
                          : b.stars == 3
                          ? 0.3
                          : b.stars == 2
                          ? 0.2
                          : 0.1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: b.stars == 5
                              ? const Color(0xFF22C663)
                              : b.stars == 4
                              ? const Color(0xFF84CD15)
                              : b.stars == 3
                              ? const Color(0xFFFBCD16)
                              : b.stars == 2
                              ? const Color(0xFFF49643)
                              : const Color(0xFFD05255),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              SizedBox(width: sw * 0.027),
              SizedBox(
                width: sw * 0.080,
                child: Text(
                  b.label,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: sw * 0.032),
                ),
              ),
            ]),
          )),

          SizedBox(height: sh * 0.010),
          const Divider(thickness: 5, color: Color(0xFFC3C3C3)),
          SizedBox(height: sh * 0.017),
          ...ReviewStore.reviews.map((r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _reviewCard(
                r['name'],
                r['date'],
                r['rating'],
                sw,
                sh,
                reviewText: r['review'],
              ),
              const Divider(color: Color(0xFFC3C3C3)),
              SizedBox(height: sh * 0.007),
            ],
          )),
          _reviewCard('Akhil Mohan', '28 jan 2025', 4, sw, sh),
          const Divider(color: Color(0xFFC3C3C3)),
          SizedBox(height: sh * 0.007),
          SizedBox(height: sh * 0.012),
          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.075, vertical: sh * 0.012),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: const BorderSide(color: Color(0xFF52B157)),
              ),
              child: Text(
                'Read More Reviews',
                style: TextStyle(
                  fontSize: sw * 0.043,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF000000),
                ),
              ),
            ),
          ),
          SizedBox(height: sh * 0.018),
        ],
      ),
    );
  }

  Widget _reviewCard(String name, String date, int stars, double sw, double sh, {String reviewText = ''}) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.006),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: sw * 0.107,
          height: sw * 0.107,
          decoration: const BoxDecoration(color: Color(0xFFDBFFDD), shape: BoxShape.circle),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(sw * 0.019),
              child: Image.asset(
                'assets/images/person.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person, color: Colors.grey, size: sw * 0.053),
              ),
            ),
          ),
        ),
        SizedBox(width: sw * 0.027),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w600)),
          SizedBox(height: sh * 0.005),
          Row(
            children: List.generate(5, (i) => Icon(
              i < stars ? Icons.star : Icons.star_border,
              size: sw * 0.040,
              color: const Color(0xFFCEC01D),
            )),
          ),
          SizedBox(height: sh * 0.005),
          Text(
            'Reviewed on $date',
            style: TextStyle(fontSize: sw * 0.035, color: Colors.black54),
          ),

          // ── SHOW REVIEW TEXT IF EXISTS ──
          if (reviewText.isNotEmpty) ...[
            SizedBox(height: sh * 0.005),
            SizedBox(
              width: sw * 0.6,
              child: Text(
                reviewText,
                style: TextStyle(fontSize: sw * 0.035, color: Colors.black87),
              ),
            ),
          ],
        ]),
      ]),
    );
  }

  // ── TRUST BADGES ──────────────────────────────────
  Widget _buildTrustBadges(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.053, vertical: sh * 0.012),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(sw * 0.032, sh * 0.043, sw * 0.032, sh * 0.020),
            decoration: BoxDecoration(
              color: const Color(0xFF52B157),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _badgeText('Free Delivery', sw),
                _badgeText('Genuine Product', sw),
                _badgeText('Easy Returns', sw),
              ],
            ),
          ),
          Positioned(
            top: -sh * 0.012,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _badgeIcon('assets/icon/delivery.png', sw),
                _badgeIcon('assets/icon/genuine.png', sw),
                _badgeIcon('assets/icon/returns.png', sw),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeText(String label, double sw) => Text(
    label,
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.white, fontSize: sw * 0.032, fontWeight: FontWeight.w600),
  );

  Widget _badgeIcon(String path, double sw) => Container(
    width: sw * 0.096,
    height: sw * 0.096,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    padding: EdgeInsets.all(sw * 0.016),
    child: Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.verified, size: sw * 0.053, color: Colors.grey),
    ),
  );

  // ── BOTTOM BAR ────────────────────────────────────
  Widget _buildBottomBar(double sw, double sh) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.093, vertical: sh * 0.012),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0xFF4256D3), blurRadius: 0, offset: Offset(0, -1)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToCart,
                icon: Icon(Icons.shopping_cart_outlined, size: sw * 0.053, color: const Color(0xFF4256D3)),
                label: Text(
                  'Add Cart',
                  style: TextStyle(
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4256D3),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF222222),
                  side: const BorderSide(color: Color(0xFF4256D3)),
                  padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(width: sw * 0.080),
            Expanded(
              child: ElevatedButton(
                onPressed: _buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4FE8),
                  padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/flash.png',
                      width: sw * 0.048,
                      height: sw * 0.048,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.flash_on, color: Colors.white, size: sw * 0.048),
                    ),
                    Transform.translate(
                      offset: Offset(-sw * 0.021, 0),
                      child: Image.asset(
                        'assets/images/flash.png',
                        width: sw * 0.048,
                        height: sw * 0.048,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(width: sw * 0.008),
                    Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: sw * 0.037,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBar {
  final int stars;
  final double pct;
  final String label;
  const _RatingBar({required this.stars, required this.pct, required this.label});
}