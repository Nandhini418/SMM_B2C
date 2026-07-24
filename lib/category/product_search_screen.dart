import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smm_power/category/product_details.dart';
import 'package:smm_power/service/category_api_service.dart';

// ══════════════════════════════════════════════════════
//  RECENT SEARCH STORE
//  Persists up to 10 recent searches via SharedPreferences.
// ══════════════════════════════════════════════════════

class _RecentSearchStore {
  static const _key = 'recent_product_searches';
  static const _max = 10;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Add to the top, deduplicate (case-insensitive), trim to [_max].
  static Future<List<String>> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return load();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((s) => s.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    if (list.length > _max) list.removeRange(_max, list.length);
    await prefs.setStringList(_key, list);
    return list;
  }

  static Future<List<String>> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((s) => s.toLowerCase() == query.toLowerCase());
    await prefs.setStringList(_key, list);
    return list;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

// ══════════════════════════════════════════════════════
//  PRODUCT SEARCH SCREEN
//  Searches across all cached sub-category items.
//  Falls back to a network fetch if the cache is cold.
// ══════════════════════════════════════════════════════

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // All products flattened from cache / network
  List<SubCategoryItemModel> _allProducts = [];
  // Filtered results shown to user
  List<SubCategoryItemModel> _results = [];
  // Recent searches
  List<String> _recentSearches = [];

  bool _isLoadingProducts = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadAllProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Recent searches ───────────────────────────────

  Future<void> _loadRecentSearches() async {
    final list = await _RecentSearchStore.load();
    if (mounted) setState(() => _recentSearches = list);
  }

  Future<void> _saveSearch(String query) async {
    final list = await _RecentSearchStore.add(query.trim());
    if (mounted) setState(() => _recentSearches = list);
  }

  Future<void> _removeSearch(String query) async {
    final list = await _RecentSearchStore.remove(query);
    if (mounted) setState(() => _recentSearches = list);
  }

  Future<void> _clearAllSearches() async {
    await _RecentSearchStore.clear();
    if (mounted) setState(() => _recentSearches = []);
  }

  // ── Load all products ─────────────────────────────

