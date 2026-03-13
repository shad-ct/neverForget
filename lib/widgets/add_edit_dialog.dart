import 'package:flutter/material.dart';

import '../models/special_day.dart';
import '../theme/app_theme.dart';

/// Predefined categories with their default emojis.
const Map<String, String> predefinedCategories = {
  'Birthday': '🎂',
  'Anniversary': '💍',
  'Holiday': '🎄',
};

/// Bottom sheet dialog for adding or editing a [SpecialDay].
///
/// Uses glassmorphic styling consistent with the app's design language.
/// If [existingDay] is provided, pre-fills the form for editing.
class AddEditDialog extends StatefulWidget {
  final SpecialDay? existingDay;
  final Function(SpecialDay day) onSave;

  const AddEditDialog({
    super.key,
    this.existingDay,
    required this.onSave,
  });

  @override
  State<AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<AddEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contactController;
  late TextEditingController _customCategoryController;
  late TextEditingController _emojiController;

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Birthday';
  String _selectedEmoji = '🎂';
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    final day = widget.existingDay;

    _titleController = TextEditingController(text: day?.title ?? '');
    _contactController = TextEditingController(text: day?.contact ?? '');
    _customCategoryController = TextEditingController();
    _emojiController = TextEditingController();

    if (day != null) {
      _selectedDate = day.date;
      _selectedCategory = day.category;
      _selectedEmoji = day.emoji;
      _isCustom = day.isCustom;

      if (_isCustom) {
        _customCategoryController.text = day.category;
        _emojiController.text = day.emoji;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contactController.dispose();
    _customCategoryController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDay != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: double.infinity,
        height: 520,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.surfaceDark,
          border: Border.all(
            color: AppTheme.accentPurple.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  isEditing ? 'Edit Special Day' : 'Add Special Day',
                  style: AppTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Title field
                TextField(
                  controller: _titleController,
                  style: AppTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: "e.g. Mom's Birthday",
                    prefixIcon: Icon(Icons.edit_outlined, color: AppTheme.accentPurple),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact field
                TextField(
                  controller: _contactController,
                  style: AppTheme.bodyLarge,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact (optional)',
                    hintText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.accentCyan),
                  ),
                ),
                const SizedBox(height: 16),

                // Date picker
                _buildDatePicker(),
                const SizedBox(height: 16),

                // Category selector
                _buildCategorySelector(),
                const SizedBox(height: 16),

                // Custom category + emoji (only shown when custom is selected)
                if (_isCustom) ...[
                  Row(
                    children: [
                      // Custom emoji
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _emojiController,
                          style: const TextStyle(fontSize: 28),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '😊',
                            counterText: '',
                          ),
                          maxLength: 2,
                          onChanged: (val) {
                            if (val.isNotEmpty) {
                              setState(() => _selectedEmoji = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Custom category name
                      Expanded(
                        child: TextField(
                          controller: _customCategoryController,
                          style: AppTheme.bodyLarge,
                          decoration: const InputDecoration(
                            labelText: 'Category Label',
                            hintText: 'e.g. Graduation',
                          ),
                          onChanged: (val) {
                            setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Save button
                ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: Icon(isEditing ? Icons.check : Icons.add_rounded),
                  label: Text(isEditing ? 'Update' : 'Add Reminder'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          builder: (ctx, child) {
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
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.accentCyan, size: 20),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: AppTheme.bodyLarge,
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.white.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [...predefinedCategories.keys, 'Custom'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected =
            _isCustom ? cat == 'Custom' : _selectedCategory == cat;
        final emoji = predefinedCategories[cat];

        return GestureDetector(
          onTap: () {
            setState(() {
              if (cat == 'Custom') {
                _isCustom = true;
                _selectedCategory = _customCategoryController.text.isEmpty
                    ? 'Custom'
                    : _customCategoryController.text;
                _selectedEmoji =
                    _emojiController.text.isEmpty ? '⭐' : _emojiController.text;
              } else {
                _isCustom = false;
                _selectedCategory = cat;
                _selectedEmoji = emoji!;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppTheme.accentPurple.withValues(alpha: 0.4),
                        AppTheme.accentPurple.withValues(alpha: 0.15),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: isSelected
                    ? AppTheme.accentPurple.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              cat == 'Custom' ? '✨ Custom' : '$emoji $cat',
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final day = widget.existingDay ?? SpecialDay();
    day.title = title;
    day.date = _selectedDate;
    day.category = _isCustom
        ? (_customCategoryController.text.trim().isEmpty
            ? 'Custom'
            : _customCategoryController.text.trim())
        : _selectedCategory;
    day.emoji = _selectedEmoji;
    day.isCustom = _isCustom;
    day.contact = _contactController.text.trim().isEmpty
        ? null
        : _contactController.text.trim();

    widget.onSave(day);
    Navigator.pop(context);
  }
}
