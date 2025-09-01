import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('login'.tr),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              _buildHeader(),
              
              const SizedBox(height: 40),
              
              // WeeFarm Logo
              _buildLogo(),
              
              const SizedBox(height: 40),
              
              // Phone Field
              _buildPhoneField(),
              
              const SizedBox(height: 24),
              
              // Continue Button
              _buildContinueButton(),
              
              const SizedBox(height: 32),
              
              // Register Link
              _buildRegisterLink(),
              
              const SizedBox(height: 24),
              
              // Info Text
              _buildInfoText(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'welcome_back'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'enter_phone_to_continue'.tr,
          style: Get.textTheme.bodyLarge?.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'WF',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhoneTextField(
          controller: controller.phoneController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'field_required'.tr;
            }
            if (!controller.isValidTunisianPhone(value)) {
              return 'invalid_tunisia_phone'.tr;
            }
            return null;
          },
          onChanged: controller.formatPhoneNumber,
        ),
        const SizedBox(height: 8),
        Text(
          'phone_login_info'.tr,
          style: Get.textTheme.bodySmall?.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
  
  Widget _buildContinueButton() {
    return Obx(() => CustomButton.primary(
      text: 'continue'.tr,
      onPressed: controller.isLoading.value ? null : _handleContinue,
      isLoading: controller.isLoading.value,
      width: double.infinity,
      height: 56,
    ));
  }
  
  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'dont_have_account'.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.offNamed(Routes.REGISTER),
            child: Text(
              'create_account'.tr,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'otp_login_explanation'.tr,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleContinue() {
    if (controller.loginFormKey.currentState!.validate()) {
      controller.requestOTP();
    }
  }
}