  Future<void> _loadAllProducts() async {
    setState(() => _isLoadingProducts = true);

    try {
      final categories = CategoryCache.isSideCacheReady
          ? CategoryCache.sideCategories
          : await CategoryApiService.fetchSideCategories();

      final List<SubCategoryItemModel> all = [];

      await Future.wait(
        categories.map((cat) async {
          try {
            final items =
            await CategoryApiService.fetchSubCategoryItems(cat.id);
            all.addAll(items);
          } catch (_) {}
        }),
      );

      final seen = <int>{};
      final unique = all.where((p) => seen.add(p.id)).toList();

      if (mounted) {
        setState(() {
          _allProducts = unique;
          _isLoadingProducts = false;
          _applyFilter(_query);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  // ── Filter & submit ───────────────────────────────

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _query = query;
      _results = q.isEmpty
          ? []
          : _allProducts
          .where((p) => p.productName.toLowerCase().contains(q))
          .toList();
    });
  }

  /// Called on keyboard submit or recent chip/row tap.
  void _submitSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _controller.text = q;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: q.length));
    _applyFilter(q);
    _saveSearch(q);
    _focusNode.unfocus();
  }

  // ── Navigate to product detail ────────────────────

  void _openProduct(SubCategoryItemModel item) {
    _saveSearch(item.productName);
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

  // ── Build ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(sh * 0.075),
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
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.032, vertical: sw * 0.014),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back,
                        color: Colors.black, size: sw * 0.060),
                  ),
                  SizedBox(width: sw * 0.025),
                  Expanded(
                    child: Container(
                      height: sh * 0.047,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE0E0E0), width: 1),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _applyFilter,
                        onSubmitted: _submitSearch,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                              fontSize: sw * 0.035, color: Colors.grey),
                          prefixIcon: Icon(Icons.search,
                              size: sw * 0.050,
                              color: const Color(0xFF4256D3)),
                          suffixIcon: _controller.text.isNotEmpty
                              ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              _applyFilter('');
                              _focusNode.requestFocus();
                            },
                            child: Icon(Icons.close,
                                size: sw * 0.045,
                                color: Colors.grey),
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: sh * 0.011),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(child: _buildBody(sw, sh)),
    );
  }

  Widget _buildBody(double sw, double sh) {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4256D3)),
      );
    }

    // Empty query → recent searches (or first-time hint)
    if (_query.trim().isEmpty) {
      return _buildRecentView(sw, sh);
    }

    // Has query but no matches
    if (_results.isEmpty) {
      return _buildNoResults(sw, sh);
    }

    // Results list
    return ListView.separated(
      padding: EdgeInsets.symmetric(
          vertical: sh * 0.010, horizontal: sw * 0.032),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (ctx, i) => _buildResultTile(_results[i], sw, sh),
    );
  }

  // ── Recent Searches View ──────────────────────────

  Widget _buildRecentView(double sw, double sh) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search,
                size: sw * 0.20, color: const Color(0xFFD0D5F5)),
            SizedBox(height: sh * 0.020),
            Text(
              'Search for products',
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: sh * 0.008),
            Text(
              'Type a product name to find it.',
              style: TextStyle(
                  fontSize: sw * 0.034, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──
        Padding(
          padding: EdgeInsets.fromLTRB(
              sw * 0.043, sh * 0.020, sw * 0.032, sh * 0.012),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: _clearAllSearches,
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: sw * 0.034,
                    color: const Color(0xFF4256D3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Chips (wrapping) ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.040),
          child: Wrap(
            spacing: sw * 0.022,
            runSpacing: sh * 0.010,
            children: _recentSearches
                .map((s) => _RecentChip(
              label: s,
              sw: sw,
              sh: sh,
              onTap: () => _submitSearch(s),
              onRemove: () => _removeSearch(s),
            ))
                .toList(),
          ),
        ),

        SizedBox(height: sh * 0.020),
        const Divider(color: Color(0xFFEEEEEE), height: 1),

        // ── List rows with history icon ──
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: sh * 0.006),
            itemCount: _recentSearches.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (ctx, i) =>
                _buildRecentRow(_recentSearches[i], sw, sh),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRow(String search, double sw, double sh) {
    return InkWell(
      onTap: () => _submitSearch(search),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.043, vertical: sh * 0.014),
        child: Row(
          children: [
            Icon(Icons.history,
                size: sw * 0.050, color: Colors.grey.shade400),
            SizedBox(width: sw * 0.032),
            Expanded(
              child: Text(
                search,
                style: TextStyle(
                    fontSize: sw * 0.037,
                    color: const Color(0xFF1A1A1A)),
              ),
            ),
            // Arrow-up-left: paste into field without submitting
            GestureDetector(
              onTap: () {
                _controller.text = search;
                _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: search.length));
                _applyFilter(search);
                _focusNode.requestFocus();
              },
              child: Icon(Icons.north_west,
                  size: sw * 0.042, color: Colors.grey.shade400),
            ),
            SizedBox(width: sw * 0.020),
            // Remove from list
            GestureDetector(
              onTap: () => _removeSearch(search),
              child: Icon(Icons.close,
                  size: sw * 0.042, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  // ── No Results ────────────────────────────────────

  Widget _buildNoResults(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Keep chips visible so user can pivot to a recent search
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.043, sh * 0.016, sw * 0.032, sh * 0.010),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: sw * 0.036,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllSearches,
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: sw * 0.032,
                      color: const Color(0xFF4256D3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.040),
            child: Wrap(
              spacing: sw * 0.020,
              runSpacing: sh * 0.008,
              children: _recentSearches
                  .map((s) => _RecentChip(
                label: s,
                sw: sw,
                sh: sh,
                onTap: () => _submitSearch(s),
                onRemove: () => _removeSearch(s),
              ))
                  .toList(),
            ),
          ),
          SizedBox(height: sh * 0.016),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
        ],

        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: sw * 0.18, color: const Color(0xFFD0D5F5)),
                SizedBox(height: sh * 0.018),
                Text(
                  'No results for "$_query"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sw * 0.040,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: sh * 0.008),
                Text(
                  'Try a different keyword.',
                  style: TextStyle(
                      fontSize: sw * 0.034, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Result Tile ───────────────────────────────────

  Widget _buildResultTile(
      SubCategoryItemModel item, double sw, double sh) {
    return InkWell(
      onTap: () => _openProduct(item),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: sh * 0.012, horizontal: sw * 0.010),
        child: Row(
          children: [
            Container(
              width: sw * 0.133,
              height: sw * 0.133,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: item.hasImage
                  ? ClipOval(
                child: Image.network(
                  item.productImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _placeholderIcon(sw),
                ),
              )
                  : _placeholderIcon(sw),
            ),
            SizedBox(width: sw * 0.032),
            Expanded(
              child: _HighlightText(
                text: item.productName,
                query: _query,
                style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
                highlightStyle: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4256D3),
                  backgroundColor:
                  const Color(0xFF4256D3).withOpacity(0.08),
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                size: sw * 0.050, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon(double sw) => Center(
    child: Icon(
      Icons.image_not_supported_outlined,
      size: sw * 0.060,
      color: const Color(0xFFBDBDBD),
    ),
  );
}

// ══════════════════════════════════════════════════════
//  RECENT SEARCH CHIP
// ══════════════════════════════════════════════════════

class _RecentChip extends StatelessWidget {
  final String label;
  final double sw;
  final double sh;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({
    required this.label,
    required this.sw,
    required this.sh,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.030, vertical: sh * 0.007),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0FB),
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: const Color(0xFFCDD1F5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: sw * 0.036, color: const Color(0xFF4256D3)),
            SizedBox(width: sw * 0.014),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.032,
                color: const Color(0xFF4256D3),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: sw * 0.014),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Icon(Icons.close,
                  size: sw * 0.032,
                  color: const Color(0xFF8891D9)),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  HIGHLIGHT MATCHING TEXT
// ══════════════════════════════════════════════════════

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(text,
          style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.trim().toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) {
        spans.add(
            TextSpan(text: text.substring(start, idx), style: style));
      }
      spans.add(TextSpan(
          text: text.substring(idx, idx + lowerQuery.length),
          style: highlightStyle));
      start = idx + lowerQuery.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}