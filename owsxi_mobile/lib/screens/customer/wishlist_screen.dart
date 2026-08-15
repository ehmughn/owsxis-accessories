import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final wishlist = appState.wishlistProducts;

    return wishlist.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: AppColors.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'YOUR WISHLIST IS EMPTY',
                  style: AppTypography.headlineMedium(color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save your favorite sticker packs & prints here.',
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
        : ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'MY WISHLIST (${wishlist.length})',
                style: AppTypography.headlineMedium(color: AppColors.onSurface),
              ),
              const SizedBox(height: 16),
              ...wishlist.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoBrutalContainer(
                    backgroundColor: AppColors.surfaceContainerLowest,
                    borderColor: AppColors.onSecondaryFixed,
                    shadowColor: AppColors.onSecondaryFixed,
                    shadowOffset: const Offset(3.5, 3.5),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          child: Image.network(
                            product.imageUrl,
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
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelBold(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              NeoBrutalBadge(
                                label: product.category,
                                backgroundColor: AppColors.tertiaryFixed,
                                textColor: AppColors.onTertiaryFixed,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: AppTypography.labelBold(
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: AppColors.primaryContainer,
                              ),
                              onPressed: () => appState.toggleWishlist(product.id),
                            ),
                            GestureDetector(
                              onTap: () {
                                appState.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.onSecondaryFixed,
                                    content: Text(
                                      'MOVED ${product.title} TO CART!',
                                      style: AppTypography.labelBold(
                                        color: AppColors.onPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  border: Border.all(
                                    color: AppColors.onSecondaryFixed,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 16,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ),
                          ],
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
