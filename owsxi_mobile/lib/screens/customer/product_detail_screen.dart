import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';

class ProductDetailModal extends StatefulWidget {
  final Product product;

  const ProductDetailModal({super.key, required this.product});

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  late String _selectedVariant;
  final int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.variants.isNotEmpty
        ? widget.product.variants.first
        : 'Standard';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isWishlisted = appState.isWishlisted(widget.product.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
              left: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
              right: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
            ),
          ),
          child: Column(
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  border: Border(
                    bottom: BorderSide(color: AppColors.onSecondaryFixed, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.grid_goldenratio,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PRODUCT DETAILS',
                          style: AppTypography.labelBold(color: AppColors.onSurface),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable Details Body
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Product Image Card
                    NeoBrutalContainer(
                      backgroundColor: AppColors.surfaceContainerLowest,
                      borderColor: AppColors.onSecondaryFixed,
                      shadowColor: AppColors.tertiaryContainer,
                      shadowOffset: const Offset(5, 5),
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            child: Image.network(
                              widget.product.imageUrl,
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 240,
                                color: AppColors.surfaceContainerHigh,
                                child: const Center(
                                  child: Icon(Icons.art_track, size: 48, color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: NeoBrutalBadge(
                              label: widget.product.tag,
                              backgroundColor: AppColors.tertiaryFixed,
                              textColor: AppColors.onTertiaryFixed,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => appState.toggleWishlist(widget.product.id),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest,
                                  border: Border.all(
                                    color: AppColors.onSecondaryFixed,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isWishlisted
                                      ? AppColors.primaryContainer
                                      : AppColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title & Category
                    Text(
                      widget.product.category.toUpperCase(),
                      style: AppTypography.labelSmall(
                        color: AppColors.secondary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.title,
                      style: AppTypography.headlineMedium(color: AppColors.onSurface),
                    ),

                    const SizedBox(height: 12),

                    // Price & Rating Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: AppTypography.displayLarge(
                            color: AppColors.primaryContainer,
                          ).copyWith(fontSize: 32),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            border: Border.all(
                              color: AppColors.onSecondaryFixed,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.tertiaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.product.rating} (128 Reviews)',
                                style: AppTypography.labelSmall(
                                  color: AppColors.onSecondaryFixed,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 2, color: AppColors.onSecondaryFixed),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'DESCRIPTION',
                      style: AppTypography.labelBold(color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.product.description,
                      style: AppTypography.bodyMedium(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Features Grid
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalContainer(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            borderColor: AppColors.onSecondaryFixed,
                            shadowColor: AppColors.onSecondaryFixed,
                            shadowOffset: const Offset(3, 3),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Icon(Icons.water_drop, color: AppColors.primaryContainer, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  'WATERPROOF',
                                  style: AppTypography.labelBold(color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NeoBrutalContainer(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            borderColor: AppColors.onSecondaryFixed,
                            shadowColor: AppColors.onSecondaryFixed,
                            shadowOffset: const Offset(3, 3),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Icon(Icons.wb_sunny, color: AppColors.primaryContainer, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  'UV RESISTANT',
                                  style: AppTypography.labelBold(color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Add to Cart Button CTA
                    NeoBrutalButton(
                      label: 'ADD TO CART',
                      icon: Icons.arrow_forward,
                      backgroundColor: AppColors.primaryContainer,
                      textColor: AppColors.onPrimary,
                      shadowColor: AppColors.onSecondaryFixed,
                      fullWidth: true,
                      onPressed: () {
                        appState.addToCart(
                          widget.product,
                          variant: _selectedVariant,
                          quantity: _quantity,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.onSecondaryFixed,
                            content: Text(
                              'ADDED ${widget.product.title} TO CART!',
                              style: AppTypography.labelBold(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
