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
                    hint: '+1 555-0000',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalTextField(
                    label: 'Email Address',
                    hint: 'you@domain.com',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SAVED ADDRESSES',
                  style: AppTypography.headlineMedium(color: AppColors.onSurface),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.onSecondaryFixed,
                        content: Text(
                          'ADD NEW ADDRESS FORM OPENED',
                          style: AppTypography.labelBold(color: AppColors.onPrimary),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      border: Border.all(color: AppColors.onSecondaryFixed, width: 2),
                    ),
                    child: const Icon(Icons.add, color: AppColors.onPrimary, size: 20),
                  ),
                ),
              ],
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
                          'HOME (DEFAULT)',
                          style: AppTypography.labelBold(color: AppColors.onSecondaryContainer),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '123 Brutal St, Apt 4B\nNeo City, 90210',
                          style: AppTypography.bodySmall(color: AppColors.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.onSecondaryContainer),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Security
            Text(
              'ACCOUNT SECURITY',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset, color: AppColors.onSurface),
                    title: Text(
                      'CHANGE PASSWORD',
                      style: AppTypography.labelBold(color: AppColors.onSurface),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.onSurface),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.onSecondaryFixed,
                          content: Text(
                            'PASSWORD RESET LINK SENT TO YOUR EMAIL',
                            style: AppTypography.labelBold(color: AppColors.onPrimary),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16, thickness: 2, color: AppColors.onSecondaryFixed),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'TWO-FACTOR AUTH (2FA)',
                      style: AppTypography.labelBold(color: AppColors.onSurface),
                    ),
                    subtitle: Text(
                      _twoFactorEnabled ? 'Enabled (SMS/Authenticator)' : 'Disabled',
                      style: AppTypography.bodySmall(
                        color: _twoFactorEnabled ? AppColors.tertiary : AppColors.error,
                      ),
                    ),
                    value: _twoFactorEnabled,
                    activeTrackColor: AppColors.primaryContainer,
                    onChanged: (val) {
                      setState(() => _twoFactorEnabled = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Linked Wallets
            Text(
              'LINKED WALLETS',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            NeoBrutalContainer(
              backgroundColor: AppColors.tertiaryFixed,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: AppColors.onTertiaryFixed, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GCASH WALLET',
                          style: AppTypography.labelBold(color: AppColors.onTertiaryFixed),
                        ),
                        Text(
                          'Linked • ***1234',
                          style: AppTypography.bodySmall(color: AppColors.onTertiaryFixed),
                        ),
                      ],
                    ),
                  ),
                  const NeoBrutalBadge(
                    label: 'ACTIVE',
                    backgroundColor: AppColors.primaryContainer,
                    textColor: AppColors.onPrimary,
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
