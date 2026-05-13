import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smm_power/category/product_details.dart';
import 'package:smm_power/wishlist_state.dart';

// ── MODEL ──────────────────────────────────────────────

class SearchProductModel {
  final int id;
  final String productName;
  final String productCode;
  final String productImage;
  final double price;
  final String stockQty;
  final String taxRate;
  final String description;

  const SearchProductModel({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.productImage,
    required this.price,
    required this.stockQty,
    required this.taxRate,
    required this.description,
  });

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {
    return SearchProductModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      productCode: json['product_code']?.toString() ?? '',
      productImage: json['product_image']?.toString().trim() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stockQty: json['stock_qty']?.toString() ?? '0',
      taxRate: json['tax_rate']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

// ── API SERVICE ────────────────────────────────────────

class _SearchApiService {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';
  static const String _cid = '44555666';

  static Future<List<SearchProductModel>> searchProducts(
      String query) async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getString('latitude') ?? '';
    final longitude = prefs.getString('longitude') ?? '';
    final deviceId = prefs.getString('device_id') ?? '';

    final requestBody = {
      'type': '1019',       // ← update to your actual search API type
      'cid': _cid,
      'lt': latitude,
      'ln': longitude,
      'device_id': deviceId,
      'search': query.trim(),
    };

    print('');
    print('══════════════════════════════════════════');
    print('📤 [SEARCH] REQUEST');
    print('query : $query');
    print('body  : ${jsonEncode(requestBody)}');
    print('══════════════════════════════════════════');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

    print('');
    print('══════════════════════════════════════════');
    print('📥 [SEARCH] RESPONSE');
    print('status : ${response.statusCode}');
    print('body   : ${response.body}');
    print('══════════════════════════════════════════');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final status = decoded['status']?.toString() ?? '';
        if (status == 'success') {
          final data = decoded['data'];
          if (data is List) {
            return data
                .map((e) =>
                SearchProductModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
        // Some APIs wrap in different keys
        if (decoded['products'] is List) {
          return (decoded['products'] as List)
              .map((e) =>
              SearchProductModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } else {
      throw Exception('Search API error: ${response.statusCode}');
    }
  }
}

// ── SCREEN ─────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SearchProductModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  String _lastQuery = '';

  // Debounce timer so we don't fire on every keystroke
  Timer? _debounce;

  // Recent searches (in-memory; persist with SharedPreferences if needed)
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Search logic ───────────────────────────────────

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query == _lastQuery && _hasSearched) return;
    _lastQuery = query;

    // Add to recent searches (deduplicate, max 8)
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) _recentSearches.removeLast();

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final results = await _SearchApiService.searchProducts(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _submitSearch() {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    _debounce?.cancel();
    _performSearch(q);
    _focusNode.unfocus();
  }

  void _applyRecent(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    _performSearch(query);
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
      _error = null;
      _lastQuery = '';
    });
    _focusNode.requestFocus();
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
          _buildSearchBar(sw, sh),
          Expanded(
            child: _buildBody(sw, sh),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR (replaces the home screen bar) ──────

  Widget _buildSearchBar(double sw, double sh) {
    return Container(
      color: const Color(0xFF52B157),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              sw * 0.043, sh * 0.015, sw * 0.043, sh * 0.017),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Icon(Icons.arrow_back,
                    color: Colors.white, size: sw * 0.064),
              ),
              SizedBox(width: sw * 0.027),

              // Search field
              Expanded(
                child: Container(
                  height: sh * 0.057,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF293896)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: sw * 0.032),
                      Icon(Icons.search,
                          color: const Color(0xFFC3C3C3),
                          size: sw * 0.053),
                      SizedBox(width: sw * 0.016),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: _onSearchChanged,
                          onSubmitted: (_) => _submitSearch(),
                          textInputAction: TextInputAction.search,
                          style: TextStyle(
                            fontSize: sw * 0.037,
                            color: const Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(
                              color: const Color(0xFF999999),
                              fontSize: sw * 0.037,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      // Clear button
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: sw * 0.021),
                            child: Icon(Icons.close,
                                color: const Color(0xFF888888),
                                size: sw * 0.048),
                          ),
                        )
                      else
                        SizedBox(width: sw * 0.032),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BODY ───────────────────────────────────────────

  Widget _buildBody(double sw, double sh) {
    // Show recent searches when field is empty
    if (!_hasSearched) {
      return _buildRecentSearches(sw, sh);
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF52B157)),
      );
    }

    if (_error != null) {
      return _buildErrorState(sw, sh);
    }

    if (_results.isEmpty) {
      return _buildEmptyState(sw, sh);
    }

