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
        title: Text('لوحة التحكم الذكية 📊'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshData,
          )
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.refreshData,
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

  Widget _buildInsightsCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange),
                SizedBox(width: 8),
                Text('نصائح ذكية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            ...controller.insights.map((insight) => 
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('• $insight', style: TextStyle(fontSize: 14)),
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
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('الطلبات المكتملة', '${controller.stats.value.completedOrders}', 
            Icons.check_circle, Colors.green),
        _buildStatCard('الطلبات المعلقة', '${controller.stats.value.pendingOrders}', 
            Icons.pending, Colors.orange),
        _buildStatCard('إجمالي المنتجات', '${controller.stats.value.totalProducts}', 
            Icons.inventory, Colors.blue),
        _buildStatCard('الإيرادات', '${controller.stats.value.revenue.toStringAsFixed(1)} د.ت', 
            Icons.money, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإيرادات الأسبوعية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.getChartSpots(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}