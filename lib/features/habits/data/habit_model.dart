import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A predefined visual style for a habit. Stored by enum name so the
/// [IconData] and [Gradient] can be reconstructed after deserialization.
enum HabitStyle {
  water,
  workout,
  reading,
  meditate,
  learn,
  sleep,
  walk,
  diet,
}

extension HabitStyleExt on HabitStyle {
  IconData get icon {
    switch (this) {
      case HabitStyle.water:
        return Icons.water_drop_rounded;
      case HabitStyle.workout:
        return Icons.fitness_center_rounded;
      case HabitStyle.reading:
        return Icons.menu_book_rounded;
      case HabitStyle.meditate:
        return Icons.self_improvement_rounded;
      case HabitStyle.learn:
        return Icons.translate_rounded;
      case HabitStyle.sleep:
        return Icons.bedtime_rounded;
      case HabitStyle.walk:
        return Icons.directions_walk_rounded;
      case HabitStyle.diet:
        return Icons.restaurant_rounded;
    }
  }

  Gradient get gradient {
    switch (this) {
      case HabitStyle.water:
        return AppColors.skyGradient;
      case HabitStyle.workout:
        return AppColors.sunsetGradient;
      case HabitStyle.reading:
        return AppColors.indigoGradient;
      case HabitStyle.meditate:
        return AppColors.pinkGradient;
      case HabitStyle.learn:
        return AppColors.emeraldGradient;
      case HabitStyle.sleep:
        return AppColors.indigoGradient;
      case HabitStyle.walk:
        return AppColors.emeraldGradient;
      case HabitStyle.diet:
        return AppColors.amberGradient;
    }
  }
}

class HabitItem {
  HabitItem({
    required this.id,
    required this.name,
    required this.style,
    this.target = 1,
    this.streak = 0,
    Set<DateTime>? completedDays,
  }) : completedDays = completedDays ?? <DateTime>{};

  final String id;
  final String name;
  final HabitStyle style;
  final int target;
  final int streak;
  final Set<DateTime> completedDays;

  IconData get icon => style.icon;
  Gradient get gradient => style.gradient;

  HabitItem copyWith({
    String? name,
    HabitStyle? style,
    int? target,
    int? streak,
    Set<DateTime>? completedDays,
  }) {
    return HabitItem(
      id: id,
      name: name ?? this.name,
      style: style ?? this.style,
      target: target ?? this.target,
      streak: streak ?? this.streak,
      completedDays: completedDays ?? this.completedDays,
    );
  }

  bool isDoneOn(DateTime day) {
    final DateTime key = DateTime(day.year, day.month, day.day);
    return completedDays.contains(key);
  }

  bool get isDoneToday => isDoneOn(DateTime.now());

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'style': style.name,
        'target': target,
        'streak': streak,
        'completedDays':
            completedDays.map((DateTime d) => d.toIso8601String()).toList(),
      };

  static HabitItem fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawDays =
        (json['completedDays'] as List<dynamic>?) ?? <dynamic>[];
    return HabitItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      style: HabitStyle.values.firstWhere(
        (HabitStyle s) => s.name == json['style'],
        orElse: () => HabitStyle.workout,
      ),
      target: (json['target'] as num?)?.toInt() ?? 1,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      completedDays: rawDays
          .map((dynamic d) => DateTime.tryParse(d as String? ?? ''))
          .whereType<DateTime>()
          .map((DateTime d) => DateTime(d.year, d.month, d.day))
          .toSet(),
    );
  }

  String encode() => jsonEncode(toJson());
  static HabitItem decode(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
