import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final filteredProducts = appState.filteredProducts;

    return Column(
      children: [
        // Top Search & Category Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHOP ALL CATALOG',
                style: AppTypography.headlineMedium(color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              // Search Input
              NeoBrutalTextField(
                hint: 'Search stickers, pins, prints...',
                prefixIcon: Icons.search,
                onChanged: (val) => appState.setSearchQuery(val),
              ),
              const SizedBox(height: 14),
              // Category filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['All', 'Sticker', 'Pin', 'Print', 'Charm', 'Apparel']
                      .map((cat) {
                    final isSelected = appState.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => appState.setSelectedCategory(cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerLowest,
                            border: Border.all(
                              color: AppColors.onSecondaryFixed,
                              width: 2.5,
                            ),
                          ),
                          child: Text(
                            cat.toUpperCase(),
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

        // Product Catalog Grid
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 48,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'NO ART DROPS FOUND',
                        style: AppTypography.headlineMedium(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try adjusting your search query or category filter.',
                        style: AppTypography.bodySmall(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.60,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildStitchCatalogCard(context, product, appState);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStitchCatalogCard(
      BuildContext context, Product product, AppState appState) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ProductDetailModal(product: product),
        );
      },
      child: NeoBrutalContainer(
        backgroundColor: AppColors.surfaceContainerLowest,
        borderColor: AppColors.onSecondaryFixed,
        shadowColor: AppColors.onSecondaryFixed,
        shadowOffset: const Offset(3.5, 3.5),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.tertiaryFixed,
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
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.tertiaryFixed,
                  child: const Center(
                    child: Icon(Icons.art_track, size: 36, color: AppColors.onSecondaryFixed),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelBold(
                            color: AppColors.onSecondaryFixed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headlineMedium(
                              color: AppColors.primaryContainer,
                            ).copyWith(fontSize: 18),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            appState.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.onSecondaryFixed,
                                content: Text(
                                  'ADDED ${product.title} TO CART!',
                                  style: AppTypography.labelBold(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              border: Border.all(
                                color: AppColors.onSecondaryFixed,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.onSecondaryFixed,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 20,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
