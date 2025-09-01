import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../home//views/home_view.dart';
import '../../marketplace/views/marketplace_view.dart';
import '../../../modules/orders/views/orders_view.dart';
import '../../../modules/chat/views/conversations_view.dart';
import '../../../modules/profile/views/profile_view.dart';

class MainView extends GetView<MainController> {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: [ // Supprimez 'const' ici
          const HomeView(),
          const MarketplaceView(),
          const OrdersView(),
          const ConversationsView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    ));
  }
  
  Widget _buildBottomNavigationBar() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'home'.tr,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront,
                label: 'marketplace'.tr,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'my_orders'.tr,
                badgeCount: controller.pendingOrdersCount.value,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'chat'.tr,
                badgeCount: controller.unreadMessagesCount.value,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'profile'.tr,
              ),
            ],
          ),
        ),
      ),
    ));
  }
  
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
  }) {
    final isActive = controller.currentIndex.value == index;
    
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? AppColors.primaryGreen.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? AppColors.primaryGreen : AppColors.mediumGray,
                    size: 24,
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryGreen : AppColors.mediumGray,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt pendingOrdersCount = 0.obs;
  final RxInt unreadMessagesCount = 0.obs;
  final RxInt unreadNotificationsCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadCounts();
  }
  
  void changePage(int index) {
    currentIndex.value = index;
  }
  
  void goToHome() => changePage(0);
  void goToMarketplace() => changePage(1);
  void goToOrders() => changePage(2);
  void goToChat() => changePage(3);
  void goToProfile() => changePage(4);
  
  Future<void> _loadCounts() async {
    // Load pending orders count
    // Load unread messages count
    // Load unread notifications count
    // This will be implemented when we create the respective controllers
  }
  
  void updatePendingOrdersCount(int count) {
    pendingOrdersCount.value = count;
  }
  
  void updateUnreadMessagesCount(int count) {
    unreadMessagesCount.value = count;
  }
  
  void updateUnreadNotificationsCount(int count) {
    unreadNotificationsCount.value = count;
  }
}