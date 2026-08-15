import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import 'product_detail_screen.dart';

class StorefrontHomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToCatalog;

  const StorefrontHomeScreen({super.key, this.onNavigateToCatalog});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final products = appState.products;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Hero Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.tertiaryContainer,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClipRRect(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida/AP1WRLvZvvy1cMNK_lnDYCGlRjl6mr1544dOl3xbuo49Ze_lQDx2OXUnqObMXtDPkGyY-yShCKne3t8F-PFR4gxDaSU3aw3NnR6DqyqgCafaZkJs9jdu6kzZ4EfVweVRkSEOmSizDcg5rn-5m7uQITlFPw_1JHCzEsP4nVSukgxvOEI2-wwygHggL0tKVZSdiF8iqBzXRPQlAnfovLWxAc10DB5Y02NSCZNIoXUVyc_mQA7RC1xtiuVjpmdfHRWvu-EcbRCT6lSxRSYblQ',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 140,
                        width: double.infinity,
                        color: AppColors.secondaryFixedDim,
                        child: const Center(
                          child: Icon(Icons.palette, size: 48, color: AppColors.onSecondaryFixed),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NOSTALGIC ART\nFOR MODERN SOULS',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineLargeMobile(
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grab our latest sticker drops and indie-sleaze prints before they vanish.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  NeoBrutalButton(
                    label: 'SHOP NOW',
                    backgroundColor: AppColors.tertiaryContainer,
                    textColor: AppColors.onTertiaryContainer,
                    shadowColor: AppColors.onSecondaryFixed,
                    fullWidth: true,
                    onPressed: () {
                      if (onNavigateToCatalog != null) {
                        onNavigateToCatalog!();
                      } else {
                        appState.setCustomerIndex(1);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Marquee Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppColors.onSecondaryFixed,
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.tertiaryContainer, width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: const Text(
                '✦ INDIE ART DROP ✦  LIMITED RUN  ✦ INDIE ART DROP ✦  LIMITED RUN  ✦ INDIE ART DROP ✦',
                style: TextStyle(
                  color: AppColors.tertiaryFixed,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Featured Collection Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'FEATURED COLLECTION',
              style: AppTypography.headlineMedium(color: AppColors.onSecondaryFixed),
            ),
          ),
          const SizedBox(height: 14),

          // Featured Horizontal List View
          SizedBox(
            height: 310,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.take(4).length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildHorizontalProductCard(context, product, appState);
              },
            ),
          ),

          const SizedBox(height: 28),

          // Buy 3 Stickers Promo Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NeoBrutalContainer(
              backgroundColor: AppColors.primaryContainer,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(6, 6),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.stars,
                    size: 54,
                    color: AppColors.onPrimaryContainer,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'BUY 3 STICKERS, GET 1 FREE PIN!',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium(color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mix and match any stickers to unlock your bonus pin.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(color: AppColors.primaryFixed),
                  ),
                  const SizedBox(height: 18),
                  NeoBrutalButton(
                    label: 'CLAIM OFFER',
                    backgroundColor: AppColors.surfaceContainerLowest,
                    textColor: AppColors.onSecondaryFixed,
                    shadowColor: AppColors.tertiaryContainer,
                    fullWidth: true,
                    onPressed: () {
                      appState.setCustomerIndex(1);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductCard(
      BuildContext context, Product product, AppState appState) {
    return SizedBox(
      width: 230,
      child: GestureDetector(
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
          shadowColor: AppColors.primaryContainer,
          shadowOffset: const Offset(4, 4),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Header with Tag
              Stack(
                children: [
                  Container(
                    height: 140,
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
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.secondaryFixedDim,
                        child: const Center(
                          child: Icon(Icons.art_track, size: 36, color: AppColors.onSecondaryFixed),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: NeoBrutalBadge(
                      label: product.tag,
                      backgroundColor: AppColors.tertiaryContainer,
                      textColor: AppColors.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelBold(
                        color: AppColors.onSecondaryFixed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    NeoBrutalButton(
                      label: 'ADD TO CART',
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: AppColors.surfaceContainer,
                      textColor: AppColors.onSecondaryFixed,
                      shadowColor: AppColors.onSecondaryFixed,
                      fullWidth: true,
                      onPressed: () {
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
