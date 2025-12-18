import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class ThemeSelectionDialog extends StatelessWidget {
  final String currentTheme;
  final Function(String) onThemeSelected;

  const ThemeSelectionDialog({
    Key? key,
    required this.currentTheme,
    required this.onThemeSelected,
  }) : super(key: key);

  static const List<String> availableThemes = [
    'glass_dark',
    'glass_light',
    'wood_dark',
    'wood_light',
    'marble_dark',
    'marble_light',
  ];

  String _formatThemeName(String theme) {
    return theme.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.backgroundTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Palette.glassBorder),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Board Theme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ...availableThemes.map((theme) {
              final isSelected = theme == currentTheme;
              return InkWell(
                onTap: () {
                  onThemeSelected(theme);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Palette.purpleAccent.withValues(alpha: 0.2)
                        : Palette.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Palette.purpleAccent
                          : Palette.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatThemeName(theme),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Palette.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Palette.purpleAccent,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Palette.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

