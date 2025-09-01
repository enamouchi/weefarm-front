import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../widgets/custom_button.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('my_orders'.tr),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _buildPlaceholder(
        icon: Icons.receipt_long,
        title: 'orders_coming_soon'.tr,
        description: 'orders_feature_description'.tr,
      ),
    );
  }
}

Widget _buildPlaceholder({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.mediumGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomButton.outline(
            text: 'go_back'.tr,
            onPressed: () => Get.back(),
            width: 200,
          ),
        ],
      ),
    ),
  );
}