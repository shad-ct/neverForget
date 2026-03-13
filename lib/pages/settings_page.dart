import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_provider.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mesh_gradient_background.dart';

/// Settings page allowing users to configure their preferred notification time.
///
/// Changing the time automatically reschedules all existing notifications.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TimeOfDay _currentTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTime();
  }

  Future<void> _loadTime() async {
    final time = await SettingsService.getNotificationTime();
    setState(() {
      _currentTime = time;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentPurple),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Notification Time Card
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 160,
                        borderRadius: 20,
                        blur: 15,
                        alignment: Alignment.center,
                        border: 1.5,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.03),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accentPurple.withValues(alpha: 0.4),
                            AppTheme.accentCyan.withValues(alpha: 0.2),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppTheme.accentPurple.withValues(alpha: 0.3),
                                          AppTheme.accentPurple.withValues(alpha: 0.05),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active_rounded,
                                      color: AppTheme.accentPurple,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notification Time',
                                          style: AppTheme.bodyLarge,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'When to send daily reminders',
                                          style: AppTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentPurple.withValues(alpha: 0.4),
                                        AppTheme.accentPurple.withValues(alpha: 0.15),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        color: AppTheme.textPrimary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        SettingsService.formatTime(_currentTime),
                                        style: AppTheme.headingMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info text
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 100,
                        borderRadius: 20,
                        blur: 12,
                        alignment: Alignment.center,
                        border: 1,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.05),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppTheme.accentCyan, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You\'ll receive a countdown alert 3 days before '
                                  'each event and a main alert on the day of the event '
                                  'at the time set above.',
                                  style: AppTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Test notification button
                      GestureDetector(
                        onTap: () async {
                          await NotificationService.instance.sendTestNotification();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Test notification sent! Check your notification shade.'),
                                backgroundColor: AppTheme.surfaceDark,
                              ),
                            );
                          }
                        },
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: 64,
                          borderRadius: 20,
                          blur: 12,
                          alignment: Alignment.center,
                          border: 1.5,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accentCyan.withValues(alpha: 0.12),
                              AppTheme.accentCyan.withValues(alpha: 0.04),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              AppTheme.accentCyan.withValues(alpha: 0.5),
                              AppTheme.accentCyan.withValues(alpha: 0.15),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_active, color: AppTheme.accentCyan, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Send Test Notification',
                                style: AppTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _currentTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentPurple,
              surface: AppTheme.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _currentTime) {
      setState(() => _currentTime = picked);
      await SettingsService.setNotificationTime(picked);

      // Reschedule all notifications with new time
      if (mounted) {
        await context.read<ReminderProvider>().rescheduleAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notification time updated to ${SettingsService.formatTime(picked)}',
              ),
              backgroundColor: AppTheme.surfaceDark,
            ),
          );
        }
      }
    }
  }
}
