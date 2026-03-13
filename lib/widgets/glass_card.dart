import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A reusable glassmorphic card widget with frosted glass effect.
///
/// Designed for accessibility on dark glass backgrounds:
/// all text uses FontWeight.w600 + text shadows for contrast.
class GlassCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? trailingText;
  final Color? accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const GlassCard({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle = '',
    this.trailingText,
    this.accentColor,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.accentPurple;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Pseudo-glassmorphism: a semi-transparent gradient + border
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(
            color: accent.withValues(alpha: 0.4),
            width: 1.5,
          ),
          // A tiny shadow instead of blur helps lift it
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Emoji badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.3),
                      accent.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: AppTheme.emojiLarge),
              ),
              const SizedBox(width: 14),

              // Title & subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing: days remaining or custom widget
              if (trailing != null)
                trailing!
              else if (trailingText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.4),
                        accent.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                  child: Text(
                    trailingText!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
