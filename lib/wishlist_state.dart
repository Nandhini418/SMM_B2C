import 'package:flutter/material.dart';

class WishlistItem {
  final String name;
  final int mrp;
  final int price;
  final String unit;
  final String image;

  /// The real product ID for navigating to ProductDetailsScreen.
  /// 0 means unknown / not set.
  final int productId;

  const WishlistItem({
    required this.name,
    required this.mrp,
    required this.price,
    required this.unit,
    required this.image,
    this.productId = 0,
  });

  @override
  bool operator ==(Object other) =>
      other is WishlistItem &&
          other.name == name &&
          other.image == image;

  @override
  int get hashCode => Object.hash(name, image);
}

class WishlistNotifier extends ValueNotifier<List<WishlistItem>> {
  WishlistNotifier() : super([]);

  bool isWishlisted(WishlistItem item) => value.any((e) => e == item);

  void toggle(WishlistItem item) {
    final list = List<WishlistItem>.from(value);
    if (isWishlisted(item)) {
      list.removeWhere((e) => e == item);
    } else {
      list.add(item);
    }
    value = list;
    notifyListeners();
  }
}

// Global singleton
final wishlistNotifier = WishlistNotifier();