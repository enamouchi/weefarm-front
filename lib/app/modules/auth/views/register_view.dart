import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../controllers/auth_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/locations_selector.dart';
import '../../../routes/app_routes.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('create_account'.tr),
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
          key: controller.registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // Profile Photo Section
              _buildProfilePhotoSection(),
              
              const SizedBox(height: 24),
              
              // Name Field
              _buildNameField(),
              
              const SizedBox(height: 16),
              
              // Phone Field
              _buildPhoneField(),
              
              const SizedBox(height: 16),
              
              // Email Field
              _buildEmailField(),
              
              const SizedBox(height: 16),
              
              // Role Selection
              _buildRoleSelection(),
              
              const SizedBox(height: 16),
              
              // Location Section
              _buildLocationSection(),
              
              const SizedBox(height: 32),
              
              // Register Button
              _buildRegisterButton(),
              
              const SizedBox(height: 24),
              
              // Login Link
              _buildLoginLink(),
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
          'create_account'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'join_weefarm_community'.tr,
          style: Get.textTheme.bodyLarge?.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          Obx(() => GestureDetector(
            onTap: _showImagePickerDialog,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGray,
                border: Border.all(
                  color: AppColors.primaryGreen,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: controller.selectedAvatar.value != null
                  ? ClipOval(
                      child: Image.file(
                        controller.selectedAvatar.value!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: AppColors.mediumGray,
                    ),
            ),
          )),
          const SizedBox(height: 12),
          Text(
            'add_profile_photo'.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'optional'.tr,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNameField() {
    return CustomTextField(
      controller: controller.nameController,
      label: 'full_name'.tr,
      hint: 'enter_full_name'.tr,
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'field_required'.tr;
        }
        if (value.trim().length < 2) {
          return 'name_too_short'.tr;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }
  
  Widget _buildPhoneField() {
    return CustomTextField(
      controller: controller.phoneController,
      label: 'phone_number'.tr,
      hint: 'phone_format'.tr,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'field_required'.tr;
        }
        if (!GetUtils.isPhoneNumber(value)) {
          return 'invalid_phone'.tr;
        }
        // Tunisia phone number validation
        if (!RegExp(r'^\+216[0-9]{8}$').hasMatch(value.replaceAll(' ', ''))) {
          return 'invalid_tunisia_phone'.tr;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        // Format phone number as user types
        controller.formatPhoneNumber(value);
      },
    );
  }
  
  Widget _buildEmailField() {
    return CustomTextField(
      controller: controller.emailController,
      label: 'email'.tr + ' (' + 'optional'.tr + ')',
      hint: 'enter_email'.tr,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty && !GetUtils.isEmail(value)) {
          return 'invalid_email'.tr;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }
  
  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'account_type'.tr,
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildRoleChip(
              label: 'farmer'.tr,
              value: 'farmer',
              icon: Icons.agriculture,
              isSelected: controller.selectedRole.value == 'farmer',
            ),
            _buildRoleChip(
              label: 'citizen'.tr,
              value: 'citizen',
              icon: Icons.person,
              isSelected: controller.selectedRole.value == 'citizen',
            ),
            _buildRoleChip(
              label: 'service_provider'.tr,
              value: 'service_provider',
              icon: Icons.build,
              isSelected: controller.selectedRole.value == 'service_provider',
            ),
            _buildRoleChip(
              label: 'company'.tr,
              value: 'company',
              icon: Icons.business,
              isSelected: controller.selectedRole.value == 'company',
            ),
          ],
        )),
      ],
    );
  }
  
  Widget _buildRoleChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.selectedRole.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGray,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.mediumGray,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.white : AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
Widget _buildLocationSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'location'.tr,
        style: Get.textTheme.labelLarge?.copyWith(
          color: AppColors.black,
        ),
      ),
      const SizedBox(height: 12),
      LocationSelector(
        onLocationSelected: (governorate, delegation) {
          // CORRECTION : Convertir TunisianLocation/TunisianDelegation en String
          if (governorate != null) {
            controller.selectedGovernorate.value = governorate.nameEn; // ou nameAr/nameFr selon vos besoins
          } else {
            controller.selectedGovernorate.value = null;
          }
          
          if (delegation != null) {
            controller.selectedDelegation.value = delegation.nameEn; // ou nameAr/nameFr selon vos besoins
          } else {
            controller.selectedDelegation.value = null;
          }
        },
      ),
    ],
  );
}

void _handleRegister() {
  if (controller.registerFormKey.currentState!.validate()) {
    // CORRECTION : Vérification nullable avec safe access
    if (controller.selectedGovernorate.value == null || 
        controller.selectedGovernorate.value!.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'select_governorate_required'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }
    
    controller.register();
  }
}
  
  Widget _buildRegisterButton() {
    return Obx(() => CustomButton.primary(
      text: 'create_account'.tr,
      onPressed: controller.isLoading.value ? null : _handleRegister,
      isLoading: controller.isLoading.value,
      width: double.infinity,
      height: 56,
    ));
  }
  
  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'already_have_account'.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.offNamed(Routes.LOGIN),
            child: Text(
              'login'.tr,
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
  
  void _showImagePickerDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select_image'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton.outline(
                    text: 'camera'.tr,
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      Get.back();
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton.outline(
                    text: 'gallery'.tr,
                    icon: const Icon(Icons.photo_library),
                    onPressed: () {
                      Get.back();
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (pickedFile != null) {
      controller.selectedAvatar.value = File(pickedFile.path);
    }
  }
  
  
}