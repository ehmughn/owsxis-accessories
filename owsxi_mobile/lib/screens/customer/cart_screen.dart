import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import 'checkout_screen.dart';
import 'customer_auth_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final cartItems = appState.cartItems;

    return cartItems.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: AppColors.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'YOUR CART IS EMPTY',
                  style: AppTypography.headlineMedium(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore our latest sticker drops & indie sleaze prints.',
                  style: AppTypography.bodyMedium(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                NeoBrutalButton(
                  label: 'EXPLORE CATALOG',
                  icon: Icons.storefront,
                  backgroundColor: AppColors.primaryContainer,
                  onPressed: () => appState.setCustomerIndex(1),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOUR CART',
                      style: AppTypography.headlineMedium(color: AppColors.onSurface),
                    ),
                    NeoBrutalBadge(
                      label: '${cartItems.length} ITEMS',
                      backgroundColor: AppColors.tertiaryContainer,
                      textColor: AppColors.onTertiaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cart Item List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return NeoBrutalContainer(
                      backgroundColor: AppColors.surfaceContainerLowest,
                      borderColor: AppColors.onSecondaryFixed,
                      shadowColor: AppColors.onSecondaryFixed,
                      shadowOffset: const Offset(3.5, 3.5),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            child: Image.network(
                              item.variantImageUrl?.isNotEmpty == true
                                  ? item.variantImageUrl!
                                  : item.product.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.surfaceContainerHigh,
                                child: const Icon(Icons.art_track, size: 28, color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    NeoBrutalBadge(
                                      label: item.product.tag,
                                      backgroundColor: AppColors.onSecondaryFixed,
                                      textColor: AppColors.tertiaryFixed,
                                    ),
                                    NeoBrutalBadge(
                                      label: item.selectedVariant,
                                      backgroundColor: AppColors.secondaryFixed,
                                      textColor: AppColors.onSecondaryFixed,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.headlineMedium(
                                    color: AppColors.onSecondaryFixed,
                                  ).copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.product.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySmall(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                onPressed: () => appState.removeFromCart(index),
                              ),
                              Text(
                                '₱${item.unitPrice.toStringAsFixed(2)}',
                                style: AppTypography.labelBold(
                                  color: AppColors.onSecondaryFixed,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.onSecondaryFixed,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          appState.updateCartQuantity(index, -1),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        child: Text('-',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Text(
                                        '${item.quantity}',
                                        style: AppTypography.labelSmall(
                                          color: AppColors.onSurface,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          appState.updateCartQuantity(index, 1),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        child: Text('+',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Order Summary Sidebar Box
                NeoBrutalContainer(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  borderColor: AppColors.onSecondaryFixed,
                  shadowColor: AppColors.tertiaryContainer,
                  shadowOffset: const Offset(4, 4),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER SUMMARY',
                        style: AppTypography.headlineMedium(
                          color: AppColors.onSecondaryFixed,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        'Subtotal (${cartItems.length} items)',
                        '\$${appState.cartSubtotal.toStringAsFixed(2)}',
                      ),
                      _summaryRow('Shipping', 'Calculated at next step'),
                      _summaryRow('Taxes', '\$${appState.cartTaxes.toStringAsFixed(2)}'),
                      const Divider(
                        height: 24,
                        thickness: 2,
                        color: AppColors.onSecondaryFixed,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: AppTypography.headlineMedium(
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                          Text(
                            '\$${appState.cartTotal.toStringAsFixed(2)}',
                            style: AppTypography.displayLarge(
                              color: AppColors.onSecondaryFixed,
                            ).copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Checkout CTA
                NeoBrutalButton(
                  label: 'CHECKOUT',
                  icon: Icons.shopping_bag_outlined,
                  backgroundColor: AppColors.primaryContainer,
                  textColor: AppColors.onPrimary,
                  shadowColor: AppColors.onSecondaryFixed,
                  fullWidth: true,
                  onPressed: () async {
                    if (!appState.isLoggedIn) {
                      final authenticated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerAuthScreen(
                            message: 'Please sign in to your Shopify account to proceed to checkout.',
                          ),
                        ),
                      );
                      if (authenticated != true && !appState.isLoggedIn) {
                        return;
                      }
                    }

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: AppTypography.labelBold(color: AppColors.onSecondaryFixed),
          ),
        ],
      ),
    );
  }
}
