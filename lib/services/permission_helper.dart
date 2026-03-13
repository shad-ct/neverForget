import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized permission helper that handles all Android permission workflows.
/// Handles POST_NOTIFICATIONS (Android 13+), SCHEDULE_EXACT_ALARM (Android 12+),
/// and battery optimization exemption for alarm reliability.
class PermissionHelper {
  /// Requests all required permissions in sequence.
  /// Returns `true` if all critical permissions were granted.
  static Future<bool> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final notifGranted = await _requestNotificationPermission(context);
    if (!context.mounted) return notifGranted;
    final alarmGranted = await _requestExactAlarmPermission(context);

    return notifGranted && alarmGranted;
  }

  /// Requests POST_NOTIFICATIONS permission (Android 13+).
  static Future<bool> _requestNotificationPermission(
    BuildContext context,
  ) async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final result = await Permission.notification.request();
    if (result.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(
        context,
        title: 'Notifications Required',
        message:
            'NeverForget needs notification permission to alert you about '
            'upcoming special days. Please enable it in Settings.',
      );
      return false;
    }

    return result.isGranted;
  }

  /// Checks and requests SCHEDULE_EXACT_ALARM permission (Android 12+).
  /// On Android 14+, users can revoke this in settings — we handle denial.
  static Future<bool> _requestExactAlarmPermission(
    BuildContext context,
  ) async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) return true;

    final result = await Permission.scheduleExactAlarm.request();

    if (!result.isGranted && context.mounted) {
      _showSettingsDialog(
        context,
        title: 'Exact Alarms Required',
        message:
            'NeverForget needs Exact Alarm permission to send timely reminders. '
            'Without this, notifications may be delayed or skipped entirely.',
      );
      return false;
    }

    return result.isGranted;
  }


  /// Shows a dialog directing the user to app settings when permission
  /// is permanently denied.
  static void _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Later',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Color(0xFF7B68EE)),
            ),
          ),
        ],
      ),
    );
  }

  /// Checks if all required permissions are currently granted.
  static Future<bool> areAllPermissionsGranted() async {
    if (!Platform.isAndroid) return true;

    final notif = await Permission.notification.isGranted;
    final alarm = await Permission.scheduleExactAlarm.isGranted;
    return notif && alarm;
  }
}
