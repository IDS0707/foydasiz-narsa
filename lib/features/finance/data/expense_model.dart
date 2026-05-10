import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ExpenseCategory { food, transport, leisure, utilities, shopping, health, other }

extension ExpenseCategoryExt on ExpenseCategory {
  String get labelKey {
    switch (this) {
      case ExpenseCategory.food:
        return 'cat_food';
      case ExpenseCategory.transport:
        return 'cat_transport';
      case ExpenseCategory.leisure:
        return 'cat_leisure';
      case ExpenseCategory.utilities:
        return 'cat_utilities';
      case ExpenseCategory.shopping:
        return 'cat_shopping';
      case ExpenseCategory.health:
        return 'cat_health';
      case ExpenseCategory.other:
        return 'cat_other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_filled_rounded;
      case ExpenseCategory.leisure:
        return Icons.movie_creation_outlined;
      case ExpenseCategory.utilities:
        return Icons.home_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.health:
        return Icons.favorite_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.amber;
      case ExpenseCategory.transport:
        return AppColors.sky;
      case ExpenseCategory.leisure:
        return AppColors.violet;
      case ExpenseCategory.utilities:
        return AppColors.emerald;
      case ExpenseCategory.shopping:
        return AppColors.pink;
      case ExpenseCategory.health:
        return AppColors.rose;
      case ExpenseCategory.other:
        return const Color(0xFF94A3B8);
    }
  }

  Gradient get gradient {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.amberGradient;
      case ExpenseCategory.transport:
        return AppColors.skyGradient;
      case ExpenseCategory.leisure:
        return AppColors.pinkGradient;
      case ExpenseCategory.utilities:
        return AppColors.emeraldGradient;
      case ExpenseCategory.shopping:
        return AppColors.pinkGradient;
      case ExpenseCategory.health:
        return AppColors.sunsetGradient;
      case ExpenseCategory.other:
        return AppColors.indigoGradient;
    }
  }
}

class ExpenseItem {
  ExpenseItem({
    required this.id,
    required this.amount,
    required this.category,
    this.note = '',
    DateTime? date,
    this.isIncome = false,
  }) : date = date ?? DateTime.now();

  final String id;
  final double amount;
  final ExpenseCategory category;
  final String note;
  final DateTime date;
  final bool isIncome;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'amount': amount,
        'category': category.name,
        'note': note,
        'date': date.toIso8601String(),
        'isIncome': isIncome,
      };

  static ExpenseItem fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        category: ExpenseCategory.values.firstWhere(
          (ExpenseCategory c) => c.name == json['category'],
          orElse: () => ExpenseCategory.other,
        ),
        note: json['note'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        isIncome: json['isIncome'] as bool? ?? false,
      );

  String encode() => jsonEncode(toJson());
  static ExpenseItem decode(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
