import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../widgets/custom_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Center(
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
                child: const Icon(
                  Icons.person_outline,
                  size: 60,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'profile_coming_soon'.tr,
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'profile_feature_description'.tr,
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
      ),
    );
  }
}