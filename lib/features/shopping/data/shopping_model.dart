import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ShoppingCategory { groceries, household, personal, other }

extension ShoppingCategoryExt on ShoppingCategory {
  IconData get icon {
    switch (this) {
      case ShoppingCategory.groceries:
        return Icons.shopping_basket_rounded;
      case ShoppingCategory.household:
        return Icons.cleaning_services_rounded;
      case ShoppingCategory.personal:
        return Icons.face_retouching_natural_rounded;
      case ShoppingCategory.other:
        return Icons.category_rounded;
    }
  }

  Gradient get gradient {
    switch (this) {
      case ShoppingCategory.groceries:
        return AppColors.emeraldGradient;
      case ShoppingCategory.household:
        return AppColors.skyGradient;
      case ShoppingCategory.personal:
        return AppColors.pinkGradient;
      case ShoppingCategory.other:
        return AppColors.indigoGradient;
    }
  }
}

class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.name,
    this.qty = '1',
    this.bought = false,
    this.category = ShoppingCategory.groceries,
  });

  final String id;
  final String name;
  final String qty;
  final bool bought;
  final ShoppingCategory category;

  ShoppingItem copyWith({
    String? name,
    String? qty,
    bool? bought,
    ShoppingCategory? category,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      bought: bought ?? this.bought,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'qty': qty,
        'bought': bought,
        'category': category.name,
      };

  static ShoppingItem fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        qty: json['qty'] as String? ?? '1',
        bought: json['bought'] as bool? ?? false,
        category: ShoppingCategory.values.firstWhere(
          (ShoppingCategory c) => c.name == json['category'],
          orElse: () => ShoppingCategory.groceries,
        ),
      );

  String encode() => jsonEncode(toJson());
  static ShoppingItem decode(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
