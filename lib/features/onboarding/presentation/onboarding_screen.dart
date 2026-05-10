import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../user/data/user_profile.dart';
import '../../user/providers/user_profile_provider.dart';
import 'widgets/onb_chrome.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pc = PageController();
  int _index = 0;

  // Step 1: name + age
  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();

  // Step 2: money
  String _currency = 'USD';
  final TextEditingController _income = TextEditingController();
  final TextEditingController _balance = TextEditingController();

  // Step 3: goals
  final Set<String> _goals = <String>{};

  // Step 4: daily targets
  int _taskGoal = 5;
  int _habitGoal = 3;

  static const int _totalSteps = 6;

  @override
  void dispose() {
    _pc.dispose();
    _name.dispose();
    _age.dispose();
    _income.dispose();
    _balance.dispose();
    super.dispose();
  }

  bool _canAdvance() {
    switch (_index) {
      case 0:
        return true;
      case 1:
        return _name.text.trim().isNotEmpty;
      case 2:
        return double.tryParse(_income.text.replaceAll(',', '.')) != null;
      case 3:
        return _goals.isNotEmpty;
      case 4:
        return true;
      case 5:
        return true;
    }
    return false;
  }

  void _next() {
    if (!_canAdvance()) return;
    if (_index >= _totalSteps - 1) {
      _finish();
      return;
    }
    setState(() => _index += 1);
    _pc.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_index == 0) return;
    setState(() => _index -= 1);
    _pc.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    final UserProfile profile = UserProfile(
      name: _name.text.trim().isEmpty ? 'Friend' : _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      currencyCode: _currency,
      monthlyIncome:
          double.tryParse(_income.text.replaceAll(',', '.')) ?? 0,
      currentBalance:
          double.tryParse(_balance.text.replaceAll(',', '.')) ?? 0,
      goals: _goals.toList(),
      dailyTaskGoal: _taskGoal,
      dailyHabitGoal: _habitGoal,
      createdAt: DateTime.now(),
    );
    await ref.read(userProfileProvider.notifier).save(profile);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const OnbBackground(),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Row(
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: _index == 0 ? 0 : 1,
                        duration: const Duration(milliseconds: 220),
                        child: _CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: _back,
                        ),
                      ),
                      const Spacer(),
                      _StepBadge(index: _index, total: _totalSteps),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: _ProgressBar(
                    progress: (_index + 1) / _totalSteps,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pc,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      _StepWelcome(),
                      _StepName(name: _name, age: _age, onChanged: () => setState(() {})),
                      _StepMoney(
                        currency: _currency,
                        onCurrency: (String c) => setState(() => _currency = c),
                        income: _income,
                        balance: _balance,
                        onChanged: () => setState(() {}),
                      ),
                      _StepGoals(
                        selected: _goals,
                        onToggle: (String g) => setState(() {
                          if (_goals.contains(g)) {
                            _goals.remove(g);
                          } else {
                            _goals.add(g);
                          }
                        }),
                      ),
                      _StepDaily(
                        tasks: _taskGoal,
                        habits: _habitGoal,
                        onTasks: (int v) => setState(() => _taskGoal = v),
                        onHabits: (int v) => setState(() => _habitGoal = v),
                      ),
                      _StepDone(
                        name: _name.text.trim().isEmpty
                            ? 'Friend'
                            : _name.text.trim(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                  child: _PrimaryButton(
                    label: _index == 0
                        ? context.tr('onb_get_started')
                        : (_index == _totalSteps - 1
                            ? context.tr('onb_finish')
                            : context.tr('onb_continue')),
                    enabled: _canAdvance(),
                    onTap: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        '${context.tr('onb_step')} ${index + 1} ${context.tr('onb_of')} $total',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          widthFactor: progress.clamp(0, 1).toDouble(),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            ),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.enabled,
  });
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: enabled ? 0.45 : 0.2),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Steps ----

