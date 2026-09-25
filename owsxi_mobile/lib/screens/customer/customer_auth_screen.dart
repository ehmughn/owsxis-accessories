import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';

class CustomerAuthScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;
  final String? message;

  const CustomerAuthScreen({
    super.key,
    this.onAuthenticated,
    this.message,
  });

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  final _nameController = TextEditingController(text: '');
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth(AppState appState) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? firstName;
    String? lastName;
    if (_isSignUp && name.isNotEmpty) {
      final parts = name.split(' ');
      firstName = parts.first;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Customer';
    }

    final success = await appState.loginWithShopify(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone.isNotEmpty ? phone : null,
      isSignUp: _isSignUp,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        _errorMessage = appState.authError ?? 'Failed to authenticate.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (canPop)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.onSurface, size: 26),
              onPressed: () => Navigator.pop(context, false),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: AppColors.onSecondaryFixed, height: 4),
        ),
        title: Text(
          _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              if (widget.message != null && widget.message!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    border: Border.all(color: AppColors.onSecondaryFixed, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.onPrimary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.message!,
                          style: AppTypography.labelBold(color: AppColors.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                      label: 'CUSTOMER AUTH',
                      backgroundColor: AppColors.tertiaryFixed,
                      textColor: AppColors.onTertiaryFixed,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab Selector (Sign In vs Sign Up)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isSignUp = false;
                        _errorMessage = null;
                      }),
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
                      onTap: () => setState(() {
                        _isSignUp = true;
                        _errorMessage = null;
                      }),
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

              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    border: Border.all(color: AppColors.onErrorContainer, width: 2),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.labelSmall(color: AppColors.onError),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                        hint: 'e.g. Juan Dela Cruz',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                    ],
                    NeoBrutalTextField(
                      label: 'Account Email',
                      hint: 'name@domain.com',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    NeoBrutalTextField(
                      label: 'Password',
                      hint: '••••••••••••',
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.onSurface,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      NeoBrutalTextField(
                        label: 'Phone Number (Optional)',
                        hint: '+63 912 345 6789',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryContainer),
                          )
                        : NeoBrutalButton(
                            label: _isSignUp ? 'REGISTER' : 'SIGN IN',
                            icon: Icons.login,
                            backgroundColor: AppColors.primaryContainer,
                            textColor: AppColors.onPrimary,
                            shadowColor: AppColors.onSecondaryFixed,
                            fullWidth: true,
                            onPressed: () => _submitAuth(appState),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'By signing in, your account profile, addresses, and order history will be saved.',
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
