import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';

class AdminLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AdminLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _adminEmailController = TextEditingController(text: 'admin@owsxi.secure');
  final _adminPassController = TextEditingController(text: 'admin12345');

  @override
  void dispose() {
    _adminEmailController.dispose();
    _adminPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeoBrutalContainer(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  borderColor: AppColors.onSecondaryFixed,
                  shadowColor: AppColors.onSecondaryFixed,
                  shadowOffset: const Offset(6, 6),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          border: Border.all(
                            color: AppColors.onSecondaryFixed,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 40,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'OWSXI',
                        style: AppTypography.displayLarge(color: AppColors.onSurface)
                            .copyWith(fontSize: 36),
                      ),
                      const SizedBox(height: 4),
                      const NeoBrutalBadge(
                        label: 'ADMIN CONTROL PANEL',
                        backgroundColor: AppColors.tertiaryFixed,
                        textColor: AppColors.onTertiaryFixed,
                      ),
                      const SizedBox(height: 24),
                      NeoBrutalTextField(
                        label: 'Admin Email',
                        hint: 'admin@owsxi.secure',
                        controller: _adminEmailController,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      NeoBrutalTextField(
                        label: 'Secure Password',
                        hint: '••••••••',
                        obscureText: true,
                        controller: _adminPassController,
                        prefixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 24),
                      NeoBrutalButton(
                        label: 'SIGN IN',
                        icon: Icons.arrow_forward,
                        backgroundColor: AppColors.primaryContainer,
                        textColor: AppColors.onPrimary,
                        shadowColor: AppColors.onSecondaryFixed,
                        fullWidth: true,
                        onPressed: widget.onLoginSuccess,
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 2, color: AppColors.outlineVariant),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SECURE ACCESS ONLY',
                            style: AppTypography.labelSmall(
                              color: AppColors.onSurfaceVariant,
                            ).copyWith(letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'This system is for authorized Owsxi personnel only. All access attempts are logged and monitored.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
