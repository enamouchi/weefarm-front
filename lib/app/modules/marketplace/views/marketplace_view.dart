import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../controllers/marketplace_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/custom_search_bar.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../routes/app_routes.dart';

class MarketplaceView extends GetView<MarketplaceController> {
  const MarketplaceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            _buildCategoriesSection(),
            Expanded(child: _buildProductsGrid()),
          ],
        ),
      ),
      floatingActionButton: Obx(() => 
        controller.authController.isFarmer
            ? FloatingActionButton(
                onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
                backgroundColor: AppColors.primaryGreen,
                child: const Icon(Icons.add, color: AppColors.white),
              )
            : const SizedBox(),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          Text(
            'marketplace'.tr,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.location_on, color: AppColors.primaryGreen),
            onPressed: controller.showLocationFilter,
          ),
          IconButton(
            icon: const Icon(Icons.grid_view, color: AppColors.black),
            onPressed: controller.toggleViewMode,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: CustomSearchBar(
              hintText: 'search_products'.tr,
              onChanged: controller.searchProducts,
              onSubmitted: controller.searchProducts,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.filter_list, color: AppColors.darkGray),
                  Obx(() => controller.hasActiveFilters.value
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : const SizedBox()),
                ],
              ),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoriesSection() {
    return Container(
      height: 50,
      color: AppColors.white,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategory.value == category.value;
          
          return Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                controller.selectCategory(selected ? category.value : null);
              },
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.lightGray,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.darkGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      )),
    );
  }
  
  Widget _buildProductsGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return _buildLoadingGrid();
      }
      
      if (controller.products.isEmpty) {
        return _buildEmptyState();
      }
      
      return RefreshIndicator(
        onRefresh: controller.refreshProducts,
        color: AppColors.primaryGreen,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter == 0) {
              controller.loadMoreProducts();
            }
            return false;
          },
          child: Obx(() => controller.isGridView.value
              ? _buildGridView()
              : _buildListView()),
        ),
      );
    });
  }
  
  Widget _buildGridView() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: controller.products.length + (controller.isLoadingMore.value ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= controller.products.length) {
          return const ProductCardShimmer();
        }
        
        final product = controller.products[index];
        return ProductCard(
          product: product,
          onTap: () => Get.toNamed(
            Routes.PRODUCT_DETAILS,
            arguments: product,
          ),
          onFavorite: () => controller.toggleFavorite(product),
        );
      },
    );
  }
  
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.products.length + (controller.isLoadingMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= controller.products.length) {
          return const ProductCardShimmer(isListView: true);
        }
        
        final product = controller.products[index];
        return ProductCard(
          product: product,
          isListView: true,
          onTap: () => Get.toNamed(
            Routes.PRODUCT_DETAILS,
            arguments: product,
          ),
          onFavorite: () => controller.toggleFavorite(product),
        );
      },
    );
  }
  
  Widget _buildLoadingGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardShimmer(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.mediumGray,
            ),
            const SizedBox(height: 24),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'no_products_found'.tr
                  : 'no_products_available'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'try_different_search'.tr
                  : 'check_back_later'.tr,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (controller.hasActiveFilters.value)
              ElevatedButton(
                onPressed: controller.clearFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                ),
                child: Text('clear_filters'.tr),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showFilterBottomSheet() {
    Get.bottomSheet(
      FilterBottomSheet(
        onFiltersApplied: (filters) {
          controller.applyFilters(filters);
          Get.back();
        },
        currentFilters: controller.currentFilters.value,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}