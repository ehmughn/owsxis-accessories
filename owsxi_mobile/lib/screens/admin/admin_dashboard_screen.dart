import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Welcome Banner
        NeoBrutalContainer(
          backgroundColor: AppColors.primaryContainer,
          borderColor: AppColors.onSecondaryFixed,
          shadowColor: AppColors.onSecondaryFixed,
          shadowOffset: const Offset(4, 4),
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADMIN DASHBOARD',
                    style: AppTypography.headlineMedium(color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overview & Real-time Metrics',
                    style: AppTypography.labelBold(color: AppColors.onPrimaryContainer),
                  ),
                ],
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: NeoBrutalBadge(
                  label: 'LIVE',
                  backgroundColor: AppColors.tertiaryContainer,
                  textColor: AppColors.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Metrics Stack (Stitch 1-to-1)
        _metricStackRow(
          title: 'TOTAL SALES',
          value: '\$12,450',
          badgeText: '+15%',
          badgeBg: AppColors.primaryContainer,
          badgeTextCol: AppColors.onPrimary,
          iconBg: AppColors.secondary,
          icon: Icons.payments,
          shadowColor: AppColors.tertiaryContainer,
        ),
        const SizedBox(height: 12),
        _metricStackRow(
          title: 'PENDING ORDERS',
          value: '34',
          badgeText: 'ACTION',
          badgeBg: AppColors.secondary,
          badgeTextCol: AppColors.onSecondary,
          iconBg: AppColors.tertiaryContainer,
          icon: Icons.pending_actions,
          shadowColor: AppColors.primaryContainer,
        ),
        const SizedBox(height: 12),
        _metricStackRow(
          title: 'LOW STOCK ITEMS',
          value: '12',
          badgeText: 'RESTOCK',
          badgeBg: AppColors.error,
          badgeTextCol: AppColors.onError,
          iconBg: AppColors.error,
          icon: Icons.warning,
          shadowColor: AppColors.onSecondaryFixed,
          onBadgeTap: () => appState.setAdminIndex(1),
        ),

        const SizedBox(height: 24),

        // Sales Over Time Chart Box
        NeoBrutalContainer(
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.onSecondaryFixed,
          shadowColor: AppColors.onSecondaryFixed,
          shadowOffset: const Offset(4, 4),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixedDim,
                  border: Border(
                    bottom: BorderSide(color: AppColors.onSecondaryFixed, width: 3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SALES OVER TIME',
                      style: AppTypography.labelBold(color: AppColors.onSecondaryFixed),
                    ),
                    const NeoBrutalBadge(
                      label: 'THIS WEEK',
                      backgroundColor: AppColors.surfaceContainerLowest,
                      textColor: AppColors.onSurface,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _chartBar(0.4, AppColors.primaryContainer),
                      _chartBar(0.65, AppColors.tertiaryContainer),
                      _chartBar(0.3, AppColors.primaryContainer),
                      _chartBar(0.85, AppColors.tertiaryContainer),
                      _chartBar(0.5, AppColors.primaryContainer),
                      _chartBar(0.95, AppColors.tertiaryContainer),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Recent Activity Section
        Text(
          'RECENT ACTIVITY',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: 12),

        _activityItem(
          title: 'New Order #4092',
          subtitle: '3x Sticker Packs',
          time: '2m ago',
          icon: Icons.shopping_cart,
        ),
        const SizedBox(height: 8),
        _activityItem(
          title: 'Stock Alert: Sad Hammy Pin',
          subtitle: 'Inventory dropped below 5 units',
          time: '15m ago',
          icon: Icons.warning_amber,
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _metricStackRow({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextCol,
    required Color iconBg,
    required IconData icon,
    required Color shadowColor,
    VoidCallback? onBadgeTap,
  }) {
    return NeoBrutalContainer(
      backgroundColor: AppColors.surfaceContainerLowest,
      borderColor: AppColors.onSecondaryFixed,
      shadowColor: shadowColor,
      shadowOffset: const Offset(4, 4),
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  border: Border.all(color: AppColors.onSecondaryFixed, width: 2),
                ),
                child: Icon(icon, color: AppColors.onPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
                  ),
                  Text(
                    value,
                    style: AppTypography.headlineMedium(color: AppColors.onSurface),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: onBadgeTap,
            child: NeoBrutalBadge(
              label: badgeText,
              backgroundColor: badgeBg,
              textColor: badgeTextCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(double factor, Color color) {
    return Container(
      width: 28,
      height: 120 * factor,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.onSecondaryFixed, width: 2),
      ),
    );
  }

  Widget _activityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
  }) {
    return NeoBrutalContainer(
      backgroundColor: AppColors.surfaceContainerLowest,
      borderColor: AppColors.onSecondaryFixed,
      shadowColor: AppColors.onSecondaryFixed,
      shadowOffset: const Offset(3, 3),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.tertiaryContainer, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelBold(color: AppColors.onSurface),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
