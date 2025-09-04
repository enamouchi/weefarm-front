import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../widgets/custom_button.dart';

class OtpVerificationView extends GetView<AuthController> {
  const OtpVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('verify_phone'.tr),
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
          key: controller.otpFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Header
              _buildHeader(),
              
              const SizedBox(height: 40),
              
              // Verification Icon
              _buildVerificationIcon(),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              _buildOtpInputFields(),
              
              const SizedBox(height: 32),
              
              // Verify Button
              _buildVerifyButton(),
              
              const SizedBox(height: 24),
              
              // Resend Section
              _buildResendSection(),
              
              const SizedBox(height: 24),
              
              // Development Note
              _buildDevelopmentNote(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'verify_phone_number'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${'otp_sent_to'.tr} ${controller.getFormattedPhone(controller.phoneController.text)}',
          style: Get.textTheme.bodyLarge?.copyWith(
            color: AppColors.mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildVerificationIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.sms_outlined,
        size: 50,
        color: AppColors.primaryGreen,
      ),
    );
  }
  
  Widget _buildOtpInputFields() {
    return Column(
      children: [
        Text(
          'enter_verification_code'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOtpDigitField(index)),
        ),
      ],
    );
  }
  
  Widget _buildOtpDigitField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGray,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: Get.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onOtpDigitChanged(value, index),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildVerifyButton() {
    return Obx(() => CustomButton.primary(
      text: 'verify_and_continue'.tr,
      onPressed: controller.isLoading.value ? null : _handleVerify,
      isLoading: controller.isLoading.value,
      width: double.infinity,
      height: 56,
    ));
  }
  
  Widget _buildResendSection() {
    return Obx(() {
      if (controller.otpTimer.value > 0) {
        return Column(
          children: [
            Text(
              'didnt_receive_code'.tr,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${'resend_in'.tr} ${controller.otpTimer.value}s',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Text(
              'didnt_receive_code'.tr,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: controller.resendOTP,
              child: Text(
                'resend_code'.tr,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      }
    });
  }
  
  Widget _buildDevelopmentNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.developer_mode,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'development_mode'.tr,
                style: Get.textTheme.labelLarge?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'use_otp_123456'.tr,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _onOtpDigitChanged(String value, int index) {
    // Update the OTP controller text
    String currentOtp = controller.otpController.text.padRight(6, ' ');
    List<String> otpDigits = currentOtp.split('');
    
    if (value.isNotEmpty) {
      otpDigits[index] = value;
      
      // Move to next field if not the last one
      if (index < 5) {
        FocusScope.of(Get.context!).nextFocus();
      }
    } else {
      otpDigits[index] = ' ';
      
      // Move to previous field if not the first one
      if (index > 0) {
        FocusScope.of(Get.context!).previousFocus();
      }
    }
    
    controller.otpController.text = otpDigits.join('').trim();
  }
  
  void _handleVerify() {
    final otp = controller.otpController.text.trim();
    // TODO: FIXME

    // if (otp.length != 6) {
    //   Get.snackbar(
    //     'error'.tr,
    //     'enter_complete_otp'.tr,
    //     backgroundColor: AppColors.error,
    //     colorText: AppColors.white,
    //   );
    //   return;
    // }

    controller.login();
  }
}