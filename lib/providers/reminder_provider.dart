import 'package:flutter/material.dart';

import '../models/special_day.dart';
import '../services/isar_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

/// ChangeNotifier provider that manages the list of [SpecialDay] reminders.
///
/// Wraps [IsarService] for persistence and [NotificationService] for
/// scheduling. Exposes a sorted list and CRUD methods that auto-refresh.
class ReminderProvider extends ChangeNotifier {
  final IsarService _isarService;
  List<SpecialDay> _specialDays = [];
  bool _isLoading = false;

  ReminderProvider(this._isarService);

  /// Sorted list of special days (closest upcoming first).
  List<SpecialDay> get specialDays => _specialDays;

  /// Whether data is currently being loaded from the database.
  bool get isLoading => _isLoading;

  /// Loads all special days from the database, sorted by upcoming date.
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _specialDays = await _isarService.getAllSortedByUpcoming();

    _isLoading = false;
    notifyListeners();
  }

  /// Adds a new special day, schedules its notifications, and refreshes.
  Future<void> addSpecialDay(SpecialDay day) async {
    final id = await _isarService.addSpecialDay(day);
    day.id = id;

    // Schedule notifications for this special day
    await _scheduleNotifications(day);

    await loadAll();
  }

  /// Updates an existing special day, reschedules notifications, and refreshes.
  Future<void> updateSpecialDay(SpecialDay day) async {
    await _isarService.updateSpecialDay(day);

    // Cancel old and reschedule new notifications
    NotificationService.instance.cancelForSpecialDay(day.id);
    await _scheduleNotifications(day);

    await loadAll();
  }

  /// Deletes a special day, cancels its notifications, and refreshes.
  Future<void> deleteSpecialDay(int id) async {
    NotificationService.instance.cancelForSpecialDay(id);
    await _isarService.deleteSpecialDay(id);

    await loadAll();
  }

  /// Reschedules all notifications (e.g., when notification time changes).
  Future<void> rescheduleAll() async {
    for (final day in _specialDays) {
      NotificationService.instance.cancelForSpecialDay(day.id);
      await _scheduleNotifications(day);
    }
  }

  /// Schedules the 3-day countdown and day-of notifications for a given day.
  Future<void> _scheduleNotifications(SpecialDay day) async {
    final notifTime = await SettingsService.getNotificationTime();

    await NotificationService.instance.scheduleForSpecialDay(
      day,
      notifTime,
    );
  }
}
