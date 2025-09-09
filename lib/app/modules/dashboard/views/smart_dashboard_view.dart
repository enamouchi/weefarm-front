import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/smart_dashboard_controller.dart';

class SmartDashboardView extends StatelessWidget {
  final controller = Get.put(SmartDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم الذكية'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshData,
          )
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? _buildLoadingView()
          : RefreshIndicator(
              onRefresh: controller.onRefresh,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInsightsCard(),
                    SizedBox(height: 16),
                    _buildStatsGrid(),
                    SizedBox(height: 16),
                    _buildRevenueChart(),
                    SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
            )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/ai-assistant'),
        icon: Icon(Icons.smart_toy),
        label: Text('المساعد الذكي'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green[700]),
          SizedBox(height: 16),
          Text('جاري تحليل البيانات...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[700], size: 24),
                SizedBox(width: 8),
                Text('نصائح ذكية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            ...controller.insights.map((insight) => 
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text(insight, style: TextStyle(fontSize: 14))),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'الطلبات المكتملة', 
          '${controller.stats.value.completedOrders}', 
          Icons.check_circle, 
          Colors.green
        ),
        _buildStatCard(
          'الطلبات المعلقة', 
          '${controller.stats.value.pendingOrders}', 
          Icons.pending, 
          Colors.orange
        ),
        _buildStatCard(
          'إجمالي المنتجات', 
          '${controller.stats.value.totalProducts}', 
          Icons.inventory, 
          Colors.blue
        ),
        _buildStatCard(
          'الإيرادات', 
          controller.stats.value.formattedRevenue, 
          Icons.money, 
          Colors.purple
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإيرادات الأسبوعية', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.getChartSpots(),
                      isCurved: true,
                      color: Colors.green[700],
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green[700]!.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إجراءات سريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('المساعد الذكي', Icons.smart_toy, () => Get.toNamed('/ai-assistant')),
                _buildActionButton('تحليل النباتات', Icons.camera_alt, () => Get.toNamed('/plant-scanner')),
                _buildActionButton('الطلبات', Icons.shopping_cart, () => Get.toNamed('/orders')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green[700], size: 28),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}