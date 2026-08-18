import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';
import '../../providers/app_state.dart';
import '../customer/about_screen.dart';
import '../customer/account_settings_screen.dart';
import '../customer/contact_faq_screen.dart';
import '../customer/order_history_screen.dart';

class OwsxiNavigationDrawer extends StatelessWidget {
  final Function(Widget screen, String title)? onNavigate;

  const OwsxiNavigationDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Branding
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                border: Border(
                  bottom: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OWSXI',
                        style: AppTypography.displayLarge(color: AppColors.onPrimary).copyWith(
                          fontSize: 32,
                        ),
                      ),
                      const NeoBrutalBadge(
                        label: 'V1.0.0',
                        backgroundColor: AppColors.tertiaryFixed,
                        textColor: AppColors.onTertiaryFixed,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nostalgic Art for Modern Souls',
                    style: AppTypography.labelSmall(color: AppColors.onPrimaryContainer),
                  ),
                ],
              ),
            ),

            // Navigation Links List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: _buildCustomerItems(context, appState),
              ),
            ),

            // Footer / Log Out (Matching Stitch mobile_navigation_drawer spec)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.onSecondaryFixed, width: 3),
                ),
              ),
              child: Column(
                children: [
                  if (appState.isLoggedIn) ...[
                    NeoBrutalButton(
                      label: 'LOG OUT',
                      icon: Icons.logout,
                      backgroundColor: AppColors.primaryContainer,
                      textColor: AppColors.onPrimary,
                      shadowColor: AppColors.onSecondaryFixed,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.pop(context);
                        appState.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.onSecondaryFixed,
                            content: Text(
                              'LOGGED OUT SUCCESSFULLY',
                              style: AppTypography.labelBold(color: AppColors.onPrimary),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Neo-Nostalgia Brutalism Theme',
                        style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCustomerItems(BuildContext context, AppState appState) {
    return [
      _drawerTile(
        context: context,
        icon: Icons.storefront_outlined,
        label: 'Storefront Home',
        selected: appState.currentCustomerIndex == 0,
        onTap: () {
          appState.setCustomerIndex(0);
          Navigator.pop(context);
        },
      ),
      _drawerTile(
        context: context,
        icon: Icons.grid_view_outlined,
        label: 'Shop All Catalog',
        selected: appState.currentCustomerIndex == 1,
        onTap: () {
          appState.setCustomerIndex(1);
          Navigator.pop(context);
        },
      ),
      _drawerTile(
        context: context,
        icon: Icons.shopping_cart_outlined,
        label: 'Scrapbook Cart (${appState.cartItems.length})',
        selected: appState.currentCustomerIndex == 2,
        onTap: () {
          appState.setCustomerIndex(2);
          Navigator.pop(context);
        },
      ),
      _drawerTile(
        context: context,
        icon: Icons.favorite_border,
        label: 'My Wishlist (${appState.wishlistProductIds.length})',
        selected: appState.currentCustomerIndex == 3,
        onTap: () {
          appState.setCustomerIndex(3);
          Navigator.pop(context);
        },
      ),
      _drawerTile(
        context: context,
        icon: Icons.person_outline,
        label: 'Account Dashboard',
        selected: appState.currentCustomerIndex == 3,
        onTap: () {
          appState.setCustomerIndex(3);
          Navigator.pop(context);
        },
      ),
      const Divider(height: 24, thickness: 2, color: AppColors.onSecondaryFixed),
      _drawerTile(
        context: context,
        icon: Icons.settings_outlined,
        label: 'Account Settings',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AccountSettingsScreen(),
            ),
          );
        },
      ),
      _drawerTile(
        context: context,
        icon: Icons.local_shipping_outlined,
        label: 'Order History & Tracking',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderHistoryScreen(),
            ),
          );
        },
      ),
      _drawerTile(
        context: context,
        icon: Icons.quiz_outlined,
        label: 'Contact Us & FAQ',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ContactFaqScreen(),
            ),
          );
        },
      ),
      _drawerTile(
        context: context,
        icon: Icons.info_outline,
        label: 'About Owsxi Studio',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AboutScreen(),
            ),
          );
        },
      ),
    ];
  }

  Widget _drawerTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AppColors.secondaryContainer : Colors.transparent,
        border: selected
            ? Border.all(color: AppColors.onSecondaryFixed, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? AppColors.onSecondaryFixed : AppColors.onSurface,
        ),
        title: Text(
          label.toUpperCase(),
          style: AppTypography.labelBold(
            color: selected ? AppColors.onSecondaryFixed : AppColors.onSurface,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

