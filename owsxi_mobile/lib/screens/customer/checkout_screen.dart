import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController(text: 'Eman Studio');
  final _addressController =
      TextEditingController(text: '742 Evergreen Terrace, Sector 7G');
  final _cityController = TextEditingController(text: 'Springfield');
  final _zipController = TextEditingController(text: '97477');

  String _paymentMethod = 'Credit Card';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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
          'SECURE CHECKOUT',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Section
            Text(
              '1. SHIPPING ADDRESS',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            NeoBrutalTextField(
              label: 'Full Name',
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            NeoBrutalTextField(
              label: 'Street Address',
              controller: _addressController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: NeoBrutalTextField(
                    label: 'City',
                    controller: _cityController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: NeoBrutalTextField(
                    label: 'ZIP Code',
                    controller: _zipController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Payment Method Section
            Text(
              '2. PAYMENT METHOD',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            _paymentOptionTile('Credit Card', Icons.credit_card),
            const SizedBox(height: 8),
            _paymentOptionTile('Apple Pay / Google Pay', Icons.phone_iphone),
            const SizedBox(height: 8),
            _paymentOptionTile('Retro Pop Cash Card', Icons.card_giftcard),

            const SizedBox(height: 28),

            // Order Breakdown Box
            NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.tertiaryContainer,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL CHARGE',
                    style: AppTypography.labelBold(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${appState.cartItems.length} Cart Items',
                        style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        '\$${appState.cartTotal.toStringAsFixed(2)}',
                        style: AppTypography.headlineMedium(
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Place Order CTA Button
            NeoBrutalButton(
              label: 'PLACE ORDER NOW',
              icon: Icons.check_circle_outline,
              backgroundColor: AppColors.primaryContainer,
              textColor: AppColors.onPrimary,
              shadowColor: AppColors.onSecondaryFixed,
              fullWidth: true,
              onPressed: () {
                final fullAddress =
                    '${_addressController.text}, ${_cityController.text} ${_zipController.text}';
                appState.checkoutCurrentCart(fullAddress);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderSuccessScreen(),
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

  Widget _paymentOptionTile(String title, IconData icon) {
    final isSelected = _paymentMethod == title;

    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = title),
      child: NeoBrutalContainer(
        backgroundColor: isSelected
            ? AppColors.secondaryFixed
            : AppColors.surfaceContainerLowest,
        borderColor: AppColors.onSecondaryFixed,
        shadowColor: AppColors.onSecondaryFixed,
        shadowOffset: const Offset(2.5, 2.5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.onSecondaryFixed
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: AppTypography.labelBold(
                color: isSelected
                    ? AppColors.onSecondaryFixed
                    : AppColors.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: AppColors.onSecondaryFixed,
            ),
          ],
        ),
      ),
    );
  }
}
