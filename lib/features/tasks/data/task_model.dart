import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityExt on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppColors.sky;
      case TaskPriority.medium:
        return AppColors.amber;
      case TaskPriority.high:
        return AppColors.rose;
    }
  }

  String get labelKey {
    switch (this) {
      case TaskPriority.low:
        return 'tasks_priority_low';
      case TaskPriority.medium:
        return 'tasks_priority_medium';
      case TaskPriority.high:
        return 'tasks_priority_high';
    }
  }
}

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    this.notes = '',
    this.priority = TaskPriority.medium,
    DateTime? dueAt,
    this.done = false,
  }) : dueAt = dueAt ?? DateTime.now();

  final String id;
  final String title;
  final String notes;
  final TaskPriority priority;
  final DateTime dueAt;
  final bool done;

  TaskItem copyWith({
    String? title,
    String? notes,
    TaskPriority? priority,
    DateTime? dueAt,
    bool? done,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      dueAt: dueAt ?? this.dueAt,
      done: done ?? this.done,
    );
  }

  bool get isToday {
    final DateTime now = DateTime.now();
    return dueAt.year == now.year &&
        dueAt.month == now.month &&
        dueAt.day == now.day;
  }

  bool get isUpcoming => dueAt.isAfter(DateTime.now()) && !isToday;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'notes': notes,
        'priority': priority.name,
        'dueAt': dueAt.toIso8601String(),
        'done': done,
      };

  static TaskItem fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        priority: TaskPriority.values.firstWhere(
          (TaskPriority p) => p.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '') ??
            DateTime.now(),
        done: json['done'] as bool? ?? false,
      );

  String encode() => jsonEncode(toJson());
  static TaskItem decode(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
