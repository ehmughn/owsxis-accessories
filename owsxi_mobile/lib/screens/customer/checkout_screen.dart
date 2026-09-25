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
  final _nameController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _zipController = TextEditingController();

  String _deliveryMethod = 'Shipping';
  final String _paymentMethod = 'Cash on Delivery';
  bool _isSubmitting = false;
  bool _initializedAddress = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedAddress) {
      _initializedAddress = true;
      final appState = Provider.of<AppState>(context, listen: false);

      _nameController.text = appState.userName.isNotEmpty ? appState.userName : 'Customer';
      final addr = appState.userAddress;
      _address1Controller.text = addr['address1'] ?? '';
      _address2Controller.text = addr['address2'] ?? '';
      _cityController.text = addr['city'] ?? '';
      _provinceController.text = addr['province'] ?? '';
      _zipController.text = addr['zip'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder(AppState appState) async {
    if (_nameController.text.trim().isEmpty ||
        _address1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your full name, street address, and city.'),
          backgroundColor: AppColors.errorContainer,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await appState.placeShopifyOrder(
      name: _nameController.text.trim(),
      address1: _address1Controller.text.trim(),
      address2: _address2Controller.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim(),
      zip: _zipController.text.trim(),
      paymentMethod: _paymentMethod,
      deliveryMethod: _deliveryMethod,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OrderSuccessScreen(),
        ),
      );
    } else {
      final msg = result['message']?.toString() ?? 'Failed to place order.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.errorContainer,
        ),
      );
    }
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
          'CHECKOUT',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Method Section
            _buildDeliveryMethodSection(),

            const SizedBox(height: 28),

            // Shipping Address Section
            Text(
              '2. SHIPPING ADDRESS',
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
              controller: _address1Controller,
            ),
            const SizedBox(height: 12),
            NeoBrutalTextField(
              label: 'Apartment / Suite (Optional)',
              controller: _address2Controller,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NeoBrutalTextField(
                    label: 'City',
                    controller: _cityController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoBrutalTextField(
                    label: 'Province / State',
                    controller: _provinceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NeoBrutalTextField(
              label: 'ZIP Code',
              controller: _zipController,
            ),

            const SizedBox(height: 28),

            // Payment Method Section
            Text(
              '3. PAYMENT METHOD',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            _buildCashOnDeliveryTile(),
            const SizedBox(height: 10),
            _buildDisabledPayMongoTile(),

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
                        '₱${appState.cartTotal.toStringAsFixed(2)}',
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
            if (_isSubmitting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.primaryContainer),
                ),
              )
            else
              NeoBrutalButton(
                label: 'PLACE ORDER NOW',
                icon: Icons.check_circle_outline,
                backgroundColor: AppColors.primaryContainer,
                textColor: AppColors.onPrimary,
                shadowColor: AppColors.onSecondaryFixed,
                fullWidth: true,
                onPressed: () => _handlePlaceOrder(appState),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. DELIVERY METHOD',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: 12),
        _buildDeliveryOptionTile(
          title: 'SHIPPING',
          subtitle: 'Standard delivery to your shipping address',
          icon: Icons.local_shipping_outlined,
          value: 'Shipping',
        ),
        const SizedBox(height: 10),
        _buildDeliveryOptionTile(
          title: 'PICKUP IN STORE',
          subtitle: 'Collect directly from physical store location',
          icon: Icons.storefront_outlined,
          value: 'Pickup in store',
        ),
      ],
    );
  }

  Widget _buildDeliveryOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _deliveryMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _deliveryMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: NeoBrutalContainer(
        backgroundColor: isSelected ? AppColors.secondaryFixed : AppColors.surfaceContainerHigh,
        borderColor: isSelected ? AppColors.onSecondaryFixed : AppColors.outlineVariant,
        shadowColor: isSelected ? AppColors.onSecondaryFixed : Colors.transparent,
        shadowOffset: isSelected ? const Offset(2.5, 2.5) : Offset.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.onSecondaryFixed : AppColors.outline,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelBold(
                      color: isSelected ? AppColors.onSecondaryFixed : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall(
                      color: isSelected ? AppColors.onSecondaryFixed : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.onSecondaryFixed : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOnDeliveryTile() {
    return NeoBrutalContainer(
      backgroundColor: AppColors.secondaryFixed,
      borderColor: AppColors.onSecondaryFixed,
      shadowColor: AppColors.onSecondaryFixed,
      shadowOffset: const Offset(2.5, 2.5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: AppColors.onSecondaryFixed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CASH ON DELIVERY',
                  style: AppTypography.labelBold(
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pay upon package delivery',
                  style: AppTypography.bodySmall(
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.radio_button_checked,
            color: AppColors.onSecondaryFixed,
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledPayMongoTile() {
    return Opacity(
      opacity: 0.55,
      child: NeoBrutalContainer(
        backgroundColor: AppColors.surfaceContainerHigh,
        borderColor: AppColors.outlineVariant,
        shadowColor: Colors.transparent,
        shadowOffset: Offset.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            const Icon(
              Icons.credit_card_off_outlined,
              color: AppColors.outline,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECURE PAYMENT VIA PAYMONGO',
                    style: AppTypography.labelBold(
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Disabled / Unavailable',
                    style: AppTypography.bodySmall(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            const NeoBrutalBadge(
              label: 'DISABLED',
              backgroundColor: AppColors.surfaceContainerLowest,
              textColor: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
