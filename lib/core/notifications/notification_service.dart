import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/reminders/data/reminder_model.dart';

/// Wraps [FlutterLocalNotificationsPlugin] with the lifecycle quirks needed
/// for LIFEHUB:
///
/// * Web is not supported by the plugin — every operation no-ops there.
/// * Android requires runtime POST_NOTIFICATIONS permission on API 33+, and
///   exact-alarm permission on API 31+ for precise scheduling.
/// * iOS / macOS require alert + badge + sound permission via the plugin's
///   own request.
///
/// Repeat strategy:
///   - [ReminderRepeat.once]   → schedules at the exact next occurrence of
///                               the reminder's time on its date.
///   - [ReminderRepeat.daily]  → uses [DateTimeComponents.time] to repeat
///                               every day at the same hh:mm.
///   - [ReminderRepeat.weekly] → uses [DateTimeComponents.dayOfWeekAndTime]
///                               anchored to the next matching weekday.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get available => !kIsWeb;

  Future<void> init() async {
    if (_initialized || !available) {
      _initialized = true;
      return;
    }

    tz_data.initializeTimeZones();
    // Best effort: stay on UTC if the host device's tz can't be read; the
    // plugin still respects the wall-clock time we hand it.
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      // Ignore — keep default.
    }

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: ios,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!available) return false;
    if (!_initialized) await init();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final PermissionStatus s = await Permission.notification.request();
      return s.isGranted;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? r = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return r ?? false;
    }
    return true;
  }

  NotificationDetails _details() {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'lifehub_reminders',
      'Reminders',
      channelDescription: 'Scheduled reminders from LIFEHUB',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'reminder',
    );
    const DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(
      android: android,
      iOS: ios,
      macOS: ios,
    );
  }

  Future<void> scheduleReminder(ReminderItem r) async {
    if (!available) return;
    if (!_initialized) await init();
    await cancelReminder(r.notificationId);
    if (!r.enabled) return;

    final tz.TZDateTime when = _firstOccurrence(r);

    final DateTimeComponents? matchComponents;
    switch (r.repeat) {
      case ReminderRepeat.once:
        matchComponents = null;
        break;
      case ReminderRepeat.daily:
        matchComponents = DateTimeComponents.time;
        break;
      case ReminderRepeat.weekly:
        matchComponents = DateTimeComponents.dayOfWeekAndTime;
        break;
    }

    try {
      await _plugin.zonedSchedule(
        r.notificationId,
        r.label,
        r.subtitle.isEmpty ? null : r.subtitle,
        when,
        _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponents,
      );
    } on PlatformException catch (_) {
      // Falls back to inexact when the user has not granted "schedule
      // exact alarm" — the reminder still fires, just not to the second.
      await _plugin.zonedSchedule(
        r.notificationId,
        r.label,
        r.subtitle.isEmpty ? null : r.subtitle,
        when,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponents,
      );
    } catch (_) {
      // Swallow other platform errors — UI persistence is the source of truth.
    }
  }

  Future<void> cancelReminder(int id) async {
    if (!available) return;
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!available) return;
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  /// Re-schedules every enabled reminder. Useful on app start so the OS
  /// always has the latest schedule (notifications survive reboot via the
  /// plugin's own boot receiver, but we stay on the safe side).
  Future<void> rescheduleAll(List<ReminderItem> all) async {
    if (!available) return;
    for (final ReminderItem r in all) {
      if (r.enabled) await scheduleReminder(r);
    }
  }

  tz.TZDateTime _firstOccurrence(ReminderItem r) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    switch (r.repeat) {
      case ReminderRepeat.once:
        final tz.TZDateTime exact = tz.TZDateTime(
          tz.local,
          r.date.year,
          r.date.month,
          r.date.day,
          r.time.hour,
          r.time.minute,
        );
        return exact.isBefore(now)
            ? now.add(const Duration(seconds: 5))
            : exact;
      case ReminderRepeat.daily:
        tz.TZDateTime t = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          r.time.hour,
          r.time.minute,
        );
        if (t.isBefore(now)) t = t.add(const Duration(days: 1));
        return t;
      case ReminderRepeat.weekly:
        tz.TZDateTime t = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          r.time.hour,
          r.time.minute,
        );
        while (t.weekday != r.date.weekday || t.isBefore(now)) {
          t = t.add(const Duration(days: 1));
        }
        return t;
    }
  }
}
