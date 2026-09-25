import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import 'customer_auth_screen.dart';

class StrikethroughPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  StrikethroughPainter({
    this.color = const Color(0xFF655C8A),
    this.strokeWidth = 1.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProductDetailModal extends StatefulWidget {
  final Product product;

  const ProductDetailModal({super.key, required this.product});

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  late String _selectedVariantTitle;
  ProductVariant? _selectedVariantObj;
  final Map<String, String> _selectedOptionValues = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initDefaultSelections();
  }

  void _initDefaultSelections() {
    if (widget.product.options.isNotEmpty) {
      for (final opt in widget.product.options) {
        if (opt.values.isNotEmpty) {
          _selectedOptionValues[opt.name] = opt.values.first;
        }
      }
    }

    if (widget.product.productVariants.isNotEmpty) {
      _selectedVariantObj = widget.product.productVariants.first;
      _selectedVariantTitle = _selectedVariantObj!.title;
    } else if (widget.product.variants.isNotEmpty) {
      _selectedVariantTitle = widget.product.variants.first;
    } else {
      _selectedVariantTitle = 'Standard';
    }
  }

  double get _currentPrice {
    if (_selectedVariantObj != null && _selectedVariantObj!.price > 0) {
      return _selectedVariantObj!.price;
    }
    return widget.product.price;
  }

  String get _currentImageUrl {
    if (_selectedVariantObj != null && _selectedVariantObj!.imageUrl.isNotEmpty) {
      return _selectedVariantObj!.imageUrl;
    }
    return widget.product.imageUrl;
  }

  bool get _isCurrentSelectionOutOfStock {
    if (_selectedVariantObj != null) {
      return _selectedVariantObj!.inventoryQuantity <= 0;
    }
    if (widget.product.productVariants.isNotEmpty) {
      for (final v in widget.product.productVariants) {
        bool matches = true;
        _selectedOptionValues.forEach((optKey, optVal) {
          final sVal = v.selectedOptions[optKey] ??
              (optKey == 'Variant' ? v.selectedOptions['Title'] : null) ??
              (optKey == 'Title' ? v.selectedOptions['Variant'] : null);
          if (sVal != null &&
              sVal != optVal &&
              !(sVal == 'Default Title' && optVal == 'Default Variant') &&
              !(sVal == 'Default Variant' && optVal == 'Default Title')) {
            matches = false;
          }
        });
        if (matches) {
          return v.inventoryQuantity <= 0;
        }
      }
    }
    return !widget.product.inStock || widget.product.stockQuantity <= 0;
  }

  void _selectVariantObj(ProductVariant v, {VoidCallback? onOptionChanged}) {
    setState(() {
      _selectedVariantObj = v;
      _selectedVariantTitle = v.title;
      v.selectedOptions.forEach((key, val) {
        _selectedOptionValues[key] = val;
      });
    });
    onOptionChanged?.call();
  }

  void _selectOptionValue(String optionName, String value, {VoidCallback? onOptionChanged}) {
    setState(() {
      _selectedOptionValues[optionName] = value;

      if (widget.product.productVariants.isNotEmpty) {
        // Find matching variant
        ProductVariant? match;
        for (final v in widget.product.productVariants) {
          bool isMatch = true;
          _selectedOptionValues.forEach((optKey, optVal) {
            if (v.selectedOptions[optKey] != null && v.selectedOptions[optKey] != optVal) {
              isMatch = false;
            }
          });
          if (isMatch) {
            match = v;
            break;
          }
        }

        if (match != null) {
          _selectedVariantObj = match;
          _selectedVariantTitle = match.title;
        } else {
          // Fallback matching by title containing value
          final titleMatch = widget.product.productVariants.firstWhere(
            (v) => v.title.contains(value),
            orElse: () => widget.product.productVariants.first,
          );
          _selectedVariantObj = titleMatch;
          _selectedVariantTitle = titleMatch.title;
        }
      } else {
        _selectedVariantTitle = value;
      }
    });
    onOptionChanged?.call();
  }

  void _showAddToCartPopup(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (popupContext) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            final double currentUnitPrice = _currentPrice;
            final double totalPrice = currentUnitPrice * _quantity;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
                  left: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
                  right: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Popup Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.primaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ADD TO CART',
                              style: AppTypography.labelBold(color: AppColors.onSurface),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.onSurface),
                          onPressed: () => Navigator.pop(popupContext),
                        ),
                      ],
                    ),
                    const Divider(height: 1, thickness: 2, color: AppColors.onSecondaryFixed),
                    const SizedBox(height: 16),

                    // Product Summary Row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            _currentImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: AppColors.surfaceContainerHigh,
                              child: const Icon(Icons.image, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelBold(color: AppColors.onSurface),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₱${currentUnitPrice.toStringAsFixed(2)}',
                                style: AppTypography.labelSmall(color: AppColors.primaryContainer)
                                    .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 1, color: AppColors.outline),
                    const SizedBox(height: 16),

                    // Variant Choices Section
                    _buildVariantOptionsSection(
                      onOptionChanged: () {
                        setPopupState(() {});
                      },
                    ),

                    const SizedBox(height: 16),

                    // Quantity Counter Selector
                    Text(
                      'QUANTITY',
                      style: AppTypography.labelBold(color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        NeoBrutalContainer(
                          backgroundColor: AppColors.surfaceContainerLowest,
                          borderColor: AppColors.onSecondaryFixed,
                          shadowColor: AppColors.onSecondaryFixed,
                          shadowOffset: const Offset(2, 2),
                          padding: EdgeInsets.zero,
                          child: IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.onSurface),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() => _quantity--);
                                    setPopupState(() {});
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            border: Border.all(
                              color: AppColors.onSecondaryFixed,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$_quantity',
                            style: AppTypography.headlineMedium(color: AppColors.onSurface),
                          ),
                        ),
                        const SizedBox(width: 14),
                        NeoBrutalContainer(
                          backgroundColor: AppColors.surfaceContainerLowest,
                          borderColor: AppColors.onSecondaryFixed,
                          shadowColor: AppColors.onSecondaryFixed,
                          shadowOffset: const Offset(2, 2),
                          padding: EdgeInsets.zero,
                          child: IconButton(
                            icon: const Icon(Icons.add, color: AppColors.onSurface),
                            onPressed: () {
                              setState(() => _quantity++);
                              setPopupState(() {});
                            },
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TOTAL PRICE',
                              style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              '₱${totalPrice.toStringAsFixed(2)}',
                              style: AppTypography.labelBold(color: AppColors.primaryContainer)
                                  .copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Confirm Button
                    NeoBrutalButton(
                      label: _isCurrentSelectionOutOfStock ? 'OUT OF STOCK' : 'CONFIRM ADD TO CART',
                      icon: _isCurrentSelectionOutOfStock ? Icons.block : Icons.check,
                      backgroundColor: _isCurrentSelectionOutOfStock
                          ? AppColors.surfaceContainerHigh
                          : AppColors.primaryContainer,
                      textColor: _isCurrentSelectionOutOfStock
                          ? AppColors.outline
                          : AppColors.onPrimary,
                      shadowColor: AppColors.onSecondaryFixed,
                      fullWidth: true,
                      onPressed: _isCurrentSelectionOutOfStock
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.onSecondaryFixed,
                                  content: Text(
                                    'THIS ITEM IS OUT OF STOCK AND CANNOT BE ADDED TO CART.',
                                    style: AppTypography.labelBold(color: AppColors.onPrimary),
                                  ),
                                ),
                              );
                            }
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);

                              if (!appState.isLoggedIn) {
                                Navigator.pop(popupContext);
                                final authenticated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CustomerAuthScreen(
                                      message: 'Please sign in to your account to add items to cart.',
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                if (authenticated != true && !appState.isLoggedIn) {
                                  return;
                                }
                                if (context.mounted) {
                                  _showAddToCartPopup(context, appState);
                                }
                                return;
                              }

                              final added = appState.addToCart(
                                widget.product,
                                variant: _selectedVariantTitle,
                                quantity: _quantity,
                                variantObj: _selectedVariantObj,
                              );

                              if (!added) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.onSecondaryFixed,
                                    content: Text(
                                      'THIS ITEM IS OUT OF STOCK AND CANNOT BE ADDED TO CART.',
                                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(popupContext);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }

                              messenger.showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.onSecondaryFixed,
                                  content: Text(
                                    'ADDED $_quantity x ${widget.product.title} ($_selectedVariantTitle) TO CART!',
                                    style: AppTypography.labelBold(
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  final Map<String, bool> _expandedMetafields = {};

  Widget _buildMetafieldsAccordionSection() {
    final List<Map<String, String>> accordionItems = [];

    // Always include Product Details item if description exists
    if (widget.product.description.trim().isNotEmpty) {
      accordionItems.add({
        'title': 'Product Details',
        'content': widget.product.description,
      });
    }

    if (widget.product.metafields.isNotEmpty) {
      for (final m in widget.product.metafields) {
        if (m.value.trim().isNotEmpty) {
          // Avoid duplicate Product Details title
          if (m.label == 'Product Details' && widget.product.description.trim().isNotEmpty) {
            continue;
          }
          accordionItems.add({
            'title': m.label,
            'content': m.value,
          });
        }
      }
    } else {
      accordionItems.add({
        'title': 'Size',
        'content': '• Total length, ring to lace tips: approx. 12-13 cm\n• Width: approx. 3-4 cm (the lace widens slightly at the bottom)',
      });
    }

    return Column(
      children: accordionItems.map((item) {
        final title = item['title']!;
        final content = item['content']!;
        final isExpanded = _expandedMetafields[title] ?? false;

        return Column(
          children: [
            const Divider(height: 1, thickness: 1, color: AppColors.onSecondaryFixed),
            InkWell(
              onTap: () {
                setState(() {
                  _expandedMetafields[title] = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.close : Icons.add,
                      size: 20,
                      color: AppColors.onSurface,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  String _toKebabCase(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _redirectToReview() async {
    final handle = _toKebabCase(widget.product.title);
    final urlString = 'https://owsxi.myshopify.com/products/$handle';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch review URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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
                      child: ClipRRect(
                        child: Image.network(
                          _currentImageUrl,
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
                          '₱${_currentPrice.toStringAsFixed(2)}',
                          style: AppTypography.displayLarge(
                            color: AppColors.primaryContainer,
                          ).copyWith(fontSize: 32),
                        ),
                        GestureDetector(
                          onTap: _redirectToReview,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
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
                                  Icons.open_in_new,
                                  size: 14,
                                  color: AppColors.onSecondaryFixed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Redirect to review',
                                  style: AppTypography.labelSmall(
                                    color: AppColors.onSecondaryFixed,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 2, color: AppColors.onSecondaryFixed),
                    const SizedBox(height: 16),

                    // Styled Variant & Option Selector
                    _buildVariantOptionsSection(),

                    const SizedBox(height: 16),

                    // Description Section
                    if (widget.product.description.trim().isNotEmpty) ...[
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
                      const SizedBox(height: 16),
                    ],

                    // Product Metafields Accordion (Product Details, Size, etc.)
                    _buildMetafieldsAccordionSection(),

                    const SizedBox(height: 24),

                    // Add to Cart Button CTA (Triggers Popup)
                    NeoBrutalButton(
                      label: _isCurrentSelectionOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                      icon: _isCurrentSelectionOutOfStock ? Icons.block : Icons.shopping_cart,
                      backgroundColor: _isCurrentSelectionOutOfStock
                          ? AppColors.surfaceContainerHigh
                          : AppColors.primaryContainer,
                      textColor: _isCurrentSelectionOutOfStock
                          ? AppColors.outline
                          : AppColors.onPrimary,
                      shadowColor: AppColors.onSecondaryFixed,
                      fullWidth: true,
                      onPressed: _isCurrentSelectionOutOfStock
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.onSecondaryFixed,
                                  content: Text(
                                    'THIS ITEM IS OUT OF STOCK AND CANNOT BE ADDED TO CART.',
                                    style: AppTypography.labelBold(color: AppColors.onPrimary),
                                  ),
                                ),
                              );
                            }
                          : () {
                              _showAddToCartPopup(context, appState);
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

  Widget _buildVariantOptionsSection({VoidCallback? onOptionChanged}) {
    // 1. If product has explicit options (e.g. Material, Color)
    if (widget.product.options.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.product.options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opt.name == 'Title' ? 'Variant' : opt.name,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: opt.values.map((val) {
                    return _buildOptionTile(
                      groupName: opt.name,
                      valTitle: val,
                      onOptionChanged: onOptionChanged,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // 2. If product has variants list (e.g. Round Button, Heart Button, Pink, Red, etc.)
    if (widget.product.productVariants.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Variant',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.product.productVariants.map((v) {
              return _buildVariantCardTile(
                v,
                onOptionChanged: onOptionChanged,
              );
            }).toList(),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  bool _isOptionOutOfStock(String groupName, String valTitle) {
    final variants = widget.product.productVariants;
    if (variants.isEmpty) {
      return !widget.product.inStock || widget.product.stockQuantity <= 0;
    }

    // Build combination of active selections including this option tile value
    final Map<String, String> testSelection = Map.from(_selectedOptionValues);
    testSelection[groupName] = valTitle;

    // 1. Try finding exact variant matching testSelection
    ProductVariant? exactMatch;
    for (final v in variants) {
      if (v.selectedOptions.isNotEmpty) {
        bool matchesAll = true;
        testSelection.forEach((key, val) {
          final sVal = v.selectedOptions[key] ??
              (key == 'Variant' ? v.selectedOptions['Title'] : null) ??
              (key == 'Title' ? v.selectedOptions['Variant'] : null);
          if (sVal != null &&
              sVal != val &&
              !(sVal == 'Default Title' && val == 'Default Variant') &&
              !(sVal == 'Default Variant' && val == 'Default Title')) {
            matchesAll = false;
          }
        });
        if (matchesAll) {
          exactMatch = v;
          break;
        }
      }
    }

    if (exactMatch != null) {
      return exactMatch.inventoryQuantity <= 0;
    }

    // 2. Fallback: Check all variants matching valTitle
    final matchingVariants = variants.where((v) {
      final optVal = v.selectedOptions[groupName] ??
          (groupName == 'Variant' ? v.selectedOptions['Title'] : null) ??
          (groupName == 'Title' ? v.selectedOptions['Variant'] : null);
      if (optVal != null) {
        return optVal == valTitle ||
            (optVal == 'Default Title' && valTitle == 'Default Variant') ||
            (optVal == 'Default Variant' && valTitle == 'Default Title');
      }
      final titleLower = v.title.toLowerCase();
      final valLower = valTitle.toLowerCase();
      return titleLower == valLower ||
          titleLower.contains(valLower) ||
          (valTitle == 'Default Variant' &&
              (titleLower.contains('default') || titleLower.contains('standard')));
    }).toList();

    if (matchingVariants.isEmpty) {
      return false;
    }

    // Out of stock ONLY if ALL matching variants have inventoryQuantity <= 0
    final hasInStock = matchingVariants.any((v) => v.inventoryQuantity > 0);
    return !hasInStock;
  }

  Widget _buildOptionTile({
    required String groupName,
    required String valTitle,
    VoidCallback? onOptionChanged,
  }) {
    final selectedVal = _selectedOptionValues[groupName];
    final isSelected = selectedVal == valTitle;
    final isOutOfStock = _isOptionOutOfStock(groupName, valTitle);
    final displayTitle = valTitle == 'Default Title' ? 'Default Variant' : valTitle;

    final tileContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        displayTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Courier',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
    );

    Widget cardWidget = Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.onSecondaryFixed : AppColors.surfaceContainerLowest,
        border: Border.all(
          color: isSelected ? AppColors.onSecondaryFixed : const Color(0xFFC8A951),
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: tileContent,
    );

    // Apply diagonal strikethrough line if out of stock
    if (isOutOfStock) {
      cardWidget = CustomPaint(
        foregroundPainter: StrikethroughPainter(),
        child: Opacity(
          opacity: 0.65,
          child: cardWidget,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _selectOptionValue(groupName, valTitle, onOptionChanged: onOptionChanged),
      child: cardWidget,
    );
  }

  Widget _buildVariantCardTile(
    ProductVariant v, {
    VoidCallback? onOptionChanged,
  }) {
    final isSelected = _selectedVariantObj?.id == v.id || _selectedVariantTitle == v.title;
    final isOutOfStock = v.inventoryQuantity <= 0;
    final displayTitle = v.title == 'Default Title' ? 'Default Variant' : v.title;

    final tileContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        displayTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Courier',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
    );

    Widget cardWidget = Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.onSecondaryFixed : AppColors.surfaceContainerLowest,
        border: Border.all(
          color: isSelected ? AppColors.onSecondaryFixed : const Color(0xFFC8A951),
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: tileContent,
    );

    if (isOutOfStock) {
      cardWidget = CustomPaint(
        foregroundPainter: StrikethroughPainter(),
        child: Opacity(
          opacity: 0.65,
          child: cardWidget,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _selectVariantObj(v, onOptionChanged: onOptionChanged),
      child: cardWidget,
    );
  }
}
