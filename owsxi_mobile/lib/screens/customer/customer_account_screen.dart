import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import 'order_history_screen.dart';
import 'account_settings_screen.dart';
import 'customer_auth_screen.dart';

class CustomerAccountScreen extends StatelessWidget {
  const CustomerAccountScreen({super.key});

  void _showAddressDialog(BuildContext context, AppState appState) {
    final addr1 = TextEditingController(text: appState.userAddress['address1'] ?? '');
    final addr2 = TextEditingController(text: appState.userAddress['address2'] ?? '');
    final city = TextEditingController(text: appState.userAddress['city'] ?? '');
    final province = TextEditingController(text: appState.userAddress['province'] ?? '');
    final zip = TextEditingController(text: appState.userAddress['zip'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.onSecondaryFixed, width: 3),
        ),
        title: Text('EDIT SHIPPING ADDRESS', style: AppTypography.headlineMedium(color: AppColors.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoBrutalTextField(label: 'Street Address', controller: addr1),
              const SizedBox(height: 10),
              NeoBrutalTextField(label: 'Apartment / Suite', controller: addr2),
              const SizedBox(height: 10),
              NeoBrutalTextField(label: 'City', controller: city),
              const SizedBox(height: 10),
              NeoBrutalTextField(label: 'Province / State', controller: province),
              const SizedBox(height: 10),
              NeoBrutalTextField(label: 'ZIP / Postal Code', controller: zip),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: AppTypography.labelBold(color: AppColors.onSurfaceVariant)),
          ),
          NeoBrutalButton(
            label: 'SAVE',
            backgroundColor: AppColors.primaryContainer,
            onPressed: () async {
              await appState.updateCustomerAddress(
                address1: addr1.text,
                address2: addr2.text,
                city: city.text,
                province: province.text,
                zip: zip.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
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
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (!appState.isLoggedIn) {
      return CustomerAuthScreen(
        onAuthenticated: () {},
      );
    }

    final orders = appState.orders;

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
              child: Center(
                child: Text(
                  appState.userName.isNotEmpty ? appState.userName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'HI, ${appState.userName.toUpperCase()}!',
              textAlign: TextAlign.center,
              style: AppTypography.headlineLargeMobile(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appState.userEmail,
              textAlign: TextAlign.center,
              style: AppTypography.labelBold(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            const NeoBrutalBadge(
              label: 'CUSTOMER',
              backgroundColor: AppColors.tertiaryFixed,
              textColor: AppColors.onTertiaryFixed,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Shipping Address Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SHIPPING ADDRESS',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            GestureDetector(
              onTap: () => _showAddressDialog(context, appState),
              child: Text(
                'EDIT',
                style: AppTypography.labelBold(color: AppColors.primaryContainer),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        NeoBrutalContainer(
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.onSecondaryFixed,
          shadowColor: AppColors.onSecondaryFixed,
          shadowOffset: const Offset(3.5, 3.5),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 28, color: AppColors.primaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appState.formattedAddress,
                  style: AppTypography.bodyMedium(color: AppColors.onSurface),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

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
            // 1. My Orders
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
            // 2. Settings
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountSettingsScreen(),
                  ),
                );
              },
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
            // 3. Log Out
            GestureDetector(
              onTap: () {
                appState.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.onSecondaryFixed,
                    content: Text(
                      'LOGGED OUT',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ),
                );
              },
              child: NeoBrutalContainer(
                backgroundColor: AppColors.primaryContainer,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 32, color: AppColors.onPrimary),
                    const SizedBox(height: 6),
                    Text(
                      'LOG OUT',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Recent Shopify Orders Section
        Text(
          'ORDERS (${orders.length})',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: 12),

        if (orders.isEmpty)
          NeoBrutalContainer(
            backgroundColor: AppColors.surfaceContainerLowest,
            borderColor: AppColors.onSecondaryFixed,
            shadowColor: AppColors.onSecondaryFixed,
            shadowOffset: const Offset(3.5, 3.5),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No orders found for ${appState.userEmail}.',
                    style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          )
        else
          ...orders.map((order) {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final formattedDate =
                '${months[order.date.month - 1]} ${order.date.day}, ${order.date.year}';
            final orderNum = order.trackingNumber.isNotEmpty
                ? order.trackingNumber
                : (order.id.startsWith('#') ? order.id : '#${order.id}');
            final displayOrderNum = orderNum.startsWith('#') ? orderNum : '#$orderNum';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NeoBrutalContainer(
                backgroundColor: AppColors.surfaceContainerLowest,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            'ORDER $displayOrderNum',
                            style: AppTypography.labelBold(color: AppColors.onSecondaryContainer),
                          ),
                          Row(
                            children: [
                              NeoBrutalBadge(
                                label: order.status == OrderStatus.cancelled
                                    ? 'CANCELLED'
                                    : order.paymentStatus,
                                backgroundColor: (order.paymentStatus == 'PAID' && order.status != OrderStatus.cancelled)
                                    ? AppColors.tertiaryFixed
                                    : AppColors.errorContainer,
                                textColor: (order.paymentStatus == 'PAID' && order.status != OrderStatus.cancelled)
                                    ? AppColors.onTertiaryFixed
                                    : AppColors.onErrorContainer,
                              ),
                              const SizedBox(width: 6),
                              NeoBrutalBadge(
                                label: order.statusName.toUpperCase(),
                                backgroundColor: order.status == OrderStatus.cancelled
                                    ? AppColors.errorContainer
                                    : AppColors.onSecondaryFixed,
                                textColor: order.status == OrderStatus.cancelled
                                    ? AppColors.onErrorContainer
                                    : AppColors.onPrimary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Order Details Summary Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        border: Border(
                          bottom: BorderSide(color: AppColors.onSecondaryFixed, width: 2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DATE PLACED',
                                  style: AppTypography.labelSmall(color: AppColors.outline)
                                      .copyWith(fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formattedDate,
                                  style: AppTypography.labelBold(color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Order Items List
                    if (order.items.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ITEMS PURCHASED',
                              style: AppTypography.labelSmall(color: AppColors.outline)
                                  .copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            ...order.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        border: Border.all(
                                          color: AppColors.onSecondaryFixed,
                                          width: 2,
                                        ),
                                      ),
                                      child: item.product.imageUrl.isNotEmpty
                                          ? Image.network(
                                              item.product.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => const Icon(
                                                Icons.shopping_bag,
                                                color: AppColors.onPrimary,
                                                size: 20,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.shopping_bag,
                                              color: AppColors.onPrimary,
                                              size: 20,
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.title,
                                            style: AppTypography.labelBold(
                                              color: AppColors.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Qty: ${item.quantity}  •  ₱${item.product.price.toStringAsFixed(2)} PHP',
                                            style: AppTypography.bodySmall(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₱${item.totalPrice.toStringAsFixed(2)}',
                                      style: AppTypography.labelBold(
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 2, color: AppColors.onSecondaryFixed),
                    ],

                    // Order Footer (Totals & Shipping Address)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL AMOUNT',
                                style: AppTypography.labelBold(color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                '₱${order.total.toStringAsFixed(2)} PHP',
                                style: AppTypography.headlineMedium(color: AppColors.onSurface),
                              ),
                            ],
                          ),
                          if (order.shippingAddress.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColors.outline,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.shippingAddress,
                                    style: AppTypography.bodySmall(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (order.status == OrderStatus.pending) ...[
                            const SizedBox(height: 12),
                            NeoBrutalButton(
                              label: 'CANCEL ORDER',
                              icon: Icons.cancel_outlined,
                              backgroundColor: AppColors.errorContainer,
                              textColor: AppColors.onErrorContainer,
                              shadowColor: AppColors.onSecondaryFixed,
                              fullWidth: true,
                              onPressed: () => _showCancelDialog(context, order),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 32),
      ],
    );
  }
}
