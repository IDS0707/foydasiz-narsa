import 'dart:convert';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.currencyCode,
    required this.monthlyIncome,
    required this.currentBalance,
    required this.goals,
    required this.dailyTaskGoal,
    required this.dailyHabitGoal,
    required this.createdAt,
  });

  final String name;
  final int age;
  final String currencyCode; // 'USD', 'UZS', 'RUB', 'EUR'
  final double monthlyIncome;
  final double currentBalance;
  final List<String> goals; // localization keys, e.g. 'goal_save_money'
  final int dailyTaskGoal;
  final int dailyHabitGoal;
  final DateTime createdAt;

  UserProfile copyWith({
    String? name,
    int? age,
    String? currencyCode,
    double? monthlyIncome,
    double? currentBalance,
    List<String>? goals,
    int? dailyTaskGoal,
    int? dailyHabitGoal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      currencyCode: currencyCode ?? this.currencyCode,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currentBalance: currentBalance ?? this.currentBalance,
      goals: goals ?? this.goals,
      dailyTaskGoal: dailyTaskGoal ?? this.dailyTaskGoal,
      dailyHabitGoal: dailyHabitGoal ?? this.dailyHabitGoal,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'age': age,
        'currencyCode': currencyCode,
        'monthlyIncome': monthlyIncome,
        'currentBalance': currentBalance,
        'goals': goals,
        'dailyTaskGoal': dailyTaskGoal,
        'dailyHabitGoal': dailyHabitGoal,
        'createdAt': createdAt.toIso8601String(),
      };

  static UserProfile fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        age: (json['age'] as num?)?.toInt() ?? 0,
        currencyCode: json['currencyCode'] as String? ?? 'USD',
        monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
        currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
        goals: (json['goals'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        dailyTaskGoal: (json['dailyTaskGoal'] as num?)?.toInt() ?? 5,
        dailyHabitGoal: (json['dailyHabitGoal'] as num?)?.toInt() ?? 3,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  String encode() => jsonEncode(toJson());
  static UserProfile decode(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

class CurrencyOption {
  const CurrencyOption(this.code, this.symbol, this.name, this.flag);
  final String code;
  final String symbol;
  final String name;
  final String flag;

  static const List<CurrencyOption> all = <CurrencyOption>[
    CurrencyOption('USD', '\$', 'US Dollar', '🇺🇸'),
    CurrencyOption('UZS', "so'm", 'Uzbek Som', '🇺🇿'),
    CurrencyOption('RUB', '₽', 'Russian Ruble', '🇷🇺'),
    CurrencyOption('EUR', '€', 'Euro', '🇪🇺'),
    CurrencyOption('GBP', '£', 'Pound Sterling', '🇬🇧'),
    CurrencyOption('KZT', '₸', 'Kazakhstani Tenge', '🇰🇿'),
  ];

  static CurrencyOption byCode(String code) =>
      all.firstWhere((CurrencyOption c) => c.code == code,
          orElse: () => all.first);
}

class GoalOption {
  const GoalOption(this.key, this.icon, this.gradient);
  final String key;
  final String icon; // emoji
  final List<int> gradient; // ARGB ints, kept simple — UI maps to colors.
}

const List<String> kGoalKeys = <String>[
  'goal_save_money',
  'goal_be_productive',
  'goal_get_fit',
  'goal_learn_skill',
  'goal_reduce_stress',
  'goal_better_sleep',
  'goal_track_spending',
  'goal_build_habits',
];
