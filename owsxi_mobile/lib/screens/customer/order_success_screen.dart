import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retro Success Badge Box
              NeoBrutalContainer(
                backgroundColor: AppColors.tertiaryFixed,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.primaryContainer,
                shadowOffset: const Offset(6, 6),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        border: Border.all(
                          color: AppColors.onSecondaryFixed,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 48,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ORDER CONFIRMED!',
                      style: AppTypography.headlineLargeMobile(
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your retro art drop has been packed & queued for dispatch.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Order Details Card
              NeoBrutalContainer(
                backgroundColor: AppColors.surfaceContainerLowest,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ORDER NUMBER:',
                          style: AppTypography.labelBold(color: AppColors.onSurface),
                        ),
                        const NeoBrutalBadge(
                          label: 'ORD-9021',
                          backgroundColor: AppColors.secondaryContainer,
                          textColor: AppColors.onSecondaryFixed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ESTIMATED DELIVERY:',
                          style: AppTypography.labelBold(color: AppColors.onSurface),
                        ),
                        Text(
                          'AUG 16 - AUG 18',
                          style: AppTypography.labelSmall(
                            color: AppColors.primaryContainer,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              NeoBrutalButton(
                label: 'TRACK YOUR ORDER',
                icon: Icons.local_shipping_outlined,
                backgroundColor: AppColors.secondaryContainer,
                textColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(context);
                  appState.setCustomerIndex(3); // Open Account / Orders
                },
              ),
              const SizedBox(height: 12),
              NeoBrutalButton(
                label: 'RETURN TO STOREFRONT',
                icon: Icons.storefront,
                backgroundColor: AppColors.primaryContainer,
                textColor: AppColors.onPrimary,
                shadowColor: AppColors.onSecondaryFixed,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(context);
                  appState.setCustomerIndex(0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
