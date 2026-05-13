import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── MODEL ─────────────────────────────────────────────

class ProductDetailModel {
  final int id;
  final String productName;
  final String productCode;
  final String description;
  final String productImage;
  final List<String> photos;
  final double price;
  final String stockQty;
  final String taxRate;
  final String hsnSacCode;
  final String technicalName;
  final String size;
  final String grade;
  final String model;
  final String make;

  const ProductDetailModel({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.description,
    required this.productImage,
    required this.photos,
    required this.price,
    required this.stockQty,
    required this.taxRate,
    required this.hsnSacCode,
    required this.technicalName,
    required this.size,
    required this.grade,
    required this.model,
    required this.make,
  });

  /// Convenience int getter — use when CartItemModel/WishlistItem expect int
  int get priceInt => price.toInt();

  /// True when the primary image URL is non-empty
  bool get hasImage => productImage.trim().isNotEmpty;

  /// Returns photos list if non-empty, else falls back to productImage
  List<String> get allImages {
    if (photos.isNotEmpty) return photos;
    if (hasImage) return [productImage];
    return [];
  }

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    // photos can be a List<dynamic> or absent
    final rawPhotos = json['photos'];
    final List<String> photoList = rawPhotos is List
        ? rawPhotos.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : [];

    return ProductDetailModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      productCode: json['product_code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      productImage: json['product_image']?.toString().trim() ?? '',
      photos: photoList,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stockQty: json['stock_qty']?.toString() ?? '0',
      taxRate: json['tax_rate']?.toString() ?? '',
      hsnSacCode: json['hsn_sac_code']?.toString() ?? '',
      technicalName: json['technical_name']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
    );
  }
}

// ── SESSION HELPER ─────────────────────────────────────

class _SessionParams {
  final String latitude;
  final String longitude;
  final String deviceId;

  const _SessionParams({
    required this.latitude,
    required this.longitude,
    required this.deviceId,
  });

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

// ── API SERVICE ───────────────────────────────────────

class ProductApiService {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';
  static const String _cid     = '44555666';

  /// TYPE 1018 — Fetch full product details by [productId]
  static Future<ProductDetailModel> fetchProductDetail(int productId) async {
    final session = await _SessionParams.load();

    final requestBody = {
      'type'      : '1018',
      'cid'       : _cid,
      'lt'        : session.latitude,
      'ln'        : session.longitude,
      'device_id' : session.deviceId,
      'pro_id'    : productId.toString(),
    };

    print('');
    print('══════════════════════════════════════════');
    print('📤 [TYPE 1018] REQUEST — Product Detail');
    print('══════════════════════════════════════════');
    print('URL       : $_baseUrl');
    print('pro_id    : $productId');
    print('Full Body : ${jsonEncode(requestBody)}');
    print('══════════════════════════════════════════');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requestBody,
    );

    print('');
    print('══════════════════════════════════════════');
    print('📥 [TYPE 1018] RESPONSE — Product Detail');
    print('══════════════════════════════════════════');
    print('Status Code : ${response.statusCode}');
    print('Body        : ${response.body}');
    print('══════════════════════════════════════════');
    print('');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Response shape: { "status": "success", "data": { ... } }
      if (decoded is Map<String, dynamic>) {
        final status = decoded['status']?.toString() ?? '';
        if (status == 'success' && decoded['data'] != null) {
          return ProductDetailModel.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
        // Some APIs return data directly at root level
        if (decoded.containsKey('product_name')) {
          return ProductDetailModel.fromJson(decoded);
        }
        throw Exception('[TYPE 1018] API returned status: $status');
      }

      throw Exception('[TYPE 1018] Unexpected response format');
    } else {
      throw Exception('[TYPE 1018] API Error: Status ${response.statusCode}');
    }
  }
}