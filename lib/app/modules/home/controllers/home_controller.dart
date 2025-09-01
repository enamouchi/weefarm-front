import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import 'package:weefarm/app/core/services/api_service.dart';
import 'package:weefarm/app/data/models/user_model.dart';
import 'package:weefarm/app/modules/auth/controllers/auth_controller.dart';
import 'package:weefarm/app/core/values/app_colors.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController authController = Get.find<AuthController>();
  
  // Observable states
  final RxInt unreadNotificationsCount = 0.obs;
  final RxList<FeedPost> feedPosts = <FeedPost>[].obs;
  final RxBool isLoadingFeed = false.obs;
  final Rx<FarmerStats> farmerStats = FarmerStats().obs;
  final Rx<CustomerStats> customerStats = CustomerStats().obs;
  
  // Current user getter
  Rx<UserModel?> get currentUser => authController.currentUser;
  
  @override
  void onInit() {
    super.onInit();
    _loadHomeData();
  }
  
  // Load all home data
  Future<void> _loadHomeData() async {
    await Future.wait([
      _loadFeedPosts(),
      _loadStats(),
      _loadNotificationCount(),
    ]);
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    await _loadHomeData();
  }
  
  // Load feed posts preview
  Future<void> _loadFeedPosts() async {
    try {
      isLoadingFeed.value = true;
      
      final response = await _apiService.get('/feed', queryParameters: {
        'page': '1',
        'limit': '3', // Only show 3 posts on home
      });
      
      if (response.statusCode == 200) {
        final posts = (response.data['posts'] as List)
            .map((post) => FeedPost.fromJson(post))
            .toList();
        feedPosts.assignAll(posts);
      }
    } catch (e) {
      // Silent error for feed loading
      print('Error loading feed: $e');
    } finally {
      isLoadingFeed.value = false;
    }
  }
  
  // Load user statistics
  Future<void> _loadStats() async {
    try {
      if (currentUser.value?.isFarmer == true) {
        await _loadFarmerStats();
      } else {
        await _loadCustomerStats();
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }
  
  // Load farmer statistics
  Future<void> _loadFarmerStats() async {
    try {
      final response = await _apiService.get('/users/me');
      
      if (response.statusCode == 200 && response.data['statistics'] != null) {
        farmerStats.value = FarmerStats.fromJson(response.data['statistics']);
      }
    } catch (e) {
      print('Error loading farmer stats: $e');
    }
  }
  
  // Load customer statistics  
  Future<void> _loadCustomerStats() async {
    try {
      final response = await _apiService.get('/users/me');
      
      if (response.statusCode == 200 && response.data['statistics'] != null) {
        customerStats.value = CustomerStats.fromJson(response.data['statistics']);
      }
    } catch (e) {
      print('Error loading customer stats: $e');
    }
  }
  
  // Load notification count
  Future<void> _loadNotificationCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');
      
      if (response.statusCode == 200) {
        unreadNotificationsCount.value = response.data['unreadCount'] ?? 0;
      }
    } catch (e) {
      // Silent error for notification count
      print('Error loading notification count: $e');
    }
  }
  
  // Get welcome message based on time
  String getWelcomeMessage() {
    final hour = DateTime.now().hour;
    
    String greeting;
    if (hour < 12) {
      greeting = 'good_morning'.tr;
    } else if (hour < 17) {
      greeting = 'good_afternoon'.tr;
    } else {
      greeting = 'good_evening'.tr;
    }
    
    if (currentUser.value?.isFarmer == true) {
      return '$greeting! ${'farmer_welcome_message'.tr}';
    } else {
      return '$greeting! ${'customer_welcome_message'.tr}';
    }
  }
  
  // Find nearby products using GPS
  Future<void> findNearbyProducts() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'error'.tr,
            'location_permission_denied'.tr,
            backgroundColor: AppColors.error,
            colorText: AppColors.white,
          );
          return;
        }
      }
      
      Get.toNamed('/marketplace');
      
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_get_location'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }
}

// Simple data models
class FarmerStats {
  final int totalProducts;
  final int activeProducts;
  final int totalOrders;
  final double totalRevenue;
  
  FarmerStats({
    this.totalProducts = 0,
    this.activeProducts = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
  });
  
  factory FarmerStats.fromJson(Map<String, dynamic> json) {
    return FarmerStats(
      totalProducts: json['totalProducts'] ?? 0,
      activeProducts: json['activeProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

class CustomerStats {
  final int totalOrders;
  final int favoriteProducts;
  final double totalSpent;
  
  CustomerStats({
    this.totalOrders = 0,
    this.favoriteProducts = 0,
    this.totalSpent = 0.0,
  });
  
  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      totalOrders: json['totalOrders'] ?? 0,
      favoriteProducts: json['favoriteProducts'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
    );
  }
}

class FeedPost {
  final int id;
  final String title;
  final String body;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final FeedAuthor author;
  
  FeedPost({
    required this.id,
    required this.title,
    required this.body,
    required this.images,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    required this.author,
  });
  
  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      author: FeedAuthor.fromJson(json['author'] ?? {}),
    );
  }
}

class FeedAuthor {
  final int id;
  final String name;
  final String? avatar;
  
  FeedAuthor({
    required this.id,
    required this.name,
    this.avatar,
  });
  
  factory FeedAuthor.fromJson(Map<String, dynamic> json) {
    return FeedAuthor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}