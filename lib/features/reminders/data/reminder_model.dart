import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ReminderRepeat { once, daily, weekly }

extension ReminderRepeatExt on ReminderRepeat {
  String get labelKey {
    switch (this) {
      case ReminderRepeat.once:
        return 'reminders_once';
      case ReminderRepeat.daily:
        return 'reminders_daily';
      case ReminderRepeat.weekly:
        return 'reminders_weekly';
    }
  }
}

enum ReminderCategory { general, health, work, personal }

extension ReminderCategoryExt on ReminderCategory {
  String get labelKey {
    switch (this) {
      case ReminderCategory.general:
        return 'reminder_cat_general';
      case ReminderCategory.health:
        return 'reminder_cat_health';
      case ReminderCategory.work:
        return 'reminder_cat_work';
      case ReminderCategory.personal:
        return 'reminder_cat_personal';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderCategory.general:
        return Icons.alarm_rounded;
      case ReminderCategory.health:
        return Icons.favorite_rounded;
      case ReminderCategory.work:
        return Icons.work_rounded;
      case ReminderCategory.personal:
        return Icons.person_rounded;
    }
  }

  Gradient get gradient {
    switch (this) {
      case ReminderCategory.general:
        return AppColors.indigoGradient;
      case ReminderCategory.health:
        return AppColors.sunsetGradient;
      case ReminderCategory.work:
        return AppColors.primaryGradient;
      case ReminderCategory.personal:
        return AppColors.pinkGradient;
    }
  }
}

class ReminderItem {
  ReminderItem({
    required this.id,
    required this.label,
    required this.time,
    this.subtitle = '',
    this.repeat = ReminderRepeat.daily,
    this.enabled = true,
    this.category = ReminderCategory.general,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  final String id;
  final String label;
  final TimeOfDay time;
  final String subtitle;
  final ReminderRepeat repeat;
  final bool enabled;
  final ReminderCategory category;
  // Used for one-off reminders to remember the exact day; ignored for
  // daily/weekly schedules.
  final DateTime date;

  /// Stable integer id derived from the string id, used by the system
  /// notification scheduler (which only accepts ints).
  int get notificationId => id.hashCode & 0x7fffffff;

  ReminderItem copyWith({
    String? label,
    TimeOfDay? time,
    String? subtitle,
    ReminderRepeat? repeat,
    bool? enabled,
    ReminderCategory? category,
    DateTime? date,
  }) {
    return ReminderItem(
      id: id,
      label: label ?? this.label,
      time: time ?? this.time,
      subtitle: subtitle ?? this.subtitle,
      repeat: repeat ?? this.repeat,
      enabled: enabled ?? this.enabled,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'label': label,
        'subtitle': subtitle,
        'hour': time.hour,
        'minute': time.minute,
        'repeat': repeat.name,
        'enabled': enabled,
        'category': category.name,
        'date': date.toIso8601String(),
      };

  static ReminderItem fromJson(Map<String, dynamic> json) => ReminderItem(
        id: json['id'] as String,
        label: json['label'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        time: TimeOfDay(
          hour: (json['hour'] as num?)?.toInt() ?? 8,
          minute: (json['minute'] as num?)?.toInt() ?? 0,
        ),
        repeat: ReminderRepeat.values.firstWhere(
          (ReminderRepeat r) => r.name == json['repeat'],
          orElse: () => ReminderRepeat.daily,
        ),
        enabled: json['enabled'] as bool? ?? true,
        category: ReminderCategory.values.firstWhere(
          (ReminderCategory c) => c.name == json['category'],
          orElse: () => ReminderCategory.general,
        ),
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
      );

  String encode() => jsonEncode(toJson());
  static ReminderItem decode(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
