import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/reminders/data/reminder_model.dart';
import 'notification_settings.dart';

/// Result of a permission request — UI can react to denials with a banner.
class NotificationPermissionResult {
  const NotificationPermissionResult({
    required this.granted,
    required this.exactAlarmGranted,
  });

  final bool granted;
  final bool exactAlarmGranted;
}

/// Wraps [FlutterLocalNotificationsPlugin] with bulletproof Android 13+ /
/// Android 14+ behavior:
///
/// * Web → all operations are no-ops.
/// * `init` is idempotent, never throws, and always sets up the
///   `lifehub_reminders` Android channel.
/// * `tz.local` is configured by matching the device's current UTC offset
///   against the timezone database (instead of relying on the unreliable
///   `DateTime.now().timeZoneName`, which on Android returns localized
///   abbreviations like "GMT+5" that `tz.getLocation` cannot resolve).
/// * Scheduling defaults to `inexactAllowWhileIdle` so it works without the
///   `SCHEDULE_EXACT_ALARM` permission (which Google revokes by default on
///   Android 14+). Exact mode is attempted only when the user explicitly
///   granted exact-alarm permission.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Android channels are immutable once created — changing sound/vibration on
  // an existing channel is a no-op. We pre-create four channels covering every
  // (sound × vibration) combination so the user's toggles always pick a
  // channel that already has the right OS-level settings.
  static const String _channelBase = 'lifehub_reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription =
      'Scheduled reminders from LIFEHUB';

  // 1s buzz, 0.4s gap, 1s buzz — feels alarm-like without being painful.
  static final Int64List _vibrationPattern =
      Int64List.fromList(<int>[0, 1000, 400, 1000]);

  String _channelIdFor({required bool sound, required bool vibration}) {
    final String s = sound ? 's1' : 's0';
    final String v = vibration ? 'v1' : 'v0';
    return '${_channelBase}_${s}_$v';
  }

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _exactAlarmGranted = false;

  bool get available => !kIsWeb;
  bool get exactAlarmGranted => _exactAlarmGranted;

  Future<void> init() async {
    if (!available) {
      _initialized = true;
      return;
    }
    if (_initialized) return;

    try {
      tz_data.initializeTimeZones();
      _configureLocalTimezone();
    } catch (e, st) {
      // Timezone init must not block notification init — log and continue.
      debugPrint('NotificationService timezone init failed: $e\n$st');
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

    try {
      await _plugin.initialize(settings);
    } catch (e, st) {
      debugPrint('NotificationService plugin init failed: $e\n$st');
    }

    await _createAndroidChannel();
    _initialized = true;
  }

  /// Finds an IANA timezone whose current offset matches the device's local
  /// offset and pins `tz.local` to it. Falls back to UTC silently.
  void _configureLocalTimezone() {
    final Duration localOffset = DateTime.now().timeZoneOffset;
    final int localOffsetMs = localOffset.inMilliseconds;

    // Fast path — try the device-reported name first (works on iOS, macOS,
    // and some Android ROMs that surface IANA names).
    try {
      final tz.Location loc =
          tz.getLocation(DateTime.now().timeZoneName);
      tz.setLocalLocation(loc);
      return;
    } catch (_) {
      // Fall through to offset matching.
    }

    // Offset-matching path — walk the database and pick any location whose
    // current offset matches.
    for (final tz.Location loc in tz.timeZoneDatabase.locations.values) {
      final int offset = loc.currentTimeZone.offset;
      if (offset == localOffsetMs) {
        tz.setLocalLocation(loc);
        return;
      }
    }

    // Last resort — leave it on UTC; downstream code uses absoluteTime so
    // scheduling still works, just at UTC wall clock.
  }

  Future<void> _createAndroidChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return;

      // Create one channel per (sound × vibration) combination. Android
      // refuses to mutate an existing channel's sound/vibration settings, so
      // we swap channels at scheduling time instead.
      for (final bool sound in <bool>[true, false]) {
        for (final bool vibration in <bool>[true, false]) {
          final AndroidNotificationChannel channel =
              AndroidNotificationChannel(
            _channelIdFor(sound: sound, vibration: vibration),
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
            playSound: sound,
            enableVibration: vibration,
            vibrationPattern: vibration ? _vibrationPattern : null,
          );
          await android.createNotificationChannel(channel);
        }
      }
    } catch (e) {
      debugPrint('NotificationService channel create failed: $e');
    }
  }

  /// Requests POST_NOTIFICATIONS on Android 13+ and alert/badge/sound on iOS.
  /// On Android 12+ also asks for exact-alarm permission if not already
  /// granted — failure is non-fatal because we fall back to inexact.
  Future<NotificationPermissionResult> requestPermission() async {
    if (!available) {
      return const NotificationPermissionResult(
          granted: false, exactAlarmGranted: false);
    }
    if (!_initialized) await init();

    bool granted = true;
    bool exactGranted = false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        // POST_NOTIFICATIONS — Android 13+.
        final PermissionStatus s = await Permission.notification.request();
        granted = s.isGranted;
      } catch (e) {
        debugPrint('Notification permission request failed: $e');
        granted = false;
      }

      // Best-effort exact alarm permission (Android 12+). If unavailable on
      // older OS versions the call throws and we keep `exactGranted = false`.
      try {
        final PermissionStatus s =
            await Permission.scheduleExactAlarm.status;
        if (s.isDenied || s.isPermanentlyDenied) {
          final PermissionStatus r =
              await Permission.scheduleExactAlarm.request();
          exactGranted = r.isGranted;
        } else {
          exactGranted = s.isGranted;
        }
      } catch (_) {
        exactGranted = false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        final bool? r = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        granted = r ?? false;
      } catch (e) {
        debugPrint('iOS permission request failed: $e');
        granted = false;
      }
    }

    _exactAlarmGranted = exactGranted;
    return NotificationPermissionResult(
      granted: granted,
      exactAlarmGranted: exactGranted,
    );
  }

  NotificationDetails _details(NotificationSettings settings) {
    final String channelId = _channelIdFor(
      sound: settings.soundEnabled,
      vibration: settings.vibrationEnabled,
    );
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'reminder',
      playSound: settings.soundEnabled,
      enableVibration: settings.vibrationEnabled,
      vibrationPattern:
          settings.vibrationEnabled ? _vibrationPattern : null,
      category: AndroidNotificationCategory.reminder,
      fullScreenIntent: false,
      visibility: NotificationVisibility.public,
    );
    final DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: settings.soundEnabled,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    return NotificationDetails(
      android: android,
      iOS: ios,
      macOS: ios,
    );
  }

  Future<void> scheduleReminder(
    ReminderItem r, {
    NotificationSettings settings = const NotificationSettings(),
  }) async {
    if (!available) return;
    if (!_initialized) await init();

    // Always cancel any prior schedule for the same id — keeps state clean
    // across edits.
    await _safeCancel(r.notificationId);

    if (!r.enabled) return;
    if (!settings.reminderActive) return;

    final tz.TZDateTime when;
    try {
      when = _firstOccurrence(r);
    } catch (e) {
      debugPrint('scheduleReminder: bad time for ${r.id}: $e');
      return;
    }

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

    // Always start with the safe mode — inexactAllowWhileIdle works on every
    // Android version without exact-alarm permission. Only upgrade to exact
    // when the user explicitly granted it.
    final AndroidScheduleMode mode = _exactAlarmGranted
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _plugin.zonedSchedule(
        r.notificationId,
        r.label.isEmpty ? 'Reminder' : r.label,
        r.subtitle.isEmpty ? null : r.subtitle,
        when,
        _details(settings),
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponents,
        payload: r.id,
      );
    } on PlatformException catch (e) {
      debugPrint(
          'scheduleReminder PlatformException (${e.code}) — retrying inexact');
      // Retry with inexact — covers the rare case where exact was granted
      // and later revoked.
      try {
        await _plugin.zonedSchedule(
          r.notificationId,
          r.label.isEmpty ? 'Reminder' : r.label,
          r.subtitle.isEmpty ? null : r.subtitle,
          when,
          _details(settings),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchComponents,
          payload: r.id,
        );
      } catch (e2) {
        debugPrint('scheduleReminder retry failed: $e2');
      }
    } catch (e) {
      debugPrint('scheduleReminder unknown error: $e');
    }
  }

  Future<void> _safeCancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {
      // Cancelling a non-existent id is not an error we care about.
    }
  }

  Future<void> cancelReminder(int id) async {
    if (!available) return;
    if (!_initialized) await init();
    await _safeCancel(id);
  }

  Future<void> cancelAll() async {
    if (!available) return;
    if (!_initialized) await init();
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('cancelAll failed: $e');
    }
  }

  /// Re-schedules every enabled reminder. Called on app start and whenever
  /// notification settings change.
  Future<void> rescheduleAll(
    List<ReminderItem> all, {
    NotificationSettings settings = const NotificationSettings(),
  }) async {
    if (!available) return;
    if (!_initialized) await init();
    if (!settings.reminderActive) {
      await cancelAll();
      return;
    }
    for (final ReminderItem r in all) {
      if (r.enabled) {
        await scheduleReminder(r, settings: settings);
      } else {
        await _safeCancel(r.notificationId);
      }
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
        // If user picked a past instant, fire shortly — never schedule into
        // the past (which the plugin refuses).
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
        if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
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
        // Anchor to the same weekday as `r.date`. Walk forward until both
        // the weekday matches and the instant is in the future.
        int safety = 0;
        while ((t.weekday != r.date.weekday || !t.isAfter(now)) &&
            safety < 14) {
          t = t.add(const Duration(days: 1));
          safety++;
        }
        return t;
    }
  }
}
