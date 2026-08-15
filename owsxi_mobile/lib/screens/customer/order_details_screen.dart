import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../models/models.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: AppColors.onSecondaryFixed, height: 4),
        ),
        title: Text(
          'ORDER DETAILS ${order.id}',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Tracking Header
            NeoBrutalContainer(
              backgroundColor: AppColors.primaryContainer,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.tertiaryContainer,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.id,
                        style: AppTypography.displayLarge(color: AppColors.onPrimary)
                            .copyWith(fontSize: 28),
                      ),
                      NeoBrutalBadge(
                        label: order.statusName,
                        backgroundColor: AppColors.tertiaryFixed,
                        textColor: AppColors.onTertiaryFixed,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TRACKING ID: ${order.trackingNumber}',
                    style: AppTypography.labelSmall(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dispatch & Delivery Timeline
            Text(
              'DISPATCH & DELIVERY TIMELINE',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 14),
            _timelineStep('Order Confirmed & Payment Verified', 'Aug 10 - 09:14 AM', true),
            _timelineStep('Packaged with Custom Owsxi Stickers', 'Aug 10 - 02:30 PM', true),
            _timelineStep('Dispatched via Courier (In Transit)', 'Aug 11 - 10:00 AM', true),
            _timelineStep('Out for Local Delivery', 'Expected Aug 13', false),

            const SizedBox(height: 28),

            // Items In Package
            Text(
              'ITEMS IN PACKAGE',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NeoBrutalContainer(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  borderColor: AppColors.onSecondaryFixed,
                  shadowOffset: const Offset(2.5, 2.5),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        child: Image.network(
                          item.product.imageUrl,
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
                              item.product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelBold(color: AppColors.onSurface),
                            ),
                            Text(
                              'Qty: ${item.quantity}  •  \$${item.product.price.toStringAsFixed(2)}',
                              style: AppTypography.bodySmall(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Shipping Address Box
            NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(3, 3),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHIPPING ADDRESS',
                    style: AppTypography.labelBold(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress,
                    style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _timelineStep(String title, String time, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerHigh,
              border: Border.all(color: AppColors.onSecondaryFixed, width: 2),
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: 16,
              color: isDone ? AppColors.onPrimary : AppColors.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelBold(
                    color: isDone ? AppColors.onSurface : AppColors.outline,
                  ),
                ),
                Text(
                  time,
                  style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
