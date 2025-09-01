import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:weefarm/app/core/values/app_colors.dart';
import 'package:weefarm/app/widgets/custom_button.dart';
import 'package:weefarm/app/widgets/feed_card.dart';
import 'package:weefarm/app/widgets/loading_shimmer.dart';
import 'package:weefarm/app/routes/app_routes.dart';
import 'package:weefarm/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primaryGreen,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildWelcomeSection(),
              _buildQuickActions(),
              _buildStatsSection(),
              _buildFeedSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      floating: true,
      pinned: false,
      title: Row(
        children: [
          // WeeFarm Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'WF',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'app_name'.tr,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                'tunisian_marketplace'.tr,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.black,
              ),
              Obx(() => controller.unreadNotificationsCount.value > 0
                  ? Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : const SizedBox()),
            ],
          ),
          onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.secondaryGreen,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'welcome_back'.tr}, ${controller.currentUser.value?.name ?? ''}!',
              style: Get.textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.getWelcomeMessage(),
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            if (controller.currentUser.value?.isFarmer == true)
              CustomButton.secondary(
                text: 'add_product'.tr,
                icon: const Icon(Icons.add, color: AppColors.white),
                onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
              ),
          ],
        )),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'quick_actions'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionButton(
                  icon: Icons.storefront,
                  label: 'browse_products'.tr,
                  backgroundColor: AppColors.primaryGreen,
                  onPressed: () => Get.toNamed(Routes.MARKETPLACE),
                ),
                ActionButton(
                  icon: Icons.build,
                  label: 'services'.tr,
                  backgroundColor: AppColors.accentTeal,
                  onPressed: () => Get.toNamed(Routes.SERVICES),
                ),
                ActionButton(
                  icon: Icons.chat,
                  label: 'messages'.tr,
                  backgroundColor: AppColors.darkTeal,
                  onPressed: () => Get.toNamed(Routes.CHAT),
                ),
                ActionButton(
                  icon: Icons.location_on,
                  label: 'nearby'.tr,
                  backgroundColor: AppColors.secondaryGreen,
                  onPressed: controller.findNearbyProducts,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Obx(() => controller.currentUser.value?.isFarmer == true
            ? _buildFarmerStats()
            : _buildCustomerStats()),
      ),
    );
  }
  
  Widget _buildFarmerStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'my_farm_stats'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
              children: [
                _buildStatItem(
                  title: 'products'.tr,
                  value: controller.farmerStats.value.totalProducts.toString(),
                  icon: Icons.inventory,
                  color: AppColors.primaryGreen,
                ),
                _buildStatItem(
                  title: 'orders'.tr,
                  value: controller.farmerStats.value.totalOrders.toString(),
                  icon: Icons.receipt,
                  color: AppColors.accentTeal,
                ),
                _buildStatItem(
                  title: 'revenue'.tr,
                  value: '${controller.farmerStats.value.totalRevenue.toStringAsFixed(0)} ${'tnd'.tr}',
                  icon: Icons.monetization_on,
                  color: AppColors.secondaryGreen,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomerStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'my_activity'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
              children: [
                _buildStatItem(
                  title: 'orders'.tr,
                  value: controller.customerStats.value.totalOrders.toString(),
                  icon: Icons.shopping_bag,
                  color: AppColors.primaryGreen,
                ),
                _buildStatItem(
                  title: 'favorites'.tr,
                  value: controller.customerStats.value.favoriteProducts.toString(),
                  icon: Icons.favorite,
                  color: AppColors.error,
                ),
                _buildStatItem(
                  title: 'saved'.tr,
                  value: '${controller.customerStats.value.totalSpent.toStringAsFixed(0)} ${'tnd'.tr}',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.accentTeal,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          Text(
            title,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeedSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'community_feed'.tr,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(Routes.FEED),
                  child: Text(
                    'view_all'.tr,
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoadingFeed.value) {
                return const LoadingShimmer();
              }
              
              if (controller.feedPosts.isEmpty) {
                return _buildEmptyFeed();
              }
              
              return Column(
                children: controller.feedPosts
                    .take(3) // Show only first 3 posts on home
                    .map((post) => FeedCard(post: post))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyFeed() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'no_posts_yet'.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          Text(
            'check_back_later'.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}
