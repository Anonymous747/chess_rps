import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:chess_rps/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LanguageSelectionDialog extends ConsumerWidget {
  final Locale currentLocale;

  const LanguageSelectionDialog({
    Key? key,
    required this.currentLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: Palette.backgroundTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Palette.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _LanguageOption(
              title: l10n.english,
              locale: const Locale('en'),
              isSelected: currentLocale.languageCode == 'en',
              onTap: () async {
                await ref.read(localeNotifierProvider.notifier).setLocale(const Locale('en'));
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              title: l10n.russian,
              locale: const Locale('ru'),
              isSelected: currentLocale.languageCode == 'ru',
              onTap: () async {
                await ref.read(localeNotifierProvider.notifier).setLocale(const Locale('ru'));
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Palette.purpleAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Palette.purpleAccent : Palette.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Palette.purpleAccent : Palette.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Palette.purpleAccent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

