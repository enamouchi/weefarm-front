// 1. lib/modules/dashboard/controllers/smart_dashboard_controller.dart
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
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.get('/analytics/dashboard');
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        // Parse stats
        final statsData = data['stats'] as Map<String, dynamic>? ?? {};
        stats.value = DashboardStats.fromJson(statsData);
        
        // Parse insights
        final insightsData = data['insights'] as List?;
        if (insightsData != null) {
          insights.value = insightsData.map((item) => item.toString()).toList();
        }
        
        // Parse weekly data
        final chartsData = data['charts'] as Map<String, dynamic>?;
        final weeklyRevenue = chartsData?['weeklyRevenue'] as List?;
        
        if (weeklyRevenue != null) {
          weeklyData.value = weeklyRevenue
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
        
        print('Dashboard loaded: ${stats.value.completedOrders} orders');
      }
      
    } catch (e) {
      print('Dashboard error: $e');
      Get.snackbar(
        'تحميل البيانات التجريبية',
        'سيتم عرض بيانات تجريبية للمراجعة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onSecondary,
      );
      _loadDemoData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDemoData() {
    stats.value = DashboardStats(
      completedOrders: 28,
      pendingOrders: 4,
      totalProducts: 15,
      revenue: 2845.50,
    );
    
    insights.value = [
      'مرحبا بك في WeeFarm - السوق الزراعي التونسي الذكي!',
      'معدل إتمام الطلبات ممتاز: 87.5%',
      'منتجاتك الزراعية تحقق إقبالا جيدا من المشترين',
      'نصيحة: راجع أسعارك مع الأسعار السائدة في السوق',
    ];
    
    weeklyData.value = [
      {'_id': 1, 'revenue': 420.75, 'orders': 6},
      {'_id': 2, 'revenue': 385.50, 'orders': 5},
      {'_id': 3, 'revenue': 512.25, 'orders': 8},
      {'_id': 4, 'revenue': 298.00, 'orders': 4},
      {'_id': 5, 'revenue': 645.75, 'orders': 9},
      {'_id': 6, 'revenue': 378.25, 'orders': 6},
      {'_id': 7, 'revenue': 205.00, 'orders': 3},
    ];
  }

  List<FlSpot> getChartSpots() {
    if (weeklyData.isEmpty) return [];
    
    return weeklyData.asMap().entries.map((entry) {
      final revenue = entry.value['revenue'];
      double revenueValue = 0.0;
      
      if (revenue is num) {
        revenueValue = revenue.toDouble();
      } else if (revenue is String) {
        revenueValue = double.tryParse(revenue) ?? 0.0;
      }
      
      return FlSpot(entry.key.toDouble(), revenueValue);
    }).toList();
  }

  Future<void> onRefresh() async => await refreshData();
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
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double get completionRate {
    final total = completedOrders + pendingOrders;
    if (total == 0) return 0.0;
    return (completedOrders / total) * 100;
  }

  String get formattedRevenue => '${revenue.toStringAsFixed(2)} د.ت';
}