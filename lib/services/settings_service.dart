import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's preferred global notification time using SharedPreferences.
///
/// Default time is 9:00 AM if the user hasn't set a preference.
class SettingsService {
  static const _hourKey = 'notification_hour';
  static const _minuteKey = 'notification_minute';

  /// Default notification time: 9:00 AM.
  static const _defaultHour = 9;
  static const _defaultMinute = 0;

  /// Retrieves the user's preferred notification time.
  static Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_hourKey) ?? _defaultHour;
    final minute = prefs.getInt(_minuteKey) ?? _defaultMinute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Saves the user's preferred notification time.
  static Future<void> setNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, time.hour);
    await prefs.setInt(_minuteKey, time.minute);
  }

  /// Formats a [TimeOfDay] to a human-readable string (e.g., "9:00 AM").
  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
