import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  bool _enableFreeShipping = true;
  bool _acceptApplePay = true;
  bool _inventoryAlerts = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'STORE & MERCHANT SETTINGS',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),

        const NeoBrutalTextField(
          label: 'Store Name',
          hint: 'Owsxi Retro Accessories',
        ),
        const SizedBox(height: 14),

        const NeoBrutalTextField(
          label: 'Support Email',
          hint: 'support@owsxistudio.com',
        ),
        const SizedBox(height: 20),

        _settingToggle(
          'Free Shipping Threshold (\$50+)',
          'Automatically apply free shipping for cart totals over \$50.',
          _enableFreeShipping,
          (val) => setState(() => _enableFreeShipping = val),
        ),
        const SizedBox(height: 10),

        _settingToggle(
          'Apple Pay & Digital Wallet',
          'Allow quick checkout with express mobile wallets.',
          _acceptApplePay,
          (val) => setState(() => _acceptApplePay = val),
        ),
        const SizedBox(height: 10),

        _settingToggle(
          'Low Stock Push Alerts',
          'Send push alert when inventory drops below 10 units.',
          _inventoryAlerts,
          (val) => setState(() => _inventoryAlerts = val),
        ),

        const SizedBox(height: 28),

        NeoBrutalButton(
          label: 'SAVE STORE CONFIGURATION',
          icon: Icons.save,
          backgroundColor: AppColors.primaryContainer,
          textColor: AppColors.onPrimary,
          shadowColor: AppColors.onSecondaryFixed,
          fullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.onSecondaryFixed,
                content: Text(
                  'STORE CONFIGURATION SAVED!',
                  style: AppTypography.labelBold(color: AppColors.onPrimary),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _settingToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return NeoBrutalContainer(
      backgroundColor: AppColors.surfaceContainerLowest,
      borderColor: AppColors.onSecondaryFixed,
      shadowColor: AppColors.onSecondaryFixed,
      shadowOffset: const Offset(3, 3),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelBold(color: AppColors.onSurface),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primaryContainer,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
