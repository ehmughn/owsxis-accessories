import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: appState.userName);
    _phoneController = TextEditingController(text: appState.userPhone);
    _emailController = TextEditingController(text: appState.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showEditAddressDialog(BuildContext context, AppState appState) {
    final addr = appState.userAddress;
    final address1Controller = TextEditingController(text: addr['address1'] ?? '');
    final address2Controller = TextEditingController(text: addr['address2'] ?? '');
    final cityController = TextEditingController(text: addr['city'] ?? '');
    final provinceController = TextEditingController(text: addr['province'] ?? '');
    final zipController = TextEditingController(text: addr['zip'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.onSecondaryFixed, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'EDIT SHIPPING ADDRESS',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoBrutalTextField(
                label: 'Street Address',
                controller: address1Controller,
              ),
              const SizedBox(height: 10),
              NeoBrutalTextField(
                label: 'Apartment / Suite (Optional)',
                controller: address2Controller,
              ),
              const SizedBox(height: 10),
              NeoBrutalTextField(
                label: 'City',
                controller: cityController,
              ),
              const SizedBox(height: 10),
              NeoBrutalTextField(
                label: 'Province / State',
                controller: provinceController,
              ),
              const SizedBox(height: 10),
              NeoBrutalTextField(
                label: 'ZIP Code',
                controller: zipController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: AppTypography.labelBold(color: AppColors.outline),
            ),
          ),
          NeoBrutalButton(
            label: 'SAVE',
            backgroundColor: AppColors.primaryContainer,
            textColor: AppColors.onPrimary,
            shadowColor: AppColors.onSecondaryFixed,
            onPressed: () async {
              await appState.updateCustomerAddress(
                address1: address1Controller.text.trim(),
                address2: address2Controller.text.trim(),
                city: cityController.text.trim(),
                province: provinceController.text.trim(),
                zip: zipController.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.onSecondaryFixed,
                    content: Text(
                      'ADDRESS UPDATED SUCCESSFULLY!',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: AppColors.onSecondaryFixed, height: 4),
        ),
        title: Text(
          'ACCOUNT SETTINGS',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Information
            Text(
              'PROFILE INFORMATION',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeoBrutalTextField(
                    label: 'Full Name',
                    hint: 'Your full name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalTextField(
                    label: 'Mobile Number',
                    hint: 'Mobile number',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalTextField(
                    label: 'Email Address',
                    hint: 'Your email address',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  NeoBrutalButton(
                    label: 'SAVE CHANGES',
                    icon: Icons.save_outlined,
                    backgroundColor: AppColors.tertiaryContainer,
                    textColor: AppColors.onTertiaryContainer,
                    shadowColor: AppColors.onSecondaryFixed,
                    fullWidth: true,
                    onPressed: () {
                      appState.updateProfile(
                        name: _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.onSecondaryFixed,
                          content: Text(
                            'PROFILE UPDATED SUCCESSFULLY!',
                            style: AppTypography.labelBold(color: AppColors.onPrimary),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Saved Addresses
            Text(
              'SAVED ADDRESSES',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            NeoBrutalContainer(
              backgroundColor: AppColors.secondaryContainer,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, color: AppColors.onSecondaryContainer, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEFAULT SHIPPING ADDRESS',
                          style: AppTypography.labelBold(color: AppColors.onSecondaryContainer),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.formattedAddress,
                          style: AppTypography.bodySmall(color: AppColors.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.onSecondaryContainer),
                    onPressed: () => _showEditAddressDialog(context, appState),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Log Out Button
            NeoBrutalButton(
              label: 'LOG OUT OF ACCOUNT',
              icon: Icons.logout,
              backgroundColor: AppColors.primaryContainer,
              textColor: AppColors.onPrimary,
              shadowColor: AppColors.onSecondaryFixed,
              fullWidth: true,
              onPressed: () {
                appState.logout();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.onSecondaryFixed,
                    content: Text(
                      'LOGGED OUT SUCCESSFULLY',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
