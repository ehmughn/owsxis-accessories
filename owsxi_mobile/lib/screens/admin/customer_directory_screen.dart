import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';

class CustomerDirectoryScreen extends StatelessWidget {
  const CustomerDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final customers = appState.customers;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'CUSTOMER DIRECTORY (${customers.length})',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        ...customers.map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(3.5, 3.5),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    child: Image.network(
                      c.avatarUrl,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 54,
                        height: 54,
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.person, size: 28, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: AppTypography.labelBold(color: AppColors.onSurface),
                        ),
                        Text(
                          c.email,
                          style: AppTypography.bodySmall(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            NeoBrutalBadge(
                              label: '${c.totalOrders} ORDERS',
                              backgroundColor: AppColors.secondaryFixed,
                              textColor: AppColors.onSecondaryFixed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '\$${c.totalSpent.toStringAsFixed(2)} Spent',
                              style: AppTypography.labelSmall(
                                color: AppColors.primaryContainer,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