class _StepWelcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: const Icon(Icons.hub_rounded,
                color: Colors.white, size: 42),
          )
              .animate()
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: 520.ms),
          const SizedBox(height: 28),
          Text(
            context.tr('onb_welcome_title'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  letterSpacing: -1,
                  height: 1.1,
                ),
          ).animate(delay: 120.ms).fadeIn(duration: 360.ms).slideY(begin: 0.1),
          const SizedBox(height: 12),
          Text(
            context.tr('onb_welcome_sub'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
          ).animate(delay: 200.ms).fadeIn(duration: 360.ms).slideY(begin: 0.1),
          const SizedBox(height: 28),
          ..._features(context),
        ],
      ),
    );
  }

  List<Widget> _features(BuildContext context) {
    final List<_FeatureRow> rows = <_FeatureRow>[
      _FeatureRow(
        icon: Icons.task_alt_rounded,
        gradient: AppColors.primaryGradient,
        title: context.tr('tasks_title'),
      ),
      _FeatureRow(
        icon: Icons.account_balance_wallet_rounded,
        gradient: AppColors.indigoGradient,
        title: context.tr('finance_title'),
      ),
      _FeatureRow(
        icon: Icons.local_fire_department_rounded,
        gradient: AppColors.sunsetGradient,
        title: context.tr('habits_title'),
      ),
      _FeatureRow(
        icon: Icons.alarm_rounded,
        gradient: AppColors.pinkGradient,
        title: context.tr('reminders_title'),
      ),
    ];
    return List<Widget>.generate(rows.length, (int i) {
      final _FeatureRow r = rows[i];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: r.gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(r.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              r.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
              ),
            ),
          ],
        )
            .animate(delay: (280 + i * 80).ms)
            .fadeIn(duration: 320.ms)
            .slideX(begin: 0.08, curve: Curves.easeOutCubic),
      );
    });
  }
}

class _FeatureRow {
  const _FeatureRow({
    required this.icon,
    required this.gradient,
    required this.title,
  });
  final IconData icon;
  final Gradient gradient;
  final String title;
}

