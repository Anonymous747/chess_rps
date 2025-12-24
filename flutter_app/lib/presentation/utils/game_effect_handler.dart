import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/presentation/utils/effect_utils.dart';
import 'package:flutter/material.dart';

/// Handler for applying visual effects during gameplay
class GameEffectHandler {
  /// Apply effect when a piece moves
  static void applyMoveEffect(
    BuildContext context,
    String? effectName,
    VoidCallback onComplete,
  ) {
    final effect = effectName ?? 'classic';
    AppLogger.info('Applying move effect: $effect', tag: 'GameEffectHandler');
    
    // Map effect names to their visual style
    final effectLower = effect.toLowerCase();
    
    // Effects that show particle/overlay animations
    if (effectLower == 'sparkle' || 
        effectLower == 'particles' || 
        effectLower == 'magic' ||
        effectLower == 'cosmic' ||
        effectLower == 'stardust' ||
        effectLower == 'aurora' ||
        effectLower == 'nebula' ||
        effectLower == 'galaxy') {
      _showEffectOverlay(context, effect, onComplete);
    }
    // Effects that show glow
    else if (effectLower == 'glow' || 
             effectLower == 'neon' ||
             effectLower == 'electric' ||
             effectLower == 'plasma') {
      _showGlowEffect(context, effect, onComplete);
    }
    // Effects that show dark/shadow
    else if (effectLower == 'void' || 
             effectLower == 'shadow' ||
             effectLower == 'dark' ||
             effectLower == 'abyss') {
      _showDarkEffect(context, effect, onComplete);
    }
    // Classic effect - no special animation
    else {
      onComplete();
    }
  }

  /// Apply effect when a piece is captured
  static void applyCaptureEffect(
    BuildContext context,
    String? effectName,
    VoidCallback onComplete,
  ) {
    final effect = effectName ?? 'classic';
    AppLogger.info('Applying capture effect: $effect', tag: 'GameEffectHandler');
    
    final effectLower = effect.toLowerCase();
    
    // Effects that show explosion/particle animations
    if (effectLower == 'explosion' || 
        effectLower == 'fire' ||
        effectLower == 'inferno' ||
        effectLower == 'sparkle' ||
        effectLower == 'particles' ||
        effectLower == 'magic' ||
        effectLower == 'cosmic' ||
        effectLower == 'stardust' ||
        effectLower == 'aurora' ||
        effectLower == 'nebula' ||
        effectLower == 'galaxy') {
      _showEffectOverlay(context, effect, onComplete, isCapture: true);
    }
    // Effects that show dark/shadow
    else if (effectLower == 'void' || 
             effectLower == 'shadow' ||
             effectLower == 'dark' ||
             effectLower == 'abyss') {
      _showDarkEffect(context, effect, onComplete);
    }
    // Effects that show glow
    else if (effectLower == 'glow' || 
             effectLower == 'neon' ||
             effectLower == 'electric' ||
             effectLower == 'plasma') {
      _showGlowEffect(context, effect, onComplete);
    }
    // Classic effect - no special animation
    else {
      onComplete();
    }
  }

  /// Show a simple effect overlay
  static void _showEffectOverlay(
    BuildContext context,
    String effect,
    VoidCallback onComplete, {
    bool isCapture = false,
  }) {
    final color = EffectUtils.getEffectColor(effect);
    
    // Show a brief overlay
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => _EffectOverlay(
        color: color,
        isCapture: isCapture,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete();
        },
      ),
    );
  }

  /// Show glow effect
  static void _showGlowEffect(
    BuildContext context,
    String effect,
    VoidCallback onComplete,
  ) {
    final color = EffectUtils.getEffectColor(effect);
    
    // Show a glow overlay
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => _GlowOverlay(
        color: color,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete();
        },
      ),
    );
  }

  /// Show dark effect
  static void _showDarkEffect(
    BuildContext context,
    String effect,
    VoidCallback onComplete,
  ) {
    final color = EffectUtils.getEffectColor(effect);
    
    // Show a dark overlay
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => _DarkOverlay(
        color: color,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete();
        },
      ),
    );
  }
}

/// Simple overlay widget for effects
class _EffectOverlay extends StatefulWidget {
  final Color color;
  final VoidCallback onComplete;
  final bool isCapture;

  const _EffectOverlay({
    required this.color,
    required this.onComplete,
    this.isCapture = false,
  });

  @override
  State<_EffectOverlay> createState() => _EffectOverlayState();
}

class _EffectOverlayState extends State<_EffectOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.isCapture ? 400 : 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: widget.isCapture ? 1.5 : 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.isCapture ? 150 : 100,
                  height: widget.isCapture ? 150 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.4),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.6),
                        blurRadius: widget.isCapture ? 30 : 20,
                        spreadRadius: widget.isCapture ? 15 : 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Glow overlay widget for glow effects
class _GlowOverlay extends StatefulWidget {
  final Color color;
  final VoidCallback onComplete;

  const _GlowOverlay({
    required this.color,
    required this.onComplete,
  });

  @override
  State<_GlowOverlay> createState() => _GlowOverlayState();
}

class _GlowOverlayState extends State<_GlowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withOpacity(0.6),
                        widget.color.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.8),
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Dark overlay widget for dark/shadow effects
class _DarkOverlay extends StatefulWidget {
  final Color color;
  final VoidCallback onComplete;

  const _DarkOverlay({
    required this.color,
    required this.onComplete,
  });

  @override
  State<_DarkOverlay> createState() => _DarkOverlayState();
}

class _DarkOverlayState extends State<_DarkOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.7),
                        blurRadius: 50,
                        spreadRadius: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

