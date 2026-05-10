import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../finance/providers/finance_provider.dart';
import '../../habits/providers/habits_provider.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../user/data/user_profile.dart';
import '../../user/providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final Locale locale = ref.watch(localeProvider);
    final TasksStats tasks = ref.watch(tasksStatsProvider);
    final HabitsStats habits = ref.watch(habitsStatsProvider);
    final FinanceStats finance = ref.watch(financeStatsProvider);
    final UserProfile? profile = ref.watch(userProfileProvider);

    final bool isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            _ProfileHero(profile: profile),
            const SizedBox(height: 22),
            SectionHeader(title: context.tr('profile_stats')),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatTile(
                    gradient: AppColors.primaryGradient,
                    icon: Icons.task_alt_rounded,
                    value: '${tasks.doneAll}',
                    label: context.tr('profile_tasks_done'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    gradient: AppColors.sunsetGradient,
                    icon: Icons.local_fire_department_rounded,
                    value: '${habits.bestStreak}',
                    label: context.tr('habits_streak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    gradient: AppColors.emeraldGradient,
                    icon: Icons.payments_rounded,
                    value:
                        '${finance.monthTotal.toStringAsFixed(0)} ${finance.currencySymbol}',
                    label: context.tr('profile_money_tracked'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader(title: context.tr('profile_appearance')),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    iconBg: AppColors.indigoGradient,
                    label: context.tr('profile_dark_mode'),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (bool v) => ref
                          .read(themeModeProvider.notifier)
                          .set(v ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    iconBg: AppColors.skyGradient,
                    label: context.tr('profile_language'),
                    trailing: _LanguagePicker(current: locale, ref: ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(title: context.tr('profile_settings')),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    iconBg: AppColors.pinkGradient,
                    label: context.tr('profile_notifications'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.cloud_upload_rounded,
                    iconBg: AppColors.emeraldGradient,
                    label: context.tr('profile_backup'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.file_download_rounded,
                    iconBg: AppColors.amberGradient,
                    label: context.tr('profile_export'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.file_upload_rounded,
                    iconBg: AppColors.sunsetGradient,
                    label: context.tr('profile_import'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(title: context.tr('profile_about')),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.hub_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(context.tr('app_name'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(
                          '${context.tr('profile_version')} 1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
              .animate(interval: 30.ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.04, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final String name = profile?.name.trim().isNotEmpty == true
        ? profile!.name.trim()
        : 'Friend';
    final String initial = name.substring(0, 1).toUpperCase();
    final int joinYear = profile?.createdAt.year ?? DateTime.now().year;
    return GradientCard(
      gradient: AppColors.primaryGradient,
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFEDE9FE),
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.tr('profile_member_since')} $joinYear',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.gradient,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Gradient gradient;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final Gradient iconBg;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        height: 1,
        color: Theme.of(context).dividerColor.withOpacity(0.6),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.current, required this.ref});
  final Locale current;
  final WidgetRef ref;

  static const List<_LangOption> _options = <_LangOption>[
    _LangOption('en', 'EN', '🇺🇸', 'language_english'),
    _LangOption('uz', 'UZ', '🇺🇿', 'language_uzbek'),
    _LangOption('ru', 'RU', '🇷🇺', 'language_russian'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (String code) =>
          ref.read(localeProvider.notifier).set(Locale(code)),
      itemBuilder: (BuildContext _) {
        return _options
            .map((_LangOption o) => PopupMenuItem<String>(
                  value: o.code,
                  child: Row(
                    children: <Widget>[
                      Text(o.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text(
                        context.tr(o.labelKey),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ))
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _options
                  .firstWhere((_LangOption o) => o.code == current.languageCode,
                      orElse: () => _options.first)
                  .flag,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              current.languageCode.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _LangOption {
  const _LangOption(this.code, this.short, this.flag, this.labelKey);
  final String code;
  final String short;
  final String flag;
  final String labelKey;
}
