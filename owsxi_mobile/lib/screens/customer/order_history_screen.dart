import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;

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
          'MY ORDERS',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildStitchOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildStitchOrderCard(BuildContext context, OrderModel order) {
    final isDelivered = order.status == OrderStatus.delivered;

    return NeoBrutalContainer(
      backgroundColor: AppColors.surfaceContainerLowest,
      borderColor: AppColors.onSecondaryFixed,
      shadowColor: AppColors.onSecondaryFixed,
      shadowOffset: const Offset(4, 4),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER #${order.id}',
                    style: AppTypography.headlineMedium(color: AppColors.onSurface),
                  ),
                  Text(
                    isDelivered ? 'Delivered: Sep 12, 2023' : 'Placed: Oct 24, 2023',
                    style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              NeoBrutalBadge(
                label: order.statusName.toUpperCase(),
                backgroundColor: isDelivered
                    ? AppColors.surfaceVariant
                    : AppColors.primaryContainer,
                textColor: isDelivered
                    ? AppColors.onSurfaceVariant
                    : AppColors.onPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 2, color: AppColors.onSecondaryFixed),
          const SizedBox(height: 12),

          // Item preview
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    child: Image.network(
                      item.product.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 56,
                        height: 56,
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
                          style: AppTypography.labelBold(color: AppColors.onSurface),
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: AppTypography.headlineMedium(color: AppColors.onSurface)
                        .copyWith(fontSize: 16),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Order summary breakdown box
          if (!isDelivered) ...[
            NeoBrutalContainer(
              backgroundColor: AppColors.secondaryFixedDim,
              borderColor: AppColors.onSecondaryFixed,
              shadowOffset: Offset.zero,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _summaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                  _summaryRow('Shipping', '\$${order.shippingFee.toStringAsFixed(2)}'),
                  _summaryRow('Tax', '\$1.92'),
                  const Divider(height: 12, color: AppColors.onSecondaryFixed),
                  _summaryRow('Total', '\$${order.total.toStringAsFixed(2)}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeoBrutalButton(
              label: 'TRACK PACKAGE',
              icon: Icons.location_on,
              backgroundColor: AppColors.primaryContainer,
              textColor: AppColors.onPrimary,
              shadowColor: AppColors.onSecondaryFixed,
              fullWidth: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(order: order),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTypography.labelBold(color: AppColors.onSecondaryFixed)
                : AppTypography.bodySmall(color: AppColors.onSecondaryFixed),
          ),
          Text(
            val,
            style: isBold
                ? AppTypography.labelBold(color: AppColors.onSecondaryFixed)
                : AppTypography.bodySmall(color: AppColors.onSecondaryFixed),
          ),
        ],
      ),
    );
  }
}
