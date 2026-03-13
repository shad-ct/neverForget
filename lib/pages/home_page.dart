import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/special_day.dart';
import '../providers/reminder_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_edit_dialog.dart';
import '../widgets/glass_card.dart';
import '../widgets/mesh_gradient_background.dart';
import 'settings_page.dart';

/// Main screen showing all special days sorted by closest upcoming date.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('NeverForget'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: 'Settings',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<ReminderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentPurple),
                );
              }

              if (provider.specialDays.isEmpty) {
                return _buildEmptyState();
              }

              return _buildContent(provider.specialDays);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No special days yet', style: AppTheme.headingMedium),
          const SizedBox(height: 8),
          Text('Tap + to add your first reminder', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildContent(List<SpecialDay> allDays) {
    // Get unique categories for filter chips
    final categories = ['All', ...{for (final d in allDays) d.category}];

    // Filter by selected category
    final days = _selectedCategory == 'All'
        ? allDays
        : allDays.where((d) => d.category == _selectedCategory).toList();

    return Column(
      children: [
        // Category filter chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isSelected
                        ? LinearGradient(colors: [
                            AppTheme.accentPurple.withValues(alpha: 0.5),
                            AppTheme.accentPurple.withValues(alpha: 0.2),
                          ])
                        : null,
                    color: isSelected
                        ? null
                        : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentPurple.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isSelected
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // List
        Expanded(child: _buildList(days)),
      ],
    );
  }

  Widget _buildList(List<SpecialDay> days) {
    if (days.isEmpty) {
      return Center(
        child: Text(
          'No entries in this category',
          style: AppTheme.bodyMedium,
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final remaining = day.daysRemaining;

          Color accent;
          if (remaining == 0) {
            accent = AppTheme.accentPink;
          } else if (remaining <= 3) {
            accent = AppTheme.accentCyan;
          } else {
            accent = AppTheme.accentPurple;
          }

          String trailingLabel;
          if (remaining == 0) {
            trailingLabel = '🎉 Today!';
          } else if (remaining == 1) {
            trailingLabel = 'Tomorrow';
          } else {
            trailingLabel = '$remaining days';
          }

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    emoji: day.emoji,
                    title: day.title,
                    subtitle: '${day.category} · ${day.ageFormatted}',
                    trailingText: trailingLabel,
                    accentColor: accent,
                    onTap: () => _showDetailSheet(day),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Shows a detail bottom sheet with edit, delete, call, and message actions.
  void _showDetailSheet(SpecialDay day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final a = day.age;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Emoji + Name
              Text(day.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(day.title, style: AppTheme.headingMedium, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(day.category, style: AppTheme.bodySmall),
              const SizedBox(height: 16),

              // Age display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _agePart('${a.years}', 'Years'),
                    _ageDivider(),
                    _agePart('${a.months}', 'Months'),
                    _ageDivider(),
                    _agePart('${a.days}', 'Days'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Days remaining chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [
                    AppTheme.accentPurple.withValues(alpha: 0.4),
                    AppTheme.accentPurple.withValues(alpha: 0.15),
                  ]),
                ),
                child: Text(
                  day.daysRemaining == 0
                      ? '🎉 Today!'
                      : '${day.daysRemaining} days remaining',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Call
                  if (day.contact != null && day.contact!.isNotEmpty)
                    _actionButton(
                      Icons.call_rounded,
                      'Call',
                      AppTheme.accentCyan,
                      () => _launchUrl('tel:${day.contact}'),
                    ),

                  // SMS
                  if (day.contact != null && day.contact!.isNotEmpty)
                    _actionButton(
                      Icons.message_rounded,
                      'SMS',
                      AppTheme.accentPurple,
                      () => _launchUrl('sms:${day.contact}'),
                    ),

                  // Edit
                  _actionButton(
                    Icons.edit_rounded,
                    'Edit',
                    Colors.amber,
                    () {
                      Navigator.pop(ctx);
                      _showEditDialog(day);
                    },
                  ),

                  // Delete
                  _actionButton(
                    Icons.delete_rounded,
                    'Delete',
                    Colors.redAccent,
                    () {
                      Navigator.pop(ctx);
                      _confirmDelete(day);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _agePart(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTheme.headingMedium.copyWith(
          color: AppTheme.accentCyan,
        )),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  Widget _ageDivider() {
    return Container(
      width: 1, height: 30,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  void _confirmDelete(SpecialDay day) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${day.title}"?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReminderProvider>().deleteSpecialDay(day.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditDialog(
        onSave: (day) {
          context.read<ReminderProvider>().addSpecialDay(day);
        },
      ),
    );
  }

  void _showEditDialog(SpecialDay day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditDialog(
        existingDay: day,
        onSave: (updatedDay) {
          context.read<ReminderProvider>().updateSpecialDay(updatedDay);
        },
      ),
    );
  }
}
