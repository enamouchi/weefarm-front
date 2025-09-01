// lib/app/modules/marketplace/controllers/marketplace_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as _apiService;
import '../../../core/services/api_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/product_filters.dart';
import '../../../core/values/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';

class MarketplaceController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Get auth controller for farmer check
  AuthController get authController => Get.find<AuthController>();
  
  // Observable states
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ProductFilters> currentFilters = ProductFilters().obs;
  final RxBool isGridView = true.obs;
  
  // CORRECTION : Utilisez Rx<String?> au lieu de RxString?
  final Rx<String?> selectedCategory = Rx<String?>(null);
  
  // Categories list
  final RxList<CategoryItem> categories = <CategoryItem>[
    CategoryItem(name: 'all'.tr, value: null),
    CategoryItem(name: 'vegetables'.tr, value: 'vegetables'),
    CategoryItem(name: 'fruits'.tr, value: 'fruits'),
    CategoryItem(name: 'cereals'.tr, value: 'cereals'),
    CategoryItem(name: 'dairy'.tr, value: 'dairy'),
    CategoryItem(name: 'meat'.tr, value: 'meat'),
    CategoryItem(name: 'organic'.tr, value: 'organic'),
  ].obs;
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // CORRECTION : Computed properties avec getter
  RxBool get hasActiveFilters => 
    (!currentFilters.value.isEmpty || selectedCategory.value != null).obs;
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  // Load products with current filters and search
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      products.clear();
    }
    
    if (!hasMoreData.value || isLoading.value) return;
    
    try {
      if (refresh || products.isEmpty) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      
      final queryParams = <String, dynamic>{
        'page': currentPage.value.toString(),
        'limit': itemsPerPage.toString(),
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedCategory.value != null) 'category': selectedCategory.value,
        ...currentFilters.value.toMap(),
      };
      
      final response = await _apiService.get(
        '/products',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['products'] ?? [];
        final List<ProductModel> newProducts = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();
        
        if (refresh || products.isEmpty) {
          products.assignAll(newProducts);
        } else {
          products.addAll(newProducts);
        }
        
        // Check if there are more pages
        final totalPages = response.data['totalPages'] ?? 1;
        hasMoreData.value = currentPage.value < totalPages;
        
        if (hasMoreData.value) {
          currentPage.value++;
        }
      }
    } catch (e) {
      print('Error loading products: $e');
      Get.snackbar(
        'error'.tr, 
        'failed_to_load_products'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
  
  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    loadProducts(refresh: true);
  }
  
  // Select category
  void selectCategory(String? category) {
    selectedCategory.value = category;
    loadProducts(refresh: true);
  }
  
  // Apply filters
  void applyFilters(ProductFilters filters) {
    currentFilters.value = filters;
    loadProducts(refresh: true);
  }
  
  // Clear filters
  void clearFilters() {
    currentFilters.value = ProductFilters();
    selectedCategory.value = null;
    searchQuery.value = '';
    loadProducts(refresh: true);
  }
  
  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }
  
  // Load more products (for pagination)
  Future<void> loadMoreProducts() async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await loadProducts();
    }
  }
  
  // Toggle view mode (grid/list)
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }
  
  // Show location filter
  void showLocationFilter() {
    // TODO: Implement location-based filtering
    Get.snackbar(
      'info'.tr,
      'location_filter_coming_soon'.tr,
      backgroundColor: AppColors.primaryGreen,
      colorText: AppColors.white,
    );
  }
  
  // Toggle favorite product
  void toggleFavorite(ProductModel product) async {
    try {
      if (!authController.isLoggedIn.value) {
        Get.snackbar(
          'login_required'.tr,
          'login_to_add_favorites'.tr,
          backgroundColor: AppColors.warning,
          colorText: AppColors.white,
        );
        return;
      }
      
      final response = await _apiService.post(
        '/products/${product.id}/toggle-favorite',
      );
      
      if (response.statusCode == 200) {
        // Update the product in the list
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          final updatedProduct = product.copyWith(
            isFavorited: !product.isFavorited,
          );
          products[index] = updatedProduct;
        }
        
        Get.snackbar(
          'success'.tr,
          product.isFavorited 
              ? 'removed_from_favorites'.tr 
              : 'added_to_favorites'.tr,
          backgroundColor: AppColors.primaryGreen,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_update_favorites'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }
}

// Category item model
class CategoryItem {
  final String name;
  final String? value;
  
  CategoryItem({
    required this.name,
    this.value,
  });
}