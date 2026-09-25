import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  void _showCancelDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final orderNum = order.trackingNumber.isNotEmpty
        ? order.trackingNumber
        : (order.id.startsWith('#') ? order.id : '#${order.id}');
    final displayOrderNum = orderNum.startsWith('#') ? orderNum : '#$orderNum';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.onSecondaryFixed, width: 3),
        ),
        title: Text(
          'CANCEL ORDER?',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        content: Text(
          'Are you sure you want to cancel order $displayOrderNum? This action cannot be undone.',
          style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'NO, KEEP ORDER',
              style: AppTypography.labelBold(color: AppColors.onSurfaceVariant),
            ),
          ),
          NeoBrutalButton(
            label: 'YES, CANCEL ORDER',
            backgroundColor: AppColors.errorContainer,
            textColor: AppColors.onErrorContainer,
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await appState.cancelShopifyOrder(order.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.onSecondaryFixed,
                    content: Text(
                      result['success'] == true
                          ? 'ORDER $displayOrderNum HAS BEEN CANCELLED'
                          : 'ORDER CANCELLED',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final formattedDate = '${months[order.date.month - 1]} ${order.date.day}, ${order.date.year}';
    final orderNum = order.trackingNumber.isNotEmpty
        ? order.trackingNumber
        : (order.id.startsWith('#') ? order.id : '#${order.id}');
    final displayOrderNum = orderNum.startsWith('#') ? orderNum : '#$orderNum';

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
          'ORDER DETAILS $displayOrderNum',
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
                        displayOrderNum,
                        style: AppTypography.displayLarge(color: AppColors.onPrimary)
                            .copyWith(fontSize: 28),
                      ),
                      NeoBrutalBadge(
                        label: order.statusName.toUpperCase(),
                        backgroundColor: order.status == OrderStatus.cancelled
                            ? AppColors.errorContainer
                            : AppColors.tertiaryFixed,
                        textColor: order.status == OrderStatus.cancelled
                            ? AppColors.onErrorContainer
                            : AppColors.onTertiaryFixed,
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
            _timelineStep('Order Confirmed & Payment Verified', formattedDate, true),
            _timelineStep('Packaged with Custom Owsxi Stickers', formattedDate, true),
            _timelineStep('Dispatched via Courier', formattedDate, order.status == OrderStatus.shipped || order.status == OrderStatus.delivered),
            _timelineStep('Out for Local Delivery', order.status == OrderStatus.delivered ? formattedDate : 'Pending', order.status == OrderStatus.delivered),

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
                              'Qty: ${item.quantity}  •  ₱${item.product.price.toStringAsFixed(2)}',
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

            if (order.status == OrderStatus.pending) ...[
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: 'CANCEL ORDER',
                icon: Icons.cancel_outlined,
                backgroundColor: AppColors.errorContainer,
                textColor: AppColors.onErrorContainer,
                shadowColor: AppColors.onSecondaryFixed,
                fullWidth: true,
                onPressed: () => _showCancelDialog(context),
              ),
            ],

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
