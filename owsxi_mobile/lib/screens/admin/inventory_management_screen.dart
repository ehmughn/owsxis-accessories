import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import 'add_edit_product_screen.dart';

class InventoryManagementScreen extends StatelessWidget {
  const InventoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final products = appState.filteredProducts;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Header & Add Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INVENTORY',
              style: AppTypography.headlineLargeMobile(color: AppColors.primaryContainer),
            ),
            NeoBrutalButton(
              label: '+ ADD NEW PRODUCT',
              icon: Icons.add_circle,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              backgroundColor: AppColors.primaryContainer,
              textColor: AppColors.onPrimary,
              shadowColor: AppColors.primaryContainer,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditProductScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Search & Filters Box
        NeoBrutalContainer(
          backgroundColor: AppColors.surfaceContainerLow,
          borderColor: AppColors.onSecondaryFixed,
          shadowColor: AppColors.onSecondaryFixed,
          shadowOffset: const Offset(3, 3),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              NeoBrutalTextField(
                hint: 'Search SKU or Name...',
                prefixIcon: Icons.search,
                onChanged: (val) => appState.setSearchQuery(val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Product Cards List
        ...products.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _inventoryStitchCard(context, product, appState),
            )),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _inventoryStitchCard(
      BuildContext context, Product product, AppState appState) {
    final isLowStock = product.stockQuantity < 20 && product.stockQuantity > 0;
    final isOutOfStock = product.stockQuantity == 0 || !product.inStock;

    Color badgeBg = AppColors.secondaryContainer;
    Color badgeText = AppColors.onSecondaryContainer;
    String statusLabel = 'IN STOCK (${product.stockQuantity})';

    if (isOutOfStock) {
      badgeBg = AppColors.error;
      badgeText = AppColors.onError;
      statusLabel = 'OUT OF STOCK';
    } else if (isLowStock) {
      badgeBg = AppColors.tertiaryContainer;
      badgeText = AppColors.onTertiaryContainer;
      statusLabel = 'LOW STOCK (${product.stockQuantity})';
    }

    return NeoBrutalContainer(
      backgroundColor: AppColors.surfaceContainerLowest,
      borderColor: AppColors.onSecondaryFixed,
      shadowColor: AppColors.onSecondaryFixed,
      shadowOffset: const Offset(4, 4),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixedDim,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.onSecondaryFixed,
                      width: 3,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.secondaryFixedDim,
                    child: const Center(
                      child: Icon(Icons.art_track, size: 32, color: AppColors.onSecondaryFixed),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: NeoBrutalBadge(
                  label: statusLabel,
                  backgroundColor: badgeBg,
                  textColor: badgeText,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title.toUpperCase(),
                      style: AppTypography.labelBold(color: AppColors.onSurface)
                          .copyWith(fontSize: 16),
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTypography.labelBold(color: AppColors.primaryContainer)
                          .copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: IND-${product.id.toUpperCase()}-001',
                  style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        label: 'EDIT',
                        icon: Icons.edit,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        backgroundColor: AppColors.surfaceContainer,
                        textColor: AppColors.onSurface,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditProductScreen(productToEdit: product),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () {
                        appState.deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
