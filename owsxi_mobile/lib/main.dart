import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/neo_brutal_widgets.dart';
import 'providers/app_state.dart';
import 'screens/common/navigation_drawer.dart';
import 'screens/customer/storefront_home_screen.dart';
import 'screens/customer/catalog_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/customer_account_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/inventory_management_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/customer_directory_screen.dart';
import 'screens/admin/store_settings_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const OwsxiMobileApp(),
    ),
  );
}

class OwsxiMobileApp extends StatelessWidget {
  const OwsxiMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OWSXI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        useMaterial3: true,
      ),
      home: const OwsxiMainShell(),
    );
  }
}

class OwsxiMainShell extends StatelessWidget {
  const OwsxiMainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    Widget currentBody;
    if (appState.isAdminMode) {
      switch (appState.currentAdminIndex) {
        case 0:
          currentBody = const AdminDashboardScreen();
          break;
        case 1:
          currentBody = const InventoryManagementScreen();
          break;
        case 2:
          currentBody = const AdminOrdersScreen();
          break;
        case 3:
          currentBody = const CustomerDirectoryScreen();
          break;
        case 4:
          currentBody = const StoreSettingsScreen();
          break;
        default:
          currentBody = const AdminDashboardScreen();
      }
    } else {
      switch (appState.currentCustomerIndex) {
        case 0:
          currentBody = StorefrontHomeScreen(
            onNavigateToCatalog: () => appState.setCustomerIndex(1),
          );
          break;
        case 1:
          currentBody = const CatalogScreen();
          break;
        case 2:
          currentBody = const CartScreen();
          break;
        case 3:
          currentBody = const CustomerAccountScreen();
          break;
        default:
          currentBody = StorefrontHomeScreen(
            onNavigateToCatalog: () => appState.setCustomerIndex(1),
          );
      }
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const OwsxiNavigationDrawer(),

      // Exact Stitch Header TopAppBar
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            color: AppColors.onSecondaryFixed,
            height: 4,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.onSurface, size: 28),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OWSXI',
              style: AppTypography.displayLarge(color: AppColors.primaryContainer)
                  .copyWith(fontSize: 26, letterSpacing: -1),
            ),
            const SizedBox(width: 8),
            NeoBrutalBadge(
              label: appState.isAdminMode ? 'ADMIN' : 'STUDIO',
              backgroundColor: appState.isAdminMode
                  ? AppColors.primaryContainer
                  : AppColors.tertiaryFixed,
              textColor: appState.isAdminMode
                  ? AppColors.onPrimary
                  : AppColors.onTertiaryFixed,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (!appState.isAdminMode) ...[
            IconButton(
              icon: const Icon(
                Icons.search,
                color: AppColors.onSurface,
                size: 26,
              ),
              onPressed: () => appState.setCustomerIndex(1),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(
                Icons.swap_horiz,
                color: AppColors.onSurface,
              ),
              tooltip: 'Switch View Mode',
              onPressed: () => appState.toggleAdminMode(),
            ),
          ],
        ],
      ),

      // Page Body wrapped in Retro 24px Grid Pattern
      body: GridBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: currentBody,
        ),
      ),

      // Exact Stitch Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.onSecondaryFixed, width: 4),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: appState.isAdminMode
              ? appState.currentAdminIndex
              : appState.currentCustomerIndex,
          onTap: (index) {
            if (appState.isAdminMode) {
              appState.setAdminIndex(index);
            } else {
              appState.setCustomerIndex(index);
            }
          },
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.onTertiaryContainer,
          unselectedItemColor: AppColors.onSurfaceVariant,
          selectedLabelStyle: AppTypography.labelSmall(
            color: AppColors.onTertiaryContainer,
          ).copyWith(fontWeight: FontWeight.w900),
          unselectedLabelStyle: AppTypography.labelSmall(
            color: AppColors.onSurfaceVariant,
          ),
          type: BottomNavigationBarType.fixed,
          items: appState.isAdminMode
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined),
                    activeIcon: Icon(Icons.inventory_2),
                    label: 'Inventory',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_outlined),
                    activeIcon: Icon(Icons.shopping_cart),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group_outlined),
                    activeIcon: Icon(Icons.group),
                    label: 'Customers',
                  ),
                ]
              : [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'HOME',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag_outlined),
                    activeIcon: Icon(Icons.shopping_bag),
                    label: 'SHOP',
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart_outlined),
                        if (appState.cartItems.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.rectangle,
                              ),
                              child: Text(
                                '${appState.cartItems.length}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    activeIcon: const Icon(Icons.shopping_cart),
                    label: 'CART',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'ACCOUNT',
                  ),
                ],
        ),
      ),
    );
  }
}
