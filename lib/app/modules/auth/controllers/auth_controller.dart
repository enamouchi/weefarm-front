// lib/app/modules/auth/controllers/auth_controller.dart
import 'dart:async';
import 'dart:io';  // Added this import for File type
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' as dio show FormData, MultipartFile;
import 'package:weefarm/app/core/values/app_colors.dart';
import 'package:weefarm/app/widgets/custom_button.dart';
import 'package:weefarm/app/widgets/feed_card.dart';
import 'package:weefarm/app/widgets/loading_shimmer.dart';
import 'package:weefarm/app/routes/app_routes.dart';
import 'package:weefarm/app/core/services/api_service.dart';
import 'package:weefarm/app/core/services/storage_service.dart';
import 'package:weefarm/app/data/models/user_model.dart';


class AuthController extends GetxController {
  // Services
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  // Registration specific
  final RxString selectedRole = 'citizen'.obs;
  final Rx<String?> selectedGovernorate = Rx<String?>(null);
  final Rx<String?> selectedDelegation = Rx<String?>(null);
  final Rx<File?> selectedAvatar = Rx<File?>(null);
  
  // OTP timer
  final RxInt otpTimer = 0.obs;
  Timer? _otpTimerInstance;

  // Add getter for farmer check
  bool get isFarmer => currentUser.value?.isFarmer ?? false;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }
  
  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    otpController.dispose();
    _otpTimerInstance?.cancel();
    super.onClose();
  }
  
  // Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    try {
      final token = _storageService.accessToken;
      if (token != null && _storageService.hasValidToken()) {
        // Validate token and get user info
        final response = await _apiService.get('/users/me');
        if (response.statusCode == 200) {
          currentUser.value = UserModel.fromJson(response.data);
          isLoggedIn.value = true;
        }
      }
    } catch (e) {
      // Token invalid, clear it
      await logout();
    }
  }
  
  // Request OTP for phone number
  Future<void> requestOTP() async {
    try {
      isLoading.value = true;
      
      final formattedPhone = _formatPhoneForApi(phoneController.text);
      
      final response = await _apiService.post('/auth/request-otp', data: {
        'phone': formattedPhone,
      });
      
      if (response.statusCode == 200) {
        _startOtpTimer();
        Get.toNamed(Routes.OTP_VERIFICATION);
        
        Get.snackbar(
          'success'.tr,
          'otp_sent_successfully'.tr,
          backgroundColor: AppColors.primaryGreen,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Verify OTP and login
  Future<void> login() async {
    try {
      isLoading.value = true;
      
      final formattedPhone = _formatPhoneForApi(phoneController.text);
      
      final response = await _apiService.post('/auth/verify-otp', data: {
        'phone': formattedPhone,
        'otp': otpController.text,
      });
      
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'] ?? response.data['token'];
        final refreshToken = response.data['refreshToken'];
        final userData = response.data['user'];
        
        // Save tokens
        await _storageService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
        
        // Save user data
        final user = UserModel.fromJson(userData);
        await _storageService.saveUser(user);
        
        // Update user state
        currentUser.value = user;
        isLoggedIn.value = true;
        
        // Navigate to main app
        Get.offAllNamed(Routes.MAIN);
        
        Get.snackbar(
          'welcome'.tr,
          'login_successful'.tr,
          backgroundColor: AppColors.primaryGreen,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        Get.snackbar(
          'error'.tr,
          'invalid_otp'.tr,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      } else {
        _handleError(e);
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Register new user
  Future<void> register() async {
    try {
      isLoading.value = true;
      
      // Use the prefixed FormData from dio package
      dio.FormData formData = dio.FormData.fromMap({
        'name': nameController.text.trim(),
        'phone': _formatPhoneForApi(phoneController.text),
        'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        'role': selectedRole.value,
        'governorate': selectedGovernorate.value,
        'delegation': selectedDelegation.value,
      });
      
      // Add avatar if selected
      if (selectedAvatar.value != null) {
        formData.files.add(MapEntry(
          'avatar',
          await dio.MultipartFile.fromFile(selectedAvatar.value!.path),
        ));
      }
      
      final response = await _apiService.post('/auth/register', data: formData);
      
      if (response.statusCode == 201) {
        // Clear form
        _clearRegistrationForm();
        
        // Go to OTP verification
        _startOtpTimer();
        Get.toNamed(Routes.OTP_VERIFICATION);
        
        Get.snackbar(
          'success'.tr,
          'registration_successful_verify_phone'.tr,
          backgroundColor: AppColors.primaryGreen,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Resend OTP
  Future<void> resendOTP() async {
    try {
      final formattedPhone = _formatPhoneForApi(phoneController.text);
      
      final response = await _apiService.post('/auth/resend-otp', data: {
        'phone': formattedPhone,
      });
      
      if (response.statusCode == 200) {
        _startOtpTimer();
        
        Get.snackbar(
          'success'.tr,
          'otp_resent'.tr,
          backgroundColor: AppColors.primaryGreen,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      _handleError(e);
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _storageService.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      
      // Clear all controllers
      phoneController.clear();
      nameController.clear();
      emailController.clear();
      otpController.clear();
      
      Get.offAllNamed(Routes.WELCOME);
    } catch (e) {
      print('Logout error: $e');
    }
  }
  
  // Helper methods
  String _formatPhoneForApi(String phone) {
    return phone.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
  }
  
  String getFormattedPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('216')) {
      return '+216 ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
    }
    return phone;
  }
  
  void formatPhoneNumber(String value) {
    // Auto-format Tunisian phone numbers
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.startsWith('216')) {
      cleaned = cleaned.substring(3);
    }
    
    if (cleaned.length >= 2) {
      String formatted = '+216 ';
      if (cleaned.length >= 2) {
        formatted += '${cleaned.substring(0, 2)} ';
      }
      if (cleaned.length >= 5) {
        formatted += '${cleaned.substring(2, 5)} ';
      }
      if (cleaned.length >= 8) {
        formatted += cleaned.substring(5, 8);
      }
      
      phoneController.text = formatted;
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      );
    }
  }
  
  bool isValidTunisianPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^216[0-9]{8}$').hasMatch(cleaned);
  }
  
  void _startOtpTimer() {
    otpTimer.value = 60; // 60 seconds
    _otpTimerInstance?.cancel();
    _otpTimerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }
  
  void _clearRegistrationForm() {
    nameController.clear();
    emailController.clear();
    selectedRole.value = 'citizen';
    selectedGovernorate.value = null;
    selectedDelegation.value = null;
    selectedAvatar.value = null;
  }
  
  void _handleError(dynamic error) {
    String message = 'something_went_wrong'.tr;
    
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['message'] != null) {
        message = error.response!.data['message'];
      } else {
        switch (error.response?.statusCode) {
          case 400:
            message = 'invalid_request'.tr;
            break;
          case 401:
            message = 'unauthorized'.tr;
            break;
          case 403:
            message = 'forbidden'.tr;
            break;
          case 404:
            message = 'not_found'.tr;
            break;
          case 500:
            message = 'server_error'.tr;
            break;
        }
      }
    }
    
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }
}