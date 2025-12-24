import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

/// Stylish dialog for finishing/surrendering a game
class FinishGameDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const FinishGameDialog({
    Key? key,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.backgroundTertiary,
              Palette.backgroundSecondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Palette.glassBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: Palette.error.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flag Icon
              _buildFlagIcon(),
              const SizedBox(height: 24),
              // Title
              _buildTitle(),
              const SizedBox(height: 16),
              // Warning Message
              _buildWarningMessage(),
              const SizedBox(height: 32),
              // Buttons
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlagIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Palette.error.withOpacity(0.3),
            Palette.error.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Palette.error.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.error.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        Icons.flag,
        size: 48,
        color: Palette.error,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Finish Game?',
      style: TextStyle(
        color: Palette.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Palette.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Palette.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Palette.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Warning',
                style: TextStyle(
                  color: Palette.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Are you sure you want to finish this game?\nYour progress will be lost.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Palette.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: _buildCancelButton(context),
        ),
        const SizedBox(width: 12),
        // Confirm Button
        Expanded(
          child: _buildConfirmButton(context),
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Palette.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCancel,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  color: Palette.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cancel',
                  style: TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Palette.error,
            Palette.error.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Palette.error.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onConfirm,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag,
                  color: Palette.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Finish',
                  style: TextStyle(
                    color: Palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


