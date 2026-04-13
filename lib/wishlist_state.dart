import 'package:flutter/material.dart';

class WishlistItem {
  final String name;
  final int mrp;
  final int price;
  final String unit;
  final String image;

  const WishlistItem({
    required this.name,
    required this.mrp,
    required this.price,
    required this.unit,
    required this.image,
  });

  @override
  bool operator ==(Object other) =>
      other is WishlistItem && other.name == name && other.image == image;

  @override
  int get hashCode => Object.hash(name, image);
}

class WishlistNotifier extends ValueNotifier<List<WishlistItem>> {
  WishlistNotifier() : super([]);

  void toggle(WishlistItem item) {
    final list = List<WishlistItem>.from(value);
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
    value = list;
    notifyListeners();
  }

  bool isWishlisted(WishlistItem item) => value.contains(item);
}

// Global singleton — import this wherever needed
final wishlistNotifier = WishlistNotifier();