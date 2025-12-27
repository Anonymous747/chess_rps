import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/utils/auth_error_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignupScreen extends HookConsumerWidget {
  static const routeName = "signup";

  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final isLoading = useState(false);

    final authController = ref.read(authControllerProvider.notifier);

    // Navigate to mode selector when authenticated
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        AppLogger.info('User registered, navigating to mode selector', tag: 'SignupScreen');
        context.go(AppRoutes.modeSelector);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Palette.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Palette.textPrimary),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Palette.purpleAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person_add_outlined,
                        size: 64,
                        color: Palette.purpleAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Title
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Phone Number Field
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Palette.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Palette.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Palette.textSecondary),
                          hintText: 'Enter your phone number',
                          hintStyle: TextStyle(color: Palette.textTertiary),
                          prefixIcon: Icon(Icons.phone, color: Palette.accent),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (cleaned.length < 10) {
                            return 'Phone number must contain at least 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Palette.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword.value,
                        style: const TextStyle(color: Palette.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Palette.textSecondary),
                          hintText: 'At least 8 characters',
                          hintStyle: TextStyle(color: Palette.textTertiary),
                          prefixIcon: Icon(Icons.lock_outline, color: Palette.accent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Palette.textSecondary,
                            ),
                            onPressed: () {
                              obscurePassword.value = !obscurePassword.value;
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Confirm Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Palette.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword.value,
                        style: const TextStyle(color: Palette.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Palette.textSecondary),
                          hintText: 'Re-enter your password',
                          hintStyle: TextStyle(color: Palette.textTertiary),
                          prefixIcon: Icon(Icons.lock_outline, color: Palette.accent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Palette.textSecondary,
                            ),
                            onPressed: () {
                              obscureConfirmPassword.value = !obscureConfirmPassword.value;
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  isLoading.value = true;
                                  try {
                                    await authController.register(
                                      phoneNumber: phoneController.text,
                                      password: passwordController.text,
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      final errorMessage = AuthErrorHelper.getUserFriendlyError(e);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMessage),
                                          backgroundColor: Palette.error,
                                          duration: const Duration(seconds: 4),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } finally {
                                    // Only update isLoading if widget is still mounted
                                    // (widget may be disposed after successful signup navigation)
                                    if (context.mounted) {
                                      isLoading.value = false;
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.purpleAccent,
                          foregroundColor: Palette.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Palette.textPrimary,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

