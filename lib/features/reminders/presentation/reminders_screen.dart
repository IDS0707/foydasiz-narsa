import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/reminder_model.dart';
import '../providers/reminders_provider.dart';
import 'widgets/add_reminder_sheet.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _askedPermission = false;

  Future<bool> _ensurePermission() async {
    if (_askedPermission) return true;
    _askedPermission = true;
    final NotificationPermissionResult r = await NotificationService.instance
        .requestPermission();
    if (!mounted) return r.granted;
    if (!r.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.rose,
          content: Row(
            children: <Widget>[
              const Icon(Icons.notifications_off_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('notif_permission_denied'),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return r.granted;
  }

  @override
  Widget build(BuildContext context) {
    final List<ReminderItem> all = ref.watch(remindersProvider);

    return Scaffold(
      floatingActionButton: _AddFab(onTap: () => _openAdd(context)),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(context.tr('reminders_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          if (all.isEmpty)
            EmptyState(
              icon: Icons.alarm_rounded,
              title: context.tr('empty_reminders_title'),
              subtitle: context.tr('empty_reminders_sub'),
              ctaLabel: context.tr('empty_reminders_cta'),
              gradient: AppColors.indigoGradient,
              onCta: () => _openAdd(context),
            )
          else
            ...List<Widget>.generate(all.length, (int i) {
              final ReminderItem r = all[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderCard(reminder: r)
                    .animate(delay: (i * 50).ms)
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _openAdd(BuildContext _) async {
    await _ensurePermission();
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => const AddReminderSheet(),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.reminder});
  final ReminderItem reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = reminder.enabled;
    return Dismissible(
      key: ValueKey<String>(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFCA5A5), Color(0xFFEF4444)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(remindersProvider.notifier).remove(reminder.id),
      child: GestureDetector(
        onLongPress: () => _openEdit(context),
        onTap: () => _openEdit(context),
        child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: enabled
                    ? reminder.category.gradient
                    : LinearGradient(
                        colors: <Color>[
                          Theme.of(context).dividerColor,
                          Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.7),
                        ],
                      ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: enabled
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.indigo.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Icon(reminder.category.icon,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: enabled
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      _Chip(
                        label: context.tr(reminder.repeat.labelKey),
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      _Chip(
                        label: context.tr(reminder.category.labelKey),
                        color: AppColors.indigo,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (_) =>
                  ref.read(remindersProvider.notifier).toggle(reminder.id),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => AddReminderSheet(existing: reminder),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              context.tr('reminders_add'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
