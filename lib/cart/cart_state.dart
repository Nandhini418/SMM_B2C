import 'package:flutter/material.dart';

class CartItemModel {
  final String name;
  final String imagePath;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final String? deliveryDate;
  final bool outOfStock;
  final bool hotDeal;
  int qty;

  CartItemModel({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    this.deliveryDate,
    this.outOfStock = false,
    this.hotDeal = false,
    this.qty = 1,
  });

  @override
  bool operator ==(Object other) =>
      other is CartItemModel && other.name == name && other.imagePath == imagePath;

  @override
  int get hashCode => Object.hash(name, imagePath);
}

class CartNotifier extends ValueNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addItem(CartItemModel item) {
    final list = List<CartItemModel>.from(value);
    final existing = list.indexWhere((e) => e == item);
    if (existing != -1) {
      list[existing].qty += 1;
    } else {
      list.add(item);
    }
    value = List.from(list);
    notifyListeners();
  }

  void removeItem(CartItemModel item) {
    final list = List<CartItemModel>.from(value);
    list.remove(item);
    value = list;
    notifyListeners();
  }

  void updateQty(CartItemModel item, int qty) {
    final list = List<CartItemModel>.from(value);
    final idx = list.indexWhere((e) => e == item);
    if (idx != -1) list[idx].qty = qty;
    value = List.from(list);
    notifyListeners();
  }

  bool isInCart(CartItemModel item) => value.any((e) => e == item);

  double get total => value.fold(0.0, (s, e) => s + e.price * e.qty);
  double get savings => value.fold(0.0, (s, e) => s + (e.originalPrice - e.price) * e.qty);
}

// Global singleton
final cartNotifier = CartNotifier();