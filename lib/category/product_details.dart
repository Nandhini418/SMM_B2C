import 'package:flutter/material.dart';
import 'package:smm_power/service/product_api_service.dart';
import 'package:smm_power/service/category_api_service.dart';
import 'package:smm_power/wishlist_state.dart';
import 'package:smm_power/cart/order_summary_category.dart';
import 'package:smm_power/home_screen/recommended.dart';
import 'package:smm_power/my_order/review_product.dart';
import 'package:smm_power/navigation_source.dart';
import 'package:smm_power/cart/cart_state.dart';
import 'package:smm_power/cart/add_cart.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String? productName;
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.productName,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  // ── API state ──────────────────────────────────────
  ProductDetailModel? _product;
  bool _isLoading = true;
  String? _error;

  // ── UI state ───────────────────────────────────────
  int _currentImageIndex = 0;
  late TabController _tabController;

  // ── Recommended API state ─────────────────────────
  List<SubCategoryItemModel> _recommendedItems = [];
  bool _isRecommendedLoading = true;

  /// Sub-category id whose products appear in "You might also like".
  /// Change this to the category id that best fits your recommendations.
  static const int _recommendedCategoryId = 1;

  /// How many recommended items to show.
  static const int _recommendedLimit = 6;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProduct();
    _loadRecommended();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Fetch product detail ───────────────────────────
  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final product =
      await ProductApiService.fetchProductDetail(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Product Detail Error: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ── Fetch recommended products (TYPE 101) ─────────
  Future<void> _loadRecommended() async {
    try {
      final items =
      await CategoryApiService.fetchSubCategoryItems(_recommendedCategoryId);
      if (mounted) {
        setState(() {
          _recommendedItems = items.take(_recommendedLimit).toList();
          _isRecommendedLoading = false;
        });
      }
    } catch (e) {
      print('❌ Recommended load error: $e');
      if (mounted) setState(() => _isRecommendedLoading = false);
    }
  }

  // ── Actions ────────────────────────────────────────
  void _goToCart() {
    final p = _product;
    if (p == null) return;
    showAddToCartSheet(
      context,
      item: CartItemModel(
        name: p.productName,
        imagePath: p.productImage,
        price: p.price,
        originalPrice: p.price,
        discountPercent: 0,
        deliveryDate: 'Delivery in 3-5 days',
      ),
    );
  }

  void _buyNow() {
    final p = _product;
    if (p == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Order_Summary_Category(
          source: NavigationSource.buyNow,
          buyNowItem: CartItemModel(
            name: p.productName,
            imagePath: p.productImage,
            price: p.price,
            originalPrice: p.price,
            discountPercent: 0,
            deliveryDate: 'Delivery in 3-5 days',
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────
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
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF52B157),
              ),
            )
                : _error != null
                ? _buildErrorState(sw, sh)
                : _buildBody(sw, sh),
          ),
        ],
      ),
      bottomNavigationBar:
      (!_isLoading && _error == null && _product != null)
          ? _buildBottomBar(sw, sh)
          : null,
    );
  }

  // ── APP BAR ───────────────────────────────────────
  Widget _buildAppBar(double sw, double sh) {
    final title = _product?.productName ??
        widget.productName ??
        'Product Details';

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
                child: Icon(Icons.arrow_back,
                    color: Colors.white, size: sw * 0.064),
              ),
              SizedBox(width: sw * 0.037),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.048,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ERROR STATE ───────────────────────────────────
  Widget _buildErrorState(double sw, double sh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: sw * 0.18),
            SizedBox(height: sh * 0.020),
            Text(
              'Failed to load product details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.043,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: sh * 0.010),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: sw * 0.032, color: Colors.grey),
            ),
            SizedBox(height: sh * 0.030),
            ElevatedButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52B157),
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.075, vertical: sh * 0.014),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FULL BODY (after API load) ────────────────────
  Widget _buildBody(double sw, double sh) {
    final p = _product!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(p, sw, sh),
          _buildProductInfo(p, sw, sh),
          _buildSpecsBanner(p, sw, sh),
          SizedBox(height: sh * 0.010),
          const Divider(thickness: 2, color: Color(0xFFC3C3C3)),
          _buildTabSection(p, sw, sh),
          _buildDeliveryDetails(sw, sh),
          _buildRecommendedSection(sw, sh),
          _buildRatingsSection(sw, sh),
          _buildTrustBadges(sw, sh),
          SizedBox(height: sh * 0.099),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(ProductDetailModel p, double sw, double sh) {
    final images = p.allImages;
    final imageCount = images.isEmpty ? 1 : images.length;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: sh * 0.345,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: imageCount,
                  onPageChanged: (i) =>
                      setState(() => _currentImageIndex = i),
                  itemBuilder: (_, idx) {
                    final url = images.isNotEmpty ? images[idx] : '';
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(sw * 0.064),
                        child: url.isNotEmpty
                            ? Image.network(
                          url,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                            color:
                            const Color(0xFFF8F8F8),
                            child:
                            const CircularProgressIndicator(
                              color: Color(0xFF52B157),
                              strokeWidth: 2,
                            ),
                          ),
                          errorBuilder: (_, __, ___) =>
                              _noImageBox(sw),
                        )
                            : _noImageBox(sw),
                      ),
                    );
                  },
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
                        final wItem = WishlistItem(
                          name: p.productName,
                          mrp: p.priceInt,
                          price: p.priceInt,
                          unit: 'piece',
                          image: p.productImage,
                        );
                        final isWishlisted =
                        wishlistNotifier.isWishlisted(wItem);
                        return _floatingBtn(
                          icon: isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isWishlisted
                              ? Colors.red
                              : const Color(0xFF929292),
                          onTap: () => wishlistNotifier.toggle(wItem),
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
            children: List.generate(imageCount, (i) {
              final active = i == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: sw * 0.008),
                width: active ? sw * 0.053 : sw * 0.019,
                height: sh * 0.009,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: active
                        ? const Color(0xFF4256D3)
                        : const Color(0xFFCECECE),
                  ),
                  color: active
                      ? const Color(0xFF4256D3)
                      : Colors.white,
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

  Widget _noImageBox(double sw) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image_outlined,
          size: sw * 0.24, color: Colors.grey),
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
        width: sw * 0.101,
        height: sw * 0.101,
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAFA),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                offset: Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: color, size: sw * 0.053),
      ),
    );
  }

  // ── PRODUCT INFO ──────────────────────────────────
  Widget _buildProductInfo(ProductDetailModel p, double sw, double sh) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          sw * 0.053, sh * 0.025, sw * 0.053, sh * 0.010),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.productName,
            style: TextStyle(
              fontSize: sw * 0.048,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF000000),
              height: 1.2,
            ),
          ),
          SizedBox(height: sh * 0.007),

          if (p.productCode.isNotEmpty)
            Text(
              'Code: ${p.productCode}',
              style: TextStyle(
                fontSize: sw * 0.034,
                color: const Color(0xFF888888),
                fontWeight: FontWeight.w400,
              ),
            ),

          SizedBox(height: sh * 0.007),

          if (p.description.isNotEmpty)
            Text(
              p.description.split('\n').first.trim(),
              style: TextStyle(
                fontSize: sw * 0.037,
                color: const Color(0xFF373737),
                fontWeight: FontWeight.w400,
              ),
            ),

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
              '₹${p.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: sw * 0.053,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000),
              ),
            ),
          ]),

          SizedBox(height: sh * 0.010),

          Row(children: [
            ...List.generate(
              5,
                  (_) => Icon(Icons.star,
                  color: const Color(0xFFCEC01D), size: sw * 0.048),
            ),
            SizedBox(width: sw * 0.016),
            Text(
              '4.3 (128 reviews)',
              style:
              TextStyle(fontSize: sw * 0.035, color: const Color(0xFF000000)),
            ),
          ]),

          SizedBox(height: sh * 0.017),

          Row(children: [
            if (p.taxRate.isNotEmpty)
              Expanded(
                child: _chip(
                  'Tax: ${p.taxRate}%',
                  borderColor: const Color(0xFF41A900),
                  bgColor: const Color(0xFFEBFFEC),
                  textColor: const Color(0xFF41A900),
                  sw: sw,
                  sh: sh,
                ),
              ),
            if (p.taxRate.isNotEmpty) SizedBox(width: sw * 0.027),
            if (p.stockQty.isNotEmpty)
              Expanded(
                child: _chip(
                  'Stock: ${p.stockQty}',
                  borderColor: const Color(0xFF4256D3),
                  bgColor: const Color(0xFFF4F5FF),
                  textColor: const Color(0xFF4256D3),
                  sw: sw,
                  sh: sh,
                ),
              ),
          ]),

          SizedBox(height: sh * 0.017),

          if (p.description.isNotEmpty)
            Text(
              p.description.trim(),
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
          fontSize: sw * 0.032,
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ── SPECS BANNER ──────────────────────────────────
  Widget _buildSpecsBanner(ProductDetailModel p, double sw, double sh) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: sw * 0.053, vertical: sh * 0.012),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                sw * 0.032, sh * 0.043, sw * 0.032, sh * 0.020),
            decoration: BoxDecoration(
              color: const Color(0xFF52B157),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              _specItem(
                  'Code',
                  p.productCode.isNotEmpty ? p.productCode : '—',
                  sw,
                  sh),
              Container(
                  width: 1, height: sh * 0.074, color: Colors.white),
              _specItem(
                  'Price',
                  '₹${p.price.toStringAsFixed(0)}',
                  sw,
                  sh),
              Container(
                  width: 1, height: sh * 0.074, color: Colors.white),
              _specItem(
                  'Stock',
                  '${p.stockQty} units',
                  sw,
                  sh),
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

  Widget _specItem(String title, String subtitle, double sw, double sh) =>
      Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: sw * 0.029,
                    height: 1.4),
              ),
            ]),
      );

  Widget _topIcon(String path, double sw) => Container(
    width: sw * 0.096,
    height: sw * 0.096,
    decoration:
    const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
  Widget _buildTabSection(ProductDetailModel p, double sw, double sh) {
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
          labelStyle:
          TextStyle(fontWeight: FontWeight.w700, fontSize: sw * 0.037),
          unselectedLabelStyle:
          TextStyle(fontWeight: FontWeight.w500, fontSize: sw * 0.037),
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Description')],
        ),
        Divider(height: 0.5, color: Colors.grey[100]),
        _infoRow('Product Name', p.productName, sw, sh, isGrey: false),
        _infoRow('Product Code', p.productCode, sw, sh, isGrey: true),
        _infoRow('HSN/SAC Code', p.hsnSacCode, sw, sh),
        _infoRow('Technical Name',
            p.technicalName.isNotEmpty ? p.technicalName : '—', sw, sh,
            isGrey: true),
        _infoRow('Size', p.size.isNotEmpty ? p.size : '—', sw, sh),
        _infoRow('Grade', p.grade.isNotEmpty ? p.grade : '—', sw, sh,
            isGrey: true),
        _infoRow('Model', p.model.isNotEmpty ? p.model : '—', sw, sh),
        _infoRow('Make', p.make.isNotEmpty ? p.make : '—', sw, sh,
            isGrey: true),
        _infoRow('Tax Rate', '${p.taxRate}%', sw, sh),
        _infoRow('Stock Qty', p.stockQty, sw, sh, isGrey: true),
      ],
    );
  }

  Widget _infoRow(String title, String value, double sw, double sh,
      {bool isGrey = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.043, vertical: sh * 0.010),
      color: isGrey ? const Color(0xFFD9D9D9) : Colors.white,
      child:
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: sw * 0.373,
          child: Text(
            title,
            style: TextStyle(
                fontSize: sw * 0.035, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: sw * 0.035, fontWeight: FontWeight.w400),
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
          padding: EdgeInsets.fromLTRB(
              sw * 0.053, sh * 0.025, sw * 0.043, sh * 0.010),
          child: Text(
            'Delivery Details',
            style:
            TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w700),
          ),
        ),
        _deliveryTile('assets/icon/home.png',
            'Delivery to - Coimbatore, 641 005',
            sw: sw, sh: sh, hasArrow: true),
        SizedBox(height: sh * 0.005),
        _deliveryTile('assets/icon/truck.png', 'Delivery by 14 Mar, Sat',
            sw: sw, sh: sh),
      ],
    );
  }

  Widget _deliveryTile(String imagePath, String text,
      {required double sw, required double sh, bool hasArrow = false}) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F2F2),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.043, vertical: sh * 0.017),
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
              style: TextStyle(
                  fontSize: sw * 0.037, fontWeight: FontWeight.w500),
            ),
          ),
          if (hasArrow)
            Icon(Icons.chevron_right,
                color: const Color(0xFF4256D3), size: sw * 0.053),
        ]),
      ),
    );
  }

  // ── RECOMMENDED SECTION — API-driven ─────────────
  Widget _buildRecommendedSection(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          sw * 0.053, sh * 0.025, sw * 0.043, sh * 0.010),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You might also like',
            style: TextStyle(
                fontSize: sw * 0.043, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: sh * 0.015),

          SizedBox(
            height: sh * 0.222,
            child: _isRecommendedLoading

            // ── Loading shimmer ──
                ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) =>
                  SizedBox(width: sw * 0.032),
              itemBuilder: (_, __) => Container(
                width: sw * 0.360,
                height: sh * 0.222,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            )

            // ── Empty fallback ──
                : _recommendedItems.isEmpty
                ? Center(
              child: Text(
                'No recommendations',
                style: TextStyle(
                    color: Colors.grey, fontSize: sw * 0.035),
              ),
            )

            // ── Real API data — RecommendedCard reused unchanged ──
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recommendedItems.length,
              itemBuilder: (ctx, i) {
                final item = _recommendedItems[i];
                return RecommendedCard(
                  name: item.productName,
                  mrp: 0,
                  price: 0,
                  unit: 'piece',
                  image: item.hasImage
                      ? item.productImage!
                      : '',
                  productId: item.id,
                );
              },
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
      padding: EdgeInsets.fromLTRB(
          sw * 0.053, sh * 0.012, sw * 0.043, sh * 0.010),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ratings and reviews',
            style: TextStyle(
                fontSize: sw * 0.043, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: sh * 0.010),
          Row(children: [
            ...List.generate(
                5,
                    (_) => Icon(Icons.star,
                    color: const Color(0xFFCEC01D), size: sw * 0.053)),
            SizedBox(width: sw * 0.016),
            Text('4.3 (128 reviews)',
                style: TextStyle(fontSize: sw * 0.035)),
          ]),
          SizedBox(height: sh * 0.012),

          ...bars.map((b) => Padding(
            padding: EdgeInsets.only(bottom: sh * 0.012),
            child: Row(children: [
              Text('${b.stars}',
                  style: TextStyle(
                      fontSize: sw * 0.043,
                      fontWeight: FontWeight.w600)),
              SizedBox(width: sw * 0.011),
              Icon(Icons.star,
                  size: sw * 0.043,
                  color: const Color(0xFFCEC01D)),
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
          SizedBox(height: sh * 0.012),
          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.075, vertical: sh * 0.012),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
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

  Widget _reviewCard(String name, String date, int stars, double sw,
      double sh,
      {String reviewText = ''}) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.006),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: sw * 0.107,
          height: sw * 0.107,
          decoration: const BoxDecoration(
              color: Color(0xFFDBFFDD), shape: BoxShape.circle),
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
          Text(name,
              style: TextStyle(
                  fontSize: sw * 0.043, fontWeight: FontWeight.w600)),
          SizedBox(height: sh * 0.005),
          Row(
            children: List.generate(
                5,
                    (i) => Icon(
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
          if (reviewText.isNotEmpty) ...[
            SizedBox(height: sh * 0.005),
            SizedBox(
              width: sw * 0.6,
              child: Text(
                reviewText,
                style: TextStyle(
                    fontSize: sw * 0.035, color: Colors.black87),
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
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.053, vertical: sh * 0.012),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                sw * 0.032, sh * 0.043, sw * 0.032, sh * 0.020),
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
    style: TextStyle(
        color: Colors.white,
        fontSize: sw * 0.032,
        fontWeight: FontWeight.w600),
  );

  Widget _badgeIcon(String path, double sw) => Container(
    width: sw * 0.096,
    height: sw * 0.096,
    decoration:
    const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.093, vertical: sh * 0.012),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0xFF4256D3),
              blurRadius: 0,
              offset: Offset(0, -1)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToCart,
                icon: Icon(Icons.shopping_cart_outlined,
                    size: sw * 0.053, color: const Color(0xFF4256D3)),
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
                  padding:
                  EdgeInsets.symmetric(vertical: sh * 0.016),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(width: sw * 0.080),
            Expanded(
              child: ElevatedButton(
                onPressed: _buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4FE8),
                  padding:
                  EdgeInsets.symmetric(vertical: sh * 0.016),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
                      errorBuilder: (_, __, ___) => Icon(Icons.flash_on,
                          color: Colors.white, size: sw * 0.048),
                    ),
                    Transform.translate(
                      offset: Offset(-sw * 0.021, 0),
                      child: Image.asset(
                        'assets/images/flash.png',
                        width: sw * 0.048,
                        height: sw * 0.048,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                        const SizedBox.shrink(),
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
  const _RatingBar(
      {required this.stars, required this.pct, required this.label});
}