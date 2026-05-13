import 'package:flutter/material.dart';
import 'package:smm_power/service/category_api_service.dart';
import 'package:smm_power/category/product_details.dart'; // <-- import the new details screen

// ══════════════════════════════════════════════════════
//  CATEGORY SCREEN  —  API Bound Version  (with product navigation)
// ══════════════════════════════════════════════════════

class CategoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  /// When coming from HomeScreen, pass the category id to jump directly to it.
  /// If null, the first category in the list is selected by default.
  final int? initialCategoryId;

  const CategoryScreen({
    super.key,
    this.onBack,
    this.initialCategoryId,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // ── State ────────────────────────────────────────────
  int _selectedSideIndex = 0;
  int _selectedSortIndex = 0;

  // Left sidebar data (TYPE 100)
  List<SideCategoryModel> _sideCategories = [];
  bool _isSideLoading = true;
  String? _sideError;

  // Right content data (TYPE 101)
  List<SubCategoryItemModel> _subItems = [];
  bool _isContentLoading = false;
  String? _contentError;

  // ── Lifecycle ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadSideCategories();
  }

  // ── API Calls ─────────────────────────────────────────

  Future<void> _loadSideCategories() async {
    // ⚡ Cache warm (preloaded at login) → show instantly, zero wait
    if (CategoryCache.isSideCacheReady) {
      final categories = CategoryCache.sideCategories;
      int startIndex = 0;
      if (widget.initialCategoryId != null) {
        final found = categories.indexWhere((c) => c.id == widget.initialCategoryId);
        if (found != -1) startIndex = found;
      }
      setState(() {
        _sideCategories    = categories;
        _selectedSideIndex = startIndex;
        _isSideLoading     = false;
      });
      if (categories.isNotEmpty) _loadSubCategoryItems(categories[startIndex].id);
      return;
    }

    // Cold start — only if preloadAll() wasn't called yet
    setState(() {
      _isSideLoading = true;
      _sideError = null;
    });

    try {
      final categories = await CategoryApiService.fetchSideCategories();

      int startIndex = 0;
      if (widget.initialCategoryId != null) {
        final found = categories.indexWhere(
              (c) => c.id == widget.initialCategoryId,
        );
        if (found != -1) startIndex = found;
      }

      setState(() {
        _sideCategories = categories;
        _selectedSideIndex = startIndex;
        _isSideLoading = false;
      });

      if (categories.isNotEmpty) {
        _loadSubCategoryItems(categories[startIndex].id);
      }
    } catch (e) {
      print('❌ Side Categories Error: $e');
      setState(() {
        _isSideLoading = false;
        _sideError = e.toString();
      });
    }
  }

  Future<void> _loadSubCategoryItems(int subCategoryId) async {
    // ⚡ Cache warm → show instantly, no spinner at all
    if (CategoryCache.isSubCachReady(subCategoryId)) {
      setState(() {
        _subItems         = CategoryCache.getSubItems(subCategoryId);
        _isContentLoading = false;
        _contentError     = null;
      });
      return;
    }

    // Cold start — fetch from network
    setState(() {
      _isContentLoading = true;
      _contentError = null;
      _subItems = [];
    });

    try {
      final items =
      await CategoryApiService.fetchSubCategoryItems(subCategoryId);
      setState(() {
        _subItems = items;
        _isContentLoading = false;
      });
    } catch (e) {
      print('❌ Sub-Category Items Error: $e');
      setState(() {
        _isContentLoading = false;
        _contentError = e.toString();
      });
    }
  }

  // ── Navigate to Product Details ───────────────────────
  void _openProductDetail(SubCategoryItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: item.id,
          // Pass the product name so the AppBar title is shown
          // immediately while the API loads — avoids blank title.
          productName: item.productName,
        ),
      ),
    );
  }

  // ── Sort Bottom Sheet ─────────────────────────────────
  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sort By",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSortTile("Relevance", 0, setModalState),
                  _buildSortTile("Discount", 1, setModalState),
                  _buildSortTile("Price (lowest first)", 2, setModalState),
                  _buildSortTile("Whats New", 3, setModalState),
                  _buildSortTile("Price (Highest first)", 4, setModalState),
                  _buildSortTile("Ratings", 5, setModalState),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortTile(String title, int index, Function setModalState) {
    return InkWell(
      onTap: () {
        setModalState(() => _selectedSortIndex = index);
        Navigator.pop(context);
        print("✅ Sort Selected: $title");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: _selectedSortIndex == index
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(sh * 0.069),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.032),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Colors.black, size: sw * 0.064),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                  SizedBox(width: sw * 0.011),
                  Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: sw * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.search,
                            size: sw * 0.06, color: Colors.black),
                      ),
                      SizedBox(width: sw * 0.03),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.favorite_border,
                            size: sw * 0.06, color: Colors.black),
                      ),
                      SizedBox(width: sw * 0.03),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.shopping_cart_outlined,
                            size: sw * 0.06, color: Colors.black),
                      ),
                      SizedBox(width: sw * 0.02),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSidebar(sw, sh),
            Expanded(child: _buildContent(sw, sh)),
          ],
        ),
      ),
    );
  }

  // ── LEFT SIDEBAR (TYPE 100 data) ──────────────────────
  Widget _buildSidebar(double sw, double sh) {
    return Container(
      width: sw * 0.219,
      color: const Color(0xFFE5FFE7),
      child: _isSideLoading
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
            strokeWidth: 2,
          ),
        ),
      )
          : _sideError != null
          ? _buildSideError(sw)
          : _sideCategories.isEmpty
          ? _buildSideEmpty(sw)
          : ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _sideCategories.length,
        itemBuilder: (ctx, i) {
          final cat = _sideCategories[i];
          final isSelected = i == _selectedSideIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedSideIndex = i);
              _loadSubCategoryItems(cat.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFFE5FFE7),
                border: Border(
                  left: BorderSide(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    width: 3,
                  ),
                  bottom: const BorderSide(
                      color: Color(0xFF4256D3)),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: sh * 0.015,
                horizontal: sw * 0.021,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: sw * 0.139,
                    height: sw * 0.139,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: ClipOval(
                      child: cat.image.isNotEmpty
                          ? Image.network(
                        cat.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.category,
                          size: sw * 0.07,
                          color: const Color(0xFF4256D3),
                        ),
                      )
                          : Icon(
                        Icons.category,
                        size: sw * 0.07,
                        color: const Color(0xFF4256D3),
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.007),
                  Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sw * 0.029,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: const Color(0xFF4256D3),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSideError(double sw) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: sw * 0.08),
          const SizedBox(height: 6),
          Text(
            'Failed to load',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: sw * 0.027, color: Colors.red),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _loadSideCategories,
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: sw * 0.027,
                color: const Color(0xFF4256D3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideEmpty(double sw) {
    return Center(
      child: Text(
        'No categories',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: sw * 0.027, color: Colors.grey),
      ),
    );
  }

  // ── RIGHT CONTENT (TYPE 101 data) ─────────────────────
  Widget _buildContent(double sw, double sh) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView(
        padding: EdgeInsets.all(sw * 0.032),
        children: [
          // Sort By
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _showSortBottomSheet(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.025,
                    vertical: sh * 0.006,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF4256D3)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_vert,
                          size: sw * 0.045, color: const Color(0xFF4256D3)),
                      SizedBox(width: sw * 0.01),
                      Text(
                        "Sort By",
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          color: const Color(0xFF4256D3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.012),

          // Section title
          if (_sideCategories.isNotEmpty)
            Row(
              children: [
                Text(
                  _sideCategories[_selectedSideIndex].label,
                  style: TextStyle(
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(width: sw * 0.021),
                Expanded(
                  child: Container(
                      height: 1, color: const Color(0xFF868282)),
                ),
              ],
            ),

          SizedBox(height: sh * 0.017),

          // Content area
          _isContentLoading
              ? const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4256D3),
              ),
            ),
          )
              : _contentError != null
              ? _buildContentError(sw, sh)
              : _subItems.isEmpty
              ? _buildContentEmpty(sw, sh)
              : _buildItemGrid(_subItems, sw, sh),
        ],
      ),
    );
  }

  Widget _buildContentError(double sw, double sh) {
    return SizedBox(
      height: sh * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: sw * 0.12),
          const SizedBox(height: 8),
          Text(
            'Failed to load items',
            style: TextStyle(fontSize: sw * 0.037, color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_sideCategories.isNotEmpty) {
                _loadSubCategoryItems(
                    _sideCategories[_selectedSideIndex].id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4256D3),
            ),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentEmpty(double sw, double sh) {
    return SizedBox(
      height: sh * 0.3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: sw * 0.15, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'No items found',
              style:
              TextStyle(fontSize: sw * 0.04, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(
      List<SubCategoryItemModel> items, double sw, double sh) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (ctx, i) => GestureDetector(
        onTap: () => _openProductDetail(items[i]),   // ← NAVIGATE on tap
        child: _SubCategoryItemCard(
          item: items[i],
          sw: sw,
          sh: sh,
        ),
      ),
    );
  }
}

// ── SUB-CATEGORY ITEM CARD ────────────────────────────
class _SubCategoryItemCard extends StatelessWidget {
  final SubCategoryItemModel item;
  final double sw;
  final double sh;

  const _SubCategoryItemCard({
    required this.item,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // White circle
        Container(
          width: sw * 0.173,
          height: sw * 0.173,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: item.hasImage
              ? ClipOval(
            child: Image.network(
              item.productImage!,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(color: const Color(0xFFEEEEEE)),
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: sw * 0.08,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
            ),
          )
              : Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: sw * 0.08,
              color: const Color(0xFFBDBDBD),
            ),
          ),
        ),

        SizedBox(height: sh * 0.007),

        // Product name
        Text(
          item.productName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: sw * 0.027,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF000000),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}