import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import 'order_history_screen.dart';

class CustomerAccountScreen extends StatelessWidget {
  const CustomerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),

        // Profile Section
        Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.onSecondaryFixed,
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.tertiaryContainer,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'HI, ALEX!',
              style: AppTypography.headlineLargeMobile(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'STICKER COLLECTOR',
              style: AppTypography.labelBold(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Dashboard Navigation Grid
        Text(
          'DASHBOARD',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: 12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderHistoryScreen(),
                  ),
                );
              },
              child: NeoBrutalContainer(
                backgroundColor: AppColors.tertiaryContainer,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2, size: 32, color: AppColors.onTertiaryContainer),
                    const SizedBox(height: 6),
                    Text(
                      'MY ORDERS',
                      style: AppTypography.labelBold(color: AppColors.onTertiaryContainer),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => appState.setCustomerIndex(3),
              child: NeoBrutalContainer(
                backgroundColor: AppColors.surfaceContainer,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, size: 32, color: AppColors.onSurface),
                    const SizedBox(height: 6),
                    Text(
                      'WISHLIST',
                      style: AppTypography.labelBold(color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: NeoBrutalContainer(
                backgroundColor: AppColors.surfaceContainer,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.settings, size: 32, color: AppColors.onSurface),
                    const SizedBox(height: 6),
                    Text(
                      'SETTINGS',
                      style: AppTypography.labelBold(color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => appState.toggleAdminMode(),
              child: NeoBrutalContainer(
                backgroundColor: AppColors.primaryContainer,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.primaryContainer,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 32, color: AppColors.onPrimary),
                    const SizedBox(height: 6),
                    Text(
                      'ADMIN PORTAL',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Recent Hauls Section
        Text(
          'RECENT HAULS',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: 12),

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
                  color: AppColors.secondaryContainer,
                  border: Border(
                    bottom: BorderSide(color: AppColors.onSecondaryFixed, width: 3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORDER #9928',
                      style: AppTypography.labelBold(color: AppColors.onSecondaryContainer),
                    ),
                    const NeoBrutalBadge(
                      label: 'SHIPPED',
                      backgroundColor: AppColors.onSecondaryFixed,
                      textColor: AppColors.onPrimary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida/AP1WRLvZvvy1cMNK_lnDYCGlRjl6mr1544dOl3xbuo49Ze_lQDx2OXUnqObMXtDPkGyY-yShCKne3t8F-PFR4gxDaSU3aw3NnR6DqyqgCafaZkJs9jdu6kzZ4EfVweVRkSEOmSizDcg5rn-5m7uQITlFPw_1JHCzEsP4nVSukgxvOEI2-wwygHggL0tKVZSdiF8iqBzXRPQlAnfovLWxAc10DB5Y02NSCZNIoXUVyc_mQA7RC1xtiuVjpmdfHRWvu-EcbRCT6lSxRSYblQ',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.art_track, size: 24, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Placed: Oct 12, 2023',
                            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '2 Items · \$45.00',
                            style: AppTypography.labelBold(color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
