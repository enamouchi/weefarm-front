import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/api_service.dart';

class SmartDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  var isLoading = true.obs;
  var stats = DashboardStats().obs;
  var insights = <String>[].obs;
  var weeklyData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    refreshData();
    super.onInit();
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      
      // FIXED: Using Dio - response.data contains the JSON directly
      final response = await _apiService.get('/analytics/dashboard');
      
      // FIXED: Get data from response.data (Dio way)
      final data = response.data as Map<String, dynamic>;
      
      print('🔍 Dashboard response: $data');
      
      // Parse stats
      final statsData = data['stats'] as Map<String, dynamic>? ?? {};
      stats.value = DashboardStats.fromJson(statsData);
      
      // Parse insights
      final insightsData = data['insights'] as List?;
      if (insightsData != null) {
        insights.value = insightsData.map((item) => item.toString()).toList();
      } else {
        insights.value = [];
      }
      
      // Parse weekly data
      final chartsData = data['charts'] as Map<String, dynamic>?;
      final weeklyRevenue = chartsData?['weeklyRevenue'] as List?;
      
      if (weeklyRevenue != null) {
        weeklyData.value = weeklyRevenue
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } else {
        weeklyData.value = [];
      }
      
      print('✅ Dashboard data loaded successfully');
      print('📊 Stats: ${stats.value.completedOrders} orders, ${stats.value.revenue} revenue');
      print('💡 Insights: ${insights.length} items');
      print('📈 Weekly data: ${weeklyData.length} points');
      
    } catch (e) {
      print('❌ Dashboard error: $e');
      
      Get.snackbar(
        'تحميل البيانات التجريبية', 
        'سيتم عرض بيانات تجريبية للعرض',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        duration: Duration(seconds: 3),
      );
      
      // Load demo data on error
      _loadDemoData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDemoData() {
    print('📋 Loading demo dashboard data...');
    
    stats.value = DashboardStats(
      completedOrders: 25,
      pendingOrders: 5,
      totalProducts: 12,
      revenue: 1250.50,
    );
    
    insights.value = [
      'مرحباً بك في لوحة التحكم الذكية! 📊',
      'بياناتك تظهر نشاطاً جيداً في المزرعة 🌱',
      'معدل إتمام الطلبات ممتاز! 🎉',
      'إيراداتك في نمو مستمر! 📈',
    ];
    
    weeklyData.value = [
      {'_id': 1, 'revenue': 120.0, 'orders': 3},
      {'_id': 2, 'revenue': 250.0, 'orders': 7},
      {'_id': 3, 'revenue': 180.0, 'orders': 4},
      {'_id': 4, 'revenue': 320.0, 'orders': 9},
      {'_id': 5, 'revenue': 290.0, 'orders': 8},
      {'_id': 6, 'revenue': 410.0, 'orders': 12},
      {'_id': 7, 'revenue': 380.0, 'orders': 10},
    ];
    
    print('✅ Demo data loaded successfully');
  }

  List<FlSpot> getChartSpots() {
    if (weeklyData.isEmpty) {
      print('⚠️ No weekly data for chart');
      return [];
    }
    
    final spots = weeklyData.asMap().entries.map((entry) {
      final revenue = entry.value['revenue'];
      double revenueValue = 0.0;
      
      if (revenue is int) {
        revenueValue = revenue.toDouble();
      } else if (revenue is double) {
        revenueValue = revenue;
      } else if (revenue is String) {
        revenueValue = double.tryParse(revenue) ?? 0.0;
      }
      
      return FlSpot(entry.key.toDouble(), revenueValue);
    }).toList();
    
    print('📈 Chart spots: ${spots.length} points');
    return spots;
  }

  // Manual refresh method for pull-to-refresh
  Future<void> onRefresh() async {
    await refreshData();
  }

  // Force demo data for testing
  void loadDemoData() {
    _loadDemoData();
  }
}

class DashboardStats {
  final int completedOrders;
  final int pendingOrders;
  final int totalProducts;
  final double revenue;

  DashboardStats({
    this.completedOrders = 0,
    this.pendingOrders = 0,
    this.totalProducts = 0,
    this.revenue = 0.0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      completedOrders: _parseInt(json['completedOrders']),
      pendingOrders: _parseInt(json['pendingOrders']),
      totalProducts: _parseInt(json['totalProducts']),
      revenue: _parseDouble(json['revenue']),
    );
  }
  
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'DashboardStats(completed: $completedOrders, pending: $pendingOrders, products: $totalProducts, revenue: $revenue)';
  }
}