import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? productToEdit;

  const AddEditProductScreen({super.key, this.productToEdit});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _tagController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '18.00');
    _categoryController = TextEditingController(text: p?.category ?? 'Stickers');
    _tagController = TextEditingController(text: p?.tag ?? 'New Drop');
    _stockController = TextEditingController(text: p?.stockQuantity.toString() ?? '30');
    _imageUrlController = TextEditingController(
      text: p?.imageUrl ??
          'https://images.unsplash.com/photo-1572375992501-4b0892d50c69?w=600&auto=format&fit=crop',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _tagController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final appState = Provider.of<AppState>(context, listen: false);

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
          isEditing ? 'EDIT PRODUCT DROP' : 'ADD NEW PRODUCT DROP',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Box
            NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.tertiaryContainer,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ClipRRect(
                    child: Image.network(
                      _imageUrlController.text.isNotEmpty
                          ? _imageUrlController.text
                          : 'https://images.unsplash.com/photo-1572375992501-4b0892d50c69?w=600&auto=format&fit=crop',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.image, size: 48, color: AppColors.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalTextField(
                    label: 'Image Asset URL',
                    controller: _imageUrlController,
                    onChanged: (val) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Inputs
            NeoBrutalTextField(
              label: 'Product Title',
              hint: 'e.g. Retro Holographic Acid Star Sticker Pack',
              controller: _titleController,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: NeoBrutalTextField(
                    label: 'Category',
                    hint: 'Stickers / Prints / Pins',
                    controller: _categoryController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoBrutalTextField(
                    label: 'Tag Badge',
                    hint: 'Best Seller / New',
                    controller: _tagController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: NeoBrutalTextField(
                    label: 'Price (\$)'.toUpperCase(),
                    keyboardType: TextInputType.number,
                    controller: _priceController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoBrutalTextField(
                    label: 'Stock Quantity',
                    keyboardType: TextInputType.number,
                    controller: _stockController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            NeoBrutalTextField(
              label: 'Description',
              hint: 'Enter detailed brutalist product manifesto & materials...',
              controller: _descController,
            ),

            const SizedBox(height: 32),

            // Submit Button CTA
            NeoBrutalButton(
              label: isEditing ? 'SAVE PRODUCT CHANGES' : 'PUBLISH NEW DROP NOW',
              icon: isEditing ? Icons.save : Icons.publish,
              backgroundColor: AppColors.primaryContainer,
              textColor: AppColors.onPrimary,
              shadowColor: AppColors.onSecondaryFixed,
              fullWidth: true,
              onPressed: () {
                final priceVal = double.tryParse(_priceController.text) ?? 18.0;
                final stockVal = int.tryParse(_stockController.text) ?? 30;

                final product = Product(
                  id: isEditing
                      ? widget.productToEdit!.id
                      : 'p_${DateTime.now().millisecondsSinceEpoch}',
                  title: _titleController.text.trim().isEmpty
                      ? 'New Art Drop'
                      : _titleController.text.trim(),
                  description: _descController.text.trim(),
                  price: priceVal,
                  category: _categoryController.text.trim().isEmpty
                      ? 'Stickers'
                      : _categoryController.text.trim(),
                  tag: _tagController.text.trim().isEmpty
                      ? 'New'
                      : _tagController.text.trim(),
                  imageUrl: _imageUrlController.text.trim(),
                  inStock: stockVal > 0,
                  stockQuantity: stockVal,
                );

                if (isEditing) {
                  appState.editProduct(product);
                } else {
                  appState.addProduct(product);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.onSecondaryFixed,
                    content: Text(
                      isEditing ? 'SAVED CHANGES!' : 'PUBLISHED NEW DROP!',
                      style: AppTypography.labelBold(color: AppColors.onPrimary),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