class _StepName extends StatelessWidget {
  const _StepName(
      {required this.name, required this.age, required this.onChanged});
  final TextEditingController name;
  final TextEditingController age;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: context.tr('onb_name_title'),
      sub: context.tr('onb_name_sub'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: context.tr('onb_name_hint'),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: age,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              hintText: context.tr('onb_age_hint'),
              prefixIcon: const Icon(Icons.cake_outlined),
            ),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StepMoney extends StatelessWidget {
  const _StepMoney({
    required this.currency,
    required this.onCurrency,
    required this.income,
    required this.balance,
    required this.onChanged,
  });
  final String currency;
  final ValueChanged<String> onCurrency;
  final TextEditingController income;
  final TextEditingController balance;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: context.tr('onb_money_title'),
      sub: context.tr('onb_money_sub'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('onb_currency'),
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CurrencyOption.all
                .map((CurrencyOption c) => _CurrencyChip(
                      option: c,
                      active: c.code == currency,
                      onTap: () => onCurrency(c.code),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: income,
            onChanged: (_) => onChanged(),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              hintText: context.tr('onb_income_hint'),
              prefixIcon: const Icon(Icons.payments_outlined),
              suffixText: CurrencyOption.byCode(currency).symbol,
            ),
            style:
                const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: balance,
            onChanged: (_) => onChanged(),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              hintText: context.tr('onb_balance_hint'),
              prefixIcon:
                  const Icon(Icons.account_balance_wallet_outlined),
              suffixText: CurrencyOption.byCode(currency).symbol,
            ),
            style:
                const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.option,
    required this.active,
    required this.onTap,
  });
  final CurrencyOption option;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          color: active ? null : Theme.of(context).cardColor,
          border: Border.all(
            color: active
                ? Colors.transparent
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(option.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              option.code,
              style: TextStyle(
                color: active ? Colors.white : null,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              option.symbol,
              style: TextStyle(
                color: active
                    ? Colors.white.withValues(alpha: 0.9)
                    : Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepGoals extends StatelessWidget {
  const _StepGoals({required this.selected, required this.onToggle});
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const List<_GoalChipData> _data = <_GoalChipData>[
    _GoalChipData('goal_save_money', '💰', AppColors.emeraldGradient),
    _GoalChipData('goal_be_productive', '⚡', AppColors.primaryGradient),
    _GoalChipData('goal_get_fit', '💪', AppColors.sunsetGradient),
    _GoalChipData('goal_learn_skill', '🎓', AppColors.indigoGradient),
    _GoalChipData('goal_reduce_stress', '🧘', AppColors.pinkGradient),
    _GoalChipData('goal_better_sleep', '🌙', AppColors.skyGradient),
    _GoalChipData('goal_track_spending', '📊', AppColors.amberGradient),
    _GoalChipData('goal_build_habits', '🔥', AppColors.sunsetGradient),
  ];

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: context.tr('onb_goals_title'),
      sub: context.tr('onb_goals_sub'),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _data
            .map((_GoalChipData g) => _GoalChip(
                  data: g,
                  active: selected.contains(g.key),
                  onTap: () => onToggle(g.key),
                ))
            .toList(),
      ),
    );
  }
}

class _GoalChipData {
  const _GoalChipData(this.key, this.emoji, this.gradient);
  final String key;
  final String emoji;
  final Gradient gradient;
}

class _GoalChip extends StatelessWidget {
  const _GoalChip(
      {required this.data, required this.active, required this.onTap});
  final _GoalChipData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: active ? data.gradient : null,
          color: active ? null : Theme.of(context).cardColor,
          border: Border.all(
            color: active
                ? Colors.transparent
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? <BoxShadow>[
                  BoxShadow(
                    color: (data.gradient as LinearGradient)
                        .colors
                        .last
                        .withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(data.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              context.tr(data.key),
              style: TextStyle(
                color: active ? Colors.white : null,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDaily extends StatelessWidget {
  const _StepDaily({
    required this.tasks,
    required this.habits,
    required this.onTasks,
    required this.onHabits,
  });
  final int tasks;
  final int habits;
  final ValueChanged<int> onTasks;
  final ValueChanged<int> onHabits;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: context.tr('onb_daily_title'),
      sub: context.tr('onb_daily_sub'),
      child: Column(
        children: <Widget>[
          _StepperCard(
            label: context.tr('onb_daily_tasks'),
            icon: Icons.task_alt_rounded,
            gradient: AppColors.primaryGradient,
            value: tasks,
            min: 1,
            max: 20,
            onChanged: onTasks,
          ),
          const SizedBox(height: 14),
          _StepperCard(
            label: context.tr('onb_daily_habits'),
            icon: Icons.local_fire_department_rounded,
            gradient: AppColors.sunsetGradient,
            value: habits,
            min: 1,
            max: 10,
            onChanged: onHabits,
          ),
        ],
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final Gradient gradient;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 6),
                Text(
                  '$value',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          _RoundIcon(
            icon: Icons.remove_rounded,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          const SizedBox(width: 8),
          _RoundIcon(
            icon: Icons.add_rounded,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _StepDone extends StatelessWidget {
  const _StepDone({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: AppColors.emeraldGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 46),
          )
              .animate()
              .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack, duration: 520.ms),
          const SizedBox(height: 28),
          Text(
            '${context.tr('onb_done_title')}, $name',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                  letterSpacing: -1,
                  height: 1.1,
                ),
          ).animate(delay: 120.ms).fadeIn(duration: 360.ms).slideY(begin: 0.1),
          const SizedBox(height: 12),
          Text(
            context.tr('onb_done_sub'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
          ).animate(delay: 200.ms).fadeIn(duration: 360.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.title,
    required this.sub,
    required this.child,
  });
  final String title;
  final String sub;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.7,
                  height: 1.15,
                ),
          ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.06),
          const SizedBox(height: 8),
          Text(
            sub,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
          ).animate(delay: 80.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06),
          const SizedBox(height: 22),
          child
              .animate(delay: 160.ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.06),
        ],
      ),
    );
  }
}
