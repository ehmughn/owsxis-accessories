import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allOrders = appState.orders;

    final filteredOrders = allOrders.where((order) {
      if (_statusFilter == 'All') return true;
      return order.statusName.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    return Column(
      children: [
        // Header & Status Filter Pills
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER MANAGEMENT (${allOrders.length})',
                style: AppTypography.headlineMedium(color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['All', 'Processing', 'In Transit', 'Delivered']
                      .map((status) {
                    final isSelected = _statusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _statusFilter = status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerLowest,
                            border: Border.all(
                              color: AppColors.onSecondaryFixed,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: AppTypography.labelSmall(
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : AppColors.onSurface,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Orders List with Status Update Dropdown Actions
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: filteredOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _orderAdminTile(context, order, appState);
            },
          ),
        ),
      ],
    );
  }

  Widget _orderAdminTile(
      BuildContext context, OrderModel order, AppState appState) {
    return NeoBrutalContainer(
      backgroundColor: AppColors.surfaceContainerLowest,
      borderColor: AppColors.onSecondaryFixed,
      shadowColor: AppColors.onSecondaryFixed,
      shadowOffset: const Offset(3.5, 3.5),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: AppTypography.headlineMedium(color: AppColors.onSurface).copyWith(
                  fontSize: 20,
                ),
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
            'TRACKING: ${order.trackingNumber}',
            style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'ADDRESS: ${order.shippingAddress}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL: \$${order.total.toStringAsFixed(2)}',
                style: AppTypography.labelBold(color: AppColors.primaryContainer),
              ),
              // Status Update Selector
              PopupMenuButton<OrderStatus>(
                onSelected: (newStatus) {
                  appState.updateOrderStatus(order.id, newStatus);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.onSecondaryFixed,
                      content: Text(
                        'UPDATED STATUS FOR ${order.id}',
                        style: AppTypography.labelBold(color: AppColors.onPrimary),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    border: Border.all(color: AppColors.onSecondaryFixed, width: 2),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'UPDATE STATUS',
                        style: AppTypography.labelSmall(
                          color: AppColors.onSecondaryFixed,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.onSecondaryFixed,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: OrderStatus.processing,
                    child: Text('Mark as Processing'),
                  ),
                  PopupMenuItem(
                    value: OrderStatus.shipped,
                    child: Text('Mark as In Transit'),
                  ),
                  PopupMenuItem(
                    value: OrderStatus.delivered,
                    child: Text('Mark as Delivered'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
