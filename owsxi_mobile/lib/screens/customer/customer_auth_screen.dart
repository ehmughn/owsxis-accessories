import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';

class CustomerAuthScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;

  const CustomerAuthScreen({super.key, this.onAuthenticated});

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  bool _isSignUp = false;
  final _emailController = TextEditingController(text: 'eman@owsxistudio.com');
  final _passwordController = TextEditingController(text: 'retro-pop-1234');
  final _nameController = TextEditingController(text: 'Eman Studio');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Brand Logo Box
              NeoBrutalContainer(
                backgroundColor: AppColors.primaryContainer,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.tertiaryContainer,
                shadowOffset: const Offset(5, 5),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'OWSXI STUDIO',
                      style: AppTypography.displayLarge(color: AppColors.onPrimary)
                          .copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    const NeoBrutalBadge(
                      label: 'CUSTOMER AUTHENTICATION',
                      backgroundColor: AppColors.tertiaryFixed,
                      textColor: AppColors.onTertiaryFixed,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Tab Selector (Sign In vs Sign Up)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isSignUp = false),
                      child: NeoBrutalContainer(
                        backgroundColor: !_isSignUp
                            ? AppColors.tertiaryContainer
                            : AppColors.surfaceContainerLowest,
                        borderColor: AppColors.onSecondaryFixed,
                        shadowOffset: Offset.zero,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          'SIGN IN',
                          style: AppTypography.labelBold(
                            color: !_isSignUp
                                ? AppColors.onTertiaryContainer
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isSignUp = true),
                      child: NeoBrutalContainer(
                        backgroundColor: _isSignUp
                            ? AppColors.tertiaryContainer
                            : AppColors.surfaceContainerLowest,
                        borderColor: AppColors.onSecondaryFixed,
                        shadowOffset: Offset.zero,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          'CREATE ACCOUNT',
                          style: AppTypography.labelBold(
                            color: _isSignUp
                                ? AppColors.onTertiaryContainer
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Auth Input Form Box
              NeoBrutalContainer(
                backgroundColor: AppColors.surfaceContainerLowest,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSignUp) ...[
                      NeoBrutalTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                    ],
                    NeoBrutalTextField(
                      label: 'Email Address',
                      hint: 'name@domain.com',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    NeoBrutalTextField(
                      label: 'Password',
                      hint: '••••••••••••',
                      obscureText: true,
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 24),
                    NeoBrutalButton(
                      label: _isSignUp ? 'CREATE ACCOUNT NOW' : 'SIGN IN TO SCRAPBOOK',
                      icon: Icons.login,
                      backgroundColor: AppColors.primaryContainer,
                      textColor: AppColors.onPrimary,
                      shadowColor: AppColors.onSecondaryFixed,
                      fullWidth: true,
                      onPressed: () {
                        if (widget.onAuthenticated != null) {
                          widget.onAuthenticated!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'By authenticating, you agree to Owsxi Retro Pop Terms & Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