    return _buildResults(sw, sh);
  }

  // ── RECENT SEARCHES ────────────────────────────────

  Widget _buildRecentSearches(double sw, double sh) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
          sw * 0.053, sh * 0.020, sw * 0.053, sh * 0.020),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _recentSearches.clear()),
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: sw * 0.034,
                    color: const Color(0xFF4256D3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.012),
          ..._recentSearches.map((q) => _recentTile(q, sw, sh)),
          SizedBox(height: sh * 0.025),
          const Divider(color: Color(0xFFF0F0F0)),
          SizedBox(height: sh * 0.015),
        ],

        // Popular / suggestion chips
        Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: sw * 0.040,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: sh * 0.015),
        Wrap(
          spacing: sw * 0.027,
          runSpacing: sh * 0.010,
          children: [
            'Solar Light',
            'LED Panel',
            'Switch',
            'Cable',
            'Inverter',
            'Battery',
            'Solar Panel',
            'MCB',
          ].map((s) => _suggestionChip(s, sw, sh)).toList(),
        ),
      ],
    );
  }

  Widget _recentTile(String query, double sw, double sh) {
    return InkWell(
      onTap: () => _applyRecent(query),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.011),
        child: Row(
          children: [
            Icon(Icons.history,
                size: sw * 0.048, color: const Color(0xFF888888)),
            SizedBox(width: sw * 0.032),
            Expanded(
              child: Text(
                query,
                style: TextStyle(
                    fontSize: sw * 0.037, color: const Color(0xFF373737)),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _recentSearches.remove(query)),
              child: Icon(Icons.close,
                  size: sw * 0.040, color: const Color(0xFFCCCCCC)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String label, double sw, double sh) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
        _focusNode.unfocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.037, vertical: sh * 0.009),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD0D4FF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.032,
            color: const Color(0xFF4256D3),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ── RESULTS LIST ───────────────────────────────────

  Widget _buildResults(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              sw * 0.053, sh * 0.015, sw * 0.053, sh * 0.008),
          child: Text(
            '${_results.length} result${_results.length == 1 ? '' : 's'} for "${_lastQuery}"',
            style: TextStyle(
              fontSize: sw * 0.034,
              color: const Color(0xFF888888),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.043, vertical: sh * 0.008),
            itemCount: _results.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (ctx, i) =>
                _SearchResultTile(product: _results[i], sw: sw, sh: sh),
          ),
        ),
      ],
    );
  }

  // ── EMPTY STATE ────────────────────────────────────

  Widget _buildEmptyState(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: sw * 0.24, color: const Color(0xFFCCCCCC)),
          SizedBox(height: sh * 0.018),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: sw * 0.048,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
                fontSize: sw * 0.035, color: const Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  // ── ERROR STATE ────────────────────────────────────

  Widget _buildErrorState(double sw, double sh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: Colors.red, size: sw * 0.18),
            SizedBox(height: sh * 0.018),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: sw * 0.043,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: sh * 0.008),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: sw * 0.032, color: const Color(0xFF888888)),
            ),
            SizedBox(height: sh * 0.025),
            ElevatedButton.icon(
              onPressed: () => _performSearch(_lastQuery),
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
}

// ── SEARCH RESULT TILE ─────────────────────────────────

class _SearchResultTile extends StatelessWidget {
  final SearchProductModel product;
  final double sw;
  final double sh;

  const _SearchResultTile({
    required this.product,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    final isWishlisted = wishlistNotifier.isWishlisted(WishlistItem(
      name: product.productName,
      mrp: product.price.toInt(),
      price: product.price.toInt(),
      unit: 'piece',
      image: product.productImage,
    ));

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            productId: product.id,
            productName: product.productName,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.013),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image
            Container(
              width: sw * 0.192,
              height: sw * 0.192,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.productImage.isNotEmpty
                    ? Image.network(
                  product.productImage,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) =>
                  progress == null
                      ? child
                      : const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Color(0xFF52B157),
                    ),
                  ),
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_outlined,
                    size: sw * 0.096,
                    color: Colors.grey,
                  ),
                )
                    : Icon(Icons.image_outlined,
                    size: sw * 0.096, color: Colors.grey),
              ),
            ),

            SizedBox(width: sw * 0.037),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sw * 0.037,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),

                  if (product.productCode.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: sh * 0.004),
                      child: Text(
                        'Code: ${product.productCode}',
                        style: TextStyle(
                          fontSize: sw * 0.030,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ),

                  SizedBox(height: sh * 0.008),

                  // Price
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: sw * 0.043,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),

                  SizedBox(height: sh * 0.006),

                  // Tags row
                  Row(
                    children: [
                      if (product.taxRate.isNotEmpty)
                        _tag('Tax: ${product.taxRate}%',
                            const Color(0xFFEBFFEC),
                            const Color(0xFF41A900), sw, sh),
                      if (product.taxRate.isNotEmpty)
                        SizedBox(width: sw * 0.016),
                      _tag(
                        int.tryParse(product.stockQty) != null &&
                            int.parse(product.stockQty) > 0
                            ? 'In Stock'
                            : 'Out of Stock',
                        int.tryParse(product.stockQty) != null &&
                            int.parse(product.stockQty) > 0
                            ? const Color(0xFFF4F5FF)
                            : const Color(0xFFFFF0F0),
                        int.tryParse(product.stockQty) != null &&
                            int.parse(product.stockQty) > 0
                            ? const Color(0xFF4256D3)
                            : const Color(0xFFD05255),
                        sw,
                        sh,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: sw * 0.021),

            // Wishlist icon
            ValueListenableBuilder<List<WishlistItem>>(
              valueListenable: wishlistNotifier,
              builder: (context, wishlist, _) {
                final wItem = WishlistItem(
                  name: product.productName,
                  mrp: product.price.toInt(),
                  price: product.price.toInt(),
                  unit: 'piece',
                  image: product.productImage,
                );
                final isW = wishlistNotifier.isWishlisted(wItem);
                return GestureDetector(
                  onTap: () => wishlistNotifier.toggle(wItem),
                  child: Icon(
                    isW ? Icons.favorite : Icons.favorite_border,
                    color: isW ? Colors.red : const Color(0xFF929292),
                    size: sw * 0.053,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color bg, Color textColor, double sw, double sh) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.021, vertical: sh * 0.003),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: sw * 0.027,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}