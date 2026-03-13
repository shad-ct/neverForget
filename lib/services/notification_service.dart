import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/special_day.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TOP-LEVEL FUNCTIONS — These MUST be top-level or static so they work
// when the app is terminated (background isolate / broadcast receiver).
// ─────────────────────────────────────────────────────────────────────────────

/// Called when user taps the notification body (foreground or background).
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse response) {
  final actionId = response.actionId;

  if (actionId == 'snooze') {
    _handleSnooze(response.id ?? 0);
  } else if (actionId == 'acknowledge') {
    _handleAcknowledge(response.id ?? 0);
  }
  // If no action button was pressed, user simply tapped the notification —
  // the app launches normally via the main entry point.
}

/// Called when a notification action is triggered while the app is in the
/// background or terminated. Also a top-level function.
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  onDidReceiveNotificationResponse(response);
}

/// Snooze: reschedule the same notification for 1 hour later.
void _handleSnooze(int notificationId) {
  final flnp = FlutterLocalNotificationsPlugin();

  // Re-show the notification 1 hour from now with the same ID
  final snoozeTime = tz.TZDateTime.now(tz.local).add(const Duration(hours: 1));

  flnp.zonedSchedule(
    notificationId,
    '⏰ Snoozed Reminder',
    'Your special day reminder was snoozed. Tap to view.',
    snoozeTime,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'special_day_main',
        'Special Day Alerts',
        channelDescription: 'Day-of event alerts with action buttons',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        actions: const [
          AndroidNotificationAction(
            'snooze',
            '⏰ Snooze',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'acknowledge',
            '✅ Acknowledge',
            showsUserInterface: false,
          ),
        ],
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

/// Acknowledge: simply cancel/dismiss the notification.
void _handleAcknowledge(int notificationId) {
  FlutterLocalNotificationsPlugin().cancel(notificationId);
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION SERVICE CLASS
// ─────────────────────────────────────────────────────────────────────────────

/// Manages all notification initialization, scheduling, and cancellation.
///
/// Uses exact alarms via [AndroidScheduleMode.exactAllowWhileIdle] to bypass
/// Doze mode. Timezone-aware via [flutter_timezone].
class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _flnp =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  static NotificationService get instance {
    if (_instance == null) {
      throw StateError(
        'NotificationService not initialized. Call init() first.',
      );
    }
    return _instance!;
  }

  /// Initializes the notification plugin, timezone data, and channels.
  static Future<NotificationService> init() async {
    if (_instance != null) return _instance!;

    final service = NotificationService._();

    // Initialize timezone
    tz.initializeTimeZones();
    if (Platform.isAndroid) {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    }

    // Android initialization — white-on-transparent alpha-only icon
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await service._flnp.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    // Create notification channels
    await service._createChannels();

    _instance = service;
    return service;
  }

  /// Creates the notification channels for Android 8+.
  Future<void> _createChannels() async {
    final androidPlugin = _flnp
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    // Countdown channel (3 days before)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'special_day_countdown',
        'Countdown Alerts',
        description: '3-day countdown reminders for upcoming special days',
        importance: Importance.high,
      ),
    );

    // Main event channel (day of)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'special_day_main',
        'Special Day Alerts',
        description: 'Day-of event alerts with action buttons',
        importance: Importance.max,
      ),
    );
  }

  /// Schedules both the 3-day countdown and day-of-event notifications
  /// for a [SpecialDay] at the user's preferred [notifTime].
  ///
  /// Notification IDs use a deterministic scheme:
  /// - Countdown: `dayId * 10 + 1`
  /// - Day-of:    `dayId * 10 + 2`
  Future<void> scheduleForSpecialDay(
    SpecialDay day,
    TimeOfDay notifTime,
  ) async {
    final nextDate = day.nextOccurrence;

    // ── 3-Day Countdown Alert ──
    final countdownDate = nextDate.subtract(const Duration(days: 3));
    final countdownScheduled = tz.TZDateTime(
      tz.local,
      countdownDate.year,
      countdownDate.month,
      countdownDate.day,
      notifTime.hour,
      notifTime.minute,
    );

    // Only schedule if the countdown date is in the future
    if (countdownScheduled.isAfter(tz.TZDateTime.now(tz.local))) {
      await _flnp.zonedSchedule(
        day.id * 10 + 1,
        '${day.emoji} ${day.title} in 3 days!',
        '${day.category} coming up on ${_formatDate(nextDate)}. Get ready!',
        countdownScheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'special_day_countdown',
            'Countdown Alerts',
            channelDescription:
                '3-day countdown reminders for upcoming special days',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              '${day.emoji} ${day.title} is coming up in just 3 days!\n'
              'Category: ${day.category}\n'
              'Date: ${_formatDate(nextDate)}',
            ),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // ── Day-Of Event Alert (with Snooze & Acknowledge buttons) ──
    final mainEventScheduled = tz.TZDateTime(
      tz.local,
      nextDate.year,
      nextDate.month,
      nextDate.day,
      notifTime.hour,
      notifTime.minute,
    );

    if (mainEventScheduled.isAfter(tz.TZDateTime.now(tz.local))) {
      await _flnp.zonedSchedule(
        day.id * 10 + 2,
        '🎉 Today is ${day.title}!',
        '${day.emoji} Happy ${day.category}! Tap to view details.',
        mainEventScheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'special_day_main',
            'Special Day Alerts',
            channelDescription: 'Day-of event alerts with action buttons',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              '${day.emoji} Today is ${day.title}!\n'
              'Happy ${day.category}! 🎉',
            ),
            actions: const [
              AndroidNotificationAction(
                'snooze',
                '⏰ Snooze',
                showsUserInterface: false,
              ),
              AndroidNotificationAction(
                'acknowledge',
                '✅ Acknowledge',
                showsUserInterface: false,
              ),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Cancels both scheduled notifications for a given special day.
  void cancelForSpecialDay(int dayId) {
    _flnp.cancel(dayId * 10 + 1); // Countdown
    _flnp.cancel(dayId * 10 + 2); // Day-of
  }

  /// Sends an immediate test notification to verify the notification system.
  Future<void> sendTestNotification() async {
    await _flnp.show(
      99,
      '🎉 NeverForget Test',
      'Sreedeep nte birthday aan machu!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'special_day_main',
          'Special Day Alerts',
          channelDescription: 'Day-of event alerts with action buttons',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          actions: [
            AndroidNotificationAction(
              'snooze',
              '⏰ Snooze',
              showsUserInterface: false,
            ),
            AndroidNotificationAction(
              'acknowledge',
              '✅ Acknowledge',
              showsUserInterface: false,
            ),
          ],
        ),
      ),
    );
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _flnp.cancelAll();
  }

  /// Formats a DateTime for display in notifications.
  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
