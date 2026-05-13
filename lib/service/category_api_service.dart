import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SideCategoryModel {
  final int id;
  final String label;
  final String image;

  const SideCategoryModel({
    required this.id,
    required this.label,
    required this.image,
  });

  factory SideCategoryModel.fromJson(Map<String, dynamic> json) {
    return SideCategoryModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      label: json['name']?.toString().toUpperCase() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}

class SubCategoryItemModel {
  final int id;
  final String productName;
  final String? productImage;

  const SubCategoryItemModel({
    required this.id,
    required this.productName,
    this.productImage,
  });

  /// true only when the image URL is a real non-empty string
  bool get hasImage {
    final img = productImage;
    return img != null && img.trim().isNotEmpty;
  }

  factory SubCategoryItemModel.fromJson(Map<String, dynamic> json) {
    // product_image can be: a URL string, "" (empty string), or null
    final rawImage = json['product_image']?.toString().trim();
    return SubCategoryItemModel(
      id          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productName : json['product_name']?.toString() ?? '',
      productImage: (rawImage != null && rawImage.isNotEmpty) ? rawImage : null,
    );
  }
}

class SubCategorySectionModel {
  final String title;
  final List<SubCategoryItemModel> items;

  const SubCategorySectionModel({
    required this.title,
    required this.items,
  });
}

// ── SESSION HELPER ────────────────────────────────────
// Reads the lat, lon, device_id saved by Login_Page into SharedPreferences.

class _SessionParams {
  final String latitude;
  final String longitude;
  final String deviceId;

  const _SessionParams({
    required this.latitude,
    required this.longitude,
    required this.deviceId,
  });

  /// Reads values saved by Login_Page:
  ///   prefs.setString('latitude',  position.latitude.toString())
  ///   prefs.setString('longitude', position.longitude.toString())
  ///   prefs.setString('device_id', androidInfo.id)
  static Future<_SessionParams> load() async {
    final prefs = await SharedPreferences.getInstance();

    final latitude  = prefs.getString('latitude')  ?? '';
    final longitude = prefs.getString('longitude') ?? '';
    final deviceId  = prefs.getString('device_id') ?? '';

    print('');
    print('══════════════════════════════════════════');
    print('🔑 SESSION PARAMS (from SharedPreferences)');
    print('══════════════════════════════════════════');
    print('latitude  : $latitude');
    print('longitude : $longitude');
    print('device_id : $deviceId');
    print('══════════════════════════════════════════');
    print('');

    return _SessionParams(
      latitude:  latitude,
      longitude: longitude,
      deviceId:  deviceId,
    );
  }
}

// ══════════════════════════════════════════════════════
//  IN-MEMORY CACHE
//  Holds data fetched during preload so every screen reads
//  instantly without waiting for the network.
// ══════════════════════════════════════════════════════

class CategoryCache {
  CategoryCache._(); // singleton — never instantiate directly

  /// TYPE 100 result — left sidebar list
  static List<SideCategoryModel> sideCategories = [];

  /// TYPE 101 results — keyed by sub-category id
  /// e.g. _subItems[1] = [Solar Wall Light W01, ...]
  static final Map<int, List<SubCategoryItemModel>> _subItems = {};

  static bool get isSideCacheReady => sideCategories.isNotEmpty;

  static bool isSubCachReady(int subCategoryId) =>
      _subItems.containsKey(subCategoryId);

  static List<SubCategoryItemModel> getSubItems(int subCategoryId) =>
      _subItems[subCategoryId] ?? [];

  static void storeSideCategories(List<SideCategoryModel> list) {
    sideCategories = list;
  }

  static void storeSubItems(int subCategoryId, List<SubCategoryItemModel> items) {
    _subItems[subCategoryId] = items;
  }

  /// Clear everything (call on logout)
  static void clear() {
    sideCategories = [];
    _subItems.clear();
  }
}

// ══════════════════════════════════════════════════════
//  API SERVICE
// ══════════════════════════════════════════════════════

class CategoryApiService {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';
  static const String _cid     = '44555666';

  // ────────────────────────────────────────────────────
  //  PRELOAD — call this once right after login.
  //  1. Fetches TYPE 100 (side categories).
  //  2. Fires all TYPE 101 calls IN PARALLEL (one per category).
  //  3. Stores everything in CategoryCache.
  //  After this returns the CategoryScreen opens instantly.
  // ────────────────────────────────────────────────────
  static Future<void> preloadAll() async {
    print('');
    print('🚀 [PRELOAD] Starting full category preload...');

    try {
      // Step 1 — side categories (TYPE 100)
      final categories = await _fetchSideCategoriesNetwork();
      CategoryCache.storeSideCategories(categories);
      print('✅ [PRELOAD] Side categories cached: ${categories.length} items');

      // Step 2 — all sub-category items in parallel (TYPE 101 × N)
      await Future.wait(
        categories.map((cat) async {
          try {
            final items = await _fetchSubCategoryItemsNetwork(cat.id);
            CategoryCache.storeSubItems(cat.id, items);
            print('✅ [PRELOAD] Sub-items cached for "${cat.label}" (id:${cat.id}): ${items.length} items');
          } catch (e) {
            // One category failing must not block the others
            print('⚠️ [PRELOAD] Failed for category id:${cat.id} — $e');
          }
        }),
      );

      print('🏁 [PRELOAD] All categories preloaded successfully.');
    } catch (e) {
      print('❌ [PRELOAD] Critical failure: $e');
    }
  }

  // ────────────────────────────────────────────────────
  //  TYPE 100 — public entry point.
  //  Returns cache instantly if warm; fetches otherwise.
  // ────────────────────────────────────────────────────
  static Future<List<SideCategoryModel>> fetchSideCategories() async {
    if (CategoryCache.isSideCacheReady) {
      print('⚡ [TYPE 100] Served from cache (${CategoryCache.sideCategories.length} items)');
      return CategoryCache.sideCategories;
    }
    // Cache miss — fetch and store
    final result = await _fetchSideCategoriesNetwork();
    CategoryCache.storeSideCategories(result);
    return result;
  }

  // ────────────────────────────────────────────────────
  //  TYPE 101 — public entry point.
  //  Returns cache instantly if warm; fetches otherwise.
  // ────────────────────────────────────────────────────
  static Future<List<SubCategoryItemModel>> fetchSubCategoryItems(
      int subCategoryId) async {
    if (CategoryCache.isSubCachReady(subCategoryId)) {
      final cached = CategoryCache.getSubItems(subCategoryId);
      print('⚡ [TYPE 101] Served from cache for id:$subCategoryId (${cached.length} items)');
      return cached;
    }
    // Cache miss — fetch and store
    final result = await _fetchSubCategoryItemsNetwork(subCategoryId);
    CategoryCache.storeSubItems(subCategoryId, result);
    return result;
  }

  // ════════════════════════════════════════════════════
  //  PRIVATE NETWORK METHODS
  //  These always hit the network — only called by the
  //  public methods above when the cache is cold.
  // ════════════════════════════════════════════════════

  static Future<List<SideCategoryModel>> _fetchSideCategoriesNetwork() async {
    final session = await _SessionParams.load();

    final requestBody = {
      'type'      : '100',
      'cid'       : _cid,
      'lt'        : session.latitude,
      'ln'        : session.longitude,
      'device_id' : session.deviceId,
    };

    print('');
    print('══════════════════════════════════════════');
    print('📤 [TYPE 100] REQUEST — Side Categories');
    print('══════════════════════════════════════════');
    print('URL       : $_baseUrl');
    print('latitude  : ${session.latitude}');
    print('longitude : ${session.longitude}');
    print('device_id : ${session.deviceId}');
    print('Full Body : ${jsonEncode(requestBody)}');
    print('══════════════════════════════════════════');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

    print('');
    print('══════════════════════════════════════════');
    print('📥 [TYPE 100] RESPONSE — Side Categories');
    print('══════════════════════════════════════════');
    print('Status Code : ${response.statusCode}');
    print('Body        : ${response.body}');
    print('══════════════════════════════════════════');
    print('');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> dataList = [];
      if (decoded is List) {
        dataList = decoded;
      } else if (decoded is Map && decoded['data'] != null) {
        dataList = decoded['data'] as List<dynamic>;
      } else if (decoded is Map && decoded['categories'] != null) {
        dataList = decoded['categories'] as List<dynamic>;
      }
      return dataList
          .map((e) => SideCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('[TYPE 100] API Error: Status ${response.statusCode}');
    }
  }

  static Future<List<SubCategoryItemModel>> _fetchSubCategoryItemsNetwork(
      int subCategoryId) async {
    final session = await _SessionParams.load();

    final requestBody = {
      'type'         : '101',
      'cid'          : _cid,
      'lt'           : session.latitude,
      'ln'           : session.longitude,
      'device_id'    : session.deviceId,
      'sub_category' : subCategoryId.toString(),
    };

    print('');
    print('══════════════════════════════════════════');
    print('📤 [TYPE 101] REQUEST — Sub-Category id:$subCategoryId');
    print('══════════════════════════════════════════');
    print('URL           : $_baseUrl');
    print('latitude      : ${session.latitude}');
    print('longitude     : ${session.longitude}');
    print('device_id     : ${session.deviceId}');
    print('sub_category  : $subCategoryId');
    print('Full Body     : ${jsonEncode(requestBody)}');
    print('══════════════════════════════════════════');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

    print('');
    print('══════════════════════════════════════════');
    print('📥 [TYPE 101] RESPONSE — Sub-Category id:$subCategoryId');
    print('══════════════════════════════════════════');
    print('Status Code : ${response.statusCode}');
    print('Body        : ${response.body}');
    print('══════════════════════════════════════════');
    print('');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> dataList = [];
      if (decoded is List) {
        dataList = decoded;
      } else if (decoded is Map && decoded['data'] != null) {
        dataList = decoded['data'] as List<dynamic>;
      } else if (decoded is Map && decoded['products'] != null) {
        dataList = decoded['products'] as List<dynamic>;
      } else if (decoded is Map && decoded['items'] != null) {
        dataList = decoded['items'] as List<dynamic>;
      }
      return dataList
          .map((e) => SubCategoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('[TYPE 101] API Error: Status ${response.statusCode}');
    }
  }
}