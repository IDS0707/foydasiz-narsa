import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/notifications/notification_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../finance/providers/finance_provider.dart';
import '../../habits/providers/habits_provider.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../user/data/user_profile.dart';
import '../../user/presentation/widgets/edit_balance_sheet.dart';
import '../../user/presentation/widgets/edit_profile_sheet.dart';
import '../../user/providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final Locale locale = ref.watch(localeProvider);
    final TasksStats tasks = ref.watch(tasksStatsProvider);
    final HabitsStats habits = ref.watch(habitsStatsProvider);
    final UserProfile? profile = ref.watch(userProfileProvider);
    final NotificationSettings ns = ref.watch(notificationSettingsProvider);

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
            const SizedBox(height: 16),
            _BalanceCard(profile: profile),
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
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader(title: context.tr('profile_appearance')),
            _SettingsGroup(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.person_rounded,
                  iconBg: AppColors.primaryGradient,
                  label: context.tr('edit_profile'),
                  sub: context.tr('profile_edit_sub'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openEditProfile(context),
                ),
                _SettingsRow(
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
                _SettingsRow(
                  icon: Icons.language_rounded,
                  iconBg: AppColors.skyGradient,
                  label: context.tr('profile_language'),
                  trailing: _LanguagePicker(current: locale, ref: ref),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SectionHeader(title: context.tr('notif_settings')),
            _SettingsGroup(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.notifications_active_rounded,
                  iconBg: AppColors.primaryGradient,
                  label: context.tr('notif_master'),
                  sub: context.tr('notif_master_sub'),
                  trailing: Switch(
                    value: ns.masterEnabled,
                    onChanged: (bool v) async {
                      await ref
                          .read(notificationSettingsProvider.notifier)
                          .setMaster(v);
                      await ref
                          .read(remindersProvider.notifier)
                          .applySettings(
                              ref.read(notificationSettingsProvider));
                    },
                  ),
                ),
                _SettingsRow(
                  icon: Icons.alarm_rounded,
                  iconBg: AppColors.indigoGradient,
                  label: context.tr('notif_reminders'),
                  sub: context.tr('notif_reminders_sub'),
                  enabled: ns.masterEnabled,
                  trailing: Switch(
                    value: ns.remindersEnabled && ns.masterEnabled,
                    onChanged: ns.masterEnabled
                        ? (bool v) async {
                            await ref
                                .read(notificationSettingsProvider.notifier)
                                .setReminders(v);
                            await ref
                                .read(remindersProvider.notifier)
                                .applySettings(
                                    ref.read(notificationSettingsProvider));
                          }
                        : null,
                  ),
                ),
                _SettingsRow(
                  icon: Icons.volume_up_rounded,
                  iconBg: AppColors.pinkGradient,
                  label: context.tr('notif_sound'),
                  enabled: ns.masterEnabled,
                  trailing: Switch(
                    value: ns.soundEnabled && ns.masterEnabled,
                    onChanged: ns.masterEnabled
                        ? (bool v) async {
                            await ref
                                .read(notificationSettingsProvider.notifier)
                                .setSound(v);
                            await ref
                                .read(remindersProvider.notifier)
                                .applySettings(
                                    ref.read(notificationSettingsProvider));
                          }
                        : null,
                  ),
                ),
                _SettingsRow(
                  icon: Icons.vibration_rounded,
                  iconBg: AppColors.emeraldGradient,
                  label: context.tr('notif_vibration'),
                  enabled: ns.masterEnabled,
                  trailing: Switch(
                    value: ns.vibrationEnabled && ns.masterEnabled,
                    onChanged: ns.masterEnabled
                        ? (bool v) async {
                            await ref
                                .read(notificationSettingsProvider.notifier)
                                .setVibration(v);
                            await ref
                                .read(remindersProvider.notifier)
                                .applySettings(
                                    ref.read(notificationSettingsProvider));
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SectionHeader(title: context.tr('profile_settings')),
            _SettingsGroup(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.refresh_rounded,
                  iconBg: AppColors.pinkGradient,
                  label: context.tr('reset_profile'),
                  sub: context.tr('reset_profile_sub'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _resetProfile(context, ref),
                ),
              ],
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

  void _openEditProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => const EditProfileSheet(),
    );
  }

  Future<void> _resetProfile(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => _ConfirmDialog(
        title: context.tr('reset_confirm_title'),
        message: context.tr('reset_confirm_msg'),
        confirmLabel: context.tr('reset_continue'),
        destructive: true,
      ),
    );
    if (ok != true) return;

    await ref.read(remindersProvider.notifier).replaceAll(<dynamic>[].cast());
    await ref.read(tasksProvider.notifier).replaceAll(<dynamic>[].cast());
    await ref.read(financeProvider.notifier).replaceAll(<dynamic>[].cast());
    await ref.read(habitsProvider.notifier).replaceAll(<dynamic>[].cast());
    await ref.read(userProfileProvider.notifier).reset();
    await ref.read(localeProvider.notifier).clearChoice();

    if (!context.mounted) return;
    context.go('/language');
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.profile});
  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CurrencyOption currency =
        CurrencyOption.byCode(profile?.currencyCode ?? 'USD');
    final double balance = profile?.currentBalance ?? 0;
    final String fmt =
        balance == balance.roundToDouble() ? balance.toStringAsFixed(0) : balance.toStringAsFixed(2);

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        decoration: BoxDecoration(
          gradient: AppColors.emeraldGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.32),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.tr('balance_current'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$fmt ${currency.symbol}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).scaleXY(
            begin: 1.0,
            end: 1.012,
            duration: 1800.ms,
            curve: Curves.easeInOut,
          ),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => const EditBalanceSheet(),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            children[i],
            if (i != children.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Divider(
                  height: 1,
                  color: Theme.of(context)
                      .dividerColor
                      .withValues(alpha: 0.6),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.trailing,
    this.sub,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Gradient iconBg;
  final String label;
  final String? sub;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5),
                      ),
                      if (sub != null) ...<Widget>[
                        const SizedBox(height: 1),
                        Text(
                          sub!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.current, required this.ref});
  final Locale current;
  final WidgetRef ref;

  static const List<_LangOption> _options = <_LangOption>[
    _LangOption('en', '🇺🇸', 'language_english'),
    _LangOption('uz', '🇺🇿', 'language_uzbek'),
    _LangOption('ru', '🇷🇺', 'language_russian'),
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
                        style:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ))
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _options
                  .firstWhere(
                      (_LangOption o) => o.code == current.languageCode,
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
  const _LangOption(this.code, this.flag, this.labelKey);
  final String code;
  final String flag;
  final String labelKey;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.destructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: destructive
                    ? const LinearGradient(
                        colors: <Color>[
                          Color(0xFFFB7185),
                          AppColors.rose
                        ],
                      )
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                destructive
                    ? Icons.warning_amber_rounded
                    : Icons.help_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(context.tr('cancel'),
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: destructive
                            ? const LinearGradient(
                                colors: <Color>[
                                  Color(0xFFFB7185),
                                  AppColors.rose
                                ],
                              )
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          confirmLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
