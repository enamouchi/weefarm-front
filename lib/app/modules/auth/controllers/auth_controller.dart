// lib/app/modules/auth/controllers/auth_controller.dart
import 'dart:async';
import 'dart:io';
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
import 'package:weefarm/app/widgets/locations_selector.dart';
import 'package:weefarm/app/widgets/phone_input_field.dart'; // Import the location selector

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
  
  // Registration specific - Updated to use proper location objects
  final RxString selectedRole = 'farmer'.obs; // Changed default to farmer
  final Rx<TunisianLocation?> selectedGovernorate = Rx<TunisianLocation?>(null);
  final Rx<TunisianDelegation?> selectedDelegation = Rx<TunisianDelegation?>(null);
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
      
      final cleanedPhone = _cleanPhoneForApi(phoneController.text);
      print('Requesting OTP for phone: $cleanedPhone'); // Debug log
      
      final response = await _apiService.post('/auth/request-otp', data: {
        'phone': cleanedPhone,
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
        
        // Debug - show OTP in development
        if (response.data['otp'] != null) {
          print('Development OTP: ${response.data['otp']}');
        }
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
      
      final cleanedPhone = _cleanPhoneForApi(phoneController.text);
      print('Logging in with phone: $cleanedPhone, OTP: ${otpController.text}'); // Debug log
      
      final response = await _apiService.post('/auth/verify-otp', data: {
        'phone': cleanedPhone,
        'otp': otpController.text,
      });
      
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];
        final userData = response.data['user'];
        
        print('Login successful, tokens received'); // Debug log
        
        // Save tokens
        await _storageService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        // Save user data
        final user = UserModel.fromJson(userData);
        await _storageService.saveUser(user);
        
        // Update user state
        currentUser.value = user;
        isLoggedIn.value = true;
        
        // Clear OTP controller
        otpController.clear();
        
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
    
    final cleanedPhone = _cleanPhoneForApi(phoneController.text);
    print('Registering with phone: $cleanedPhone');
    print('Selected governorate: ${selectedGovernorate.value?.id}');
    print('Selected delegation: ${selectedDelegation.value?.id}');
    
    // Validate required fields
    if (selectedGovernorate.value == null || selectedDelegation.value == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_location'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }
    
    // Create form data
    dio.FormData formData = dio.FormData.fromMap({
      'name': nameController.text.trim(),
      'phone': cleanedPhone,
      'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      'role': selectedRole.value,
      'governorateId': selectedGovernorate.value!.id.toString(),
      'delegationId': selectedDelegation.value!.id.toString(),
    });
    
    // Add avatar if selected
    if (selectedAvatar.value != null) {
      try {
        final file = selectedAvatar.value!;
        print('Adding avatar file: ${file.path}');
        
        formData.files.add(MapEntry(
          'avatar',
          await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      } catch (fileError) {
        print('Error adding avatar file: $fileError');
        Get.snackbar(
          'warning'.tr,
          'avatar_upload_failed_continuing'.tr,
          backgroundColor: AppColors.warning,
          colorText: AppColors.white,
        );
      }
    }
    
    final response = await _apiService.post('/auth/register', data: formData);
    
    if (response.statusCode == 201) {
      print('Registration successful');
      
      // Start OTP timer and navigate
      _startOtpTimer();
      Get.toNamed(Routes.OTP_VERIFICATION);
      
      // Clear form after a delay to avoid controller disposal issues
      Future.delayed(const Duration(milliseconds: 500), () {
        _clearRegistrationForm();
      });
      
      Get.snackbar(
        'success'.tr,
        'registration_successful_verify_phone'.tr,
        backgroundColor: AppColors.primaryGreen,
        colorText: AppColors.white,
      );
      
      // Debug - show OTP in development
      if (response.data['otp'] != null) {
        print('Development OTP: ${response.data['otp']}');
      }
    }
  } catch (e) {
    print('Registration error: $e');
    _handleError(e);
  } finally {
    isLoading.value = false;
  }
}
  // Resend OTP
  Future<void> resendOTP() async {
    try {
      final cleanedPhone = _cleanPhoneForApi(phoneController.text);
      
      final response = await _apiService.post('/auth/request-otp', data: {
        'phone': cleanedPhone,
      });
      
      if (response.statusCode == 200) {
        _startOtpTimer();
        
        Get.snackbar(
          'success'.tr,
          'otp_resent'.tr,
          backgroundColor: AppColors.primaryGreen,
          colorText: AppColors.white,
        );
        
        // Debug - show OTP in development
        if (response.data['otp'] != null) {
          print('Development OTP: ${response.data['otp']}');
        }
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
      
      // Clear registration form
      _clearRegistrationForm();
      
      Get.offAllNamed(Routes.WELCOME);
    } catch (e) {
      print('Logout error: $e');
    }
  }
  
  // ---------------- PHONE HELPERS ----------------

  /// Clean phone number to just digits (remove +216 prefix if present)
  String _cleanPhoneForApi(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Remove Tunisia country code if present
    if (cleaned.startsWith('216')) {
      cleaned = cleaned.substring(3);
    }
    
    return cleaned;
  }

  /// Format a phone into +216 XX XXX XXX (Tunisian style) for display
  String getFormattedPhone(String phone) {
    final cleaned = _cleanPhoneForApi(phone);

    if (cleaned.length == 8) {
      return '+216 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
    }

    return phone; // fallback
  }

  /// Auto-format while typing inside TextField
  void formatPhoneNumber(String value) {
  // Don't format if user is deleting (value is getting shorter)
  if (value.length < phoneController.text.length) {
    return;
  }
  
  String cleaned = value.replaceAll(RegExp(r'\D'), '');

  // Remove country code if already included
  if (cleaned.startsWith('216')) {
    cleaned = cleaned.substring(3);
  }

  // Limit to 8 digits for Tunisian numbers
  if (cleaned.length > 8) {
    cleaned = cleaned.substring(0, 8);
  }

  // Only format if we have a meaningful change
  String formatted = '+216 ';
  if (cleaned.length >= 2) {
    formatted += '${cleaned.substring(0, 2)} ';
  }
  if (cleaned.length >= 5) {
    formatted += '${cleaned.substring(2, 5)} ';
  }
  if (cleaned.length >= 8) {
    formatted += cleaned.substring(5, 8);
  } else if (cleaned.length > 5) {
    formatted += cleaned.substring(5);
  } else if (cleaned.length > 2) {
    formatted += cleaned.substring(2);
  } else if (cleaned.length > 0) {
    formatted += cleaned;
  }

  // Only update if the formatted value is different
  if (phoneController.text != formatted.trim()) {
    phoneController.text = formatted.trim();
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length),
    );
  }
}
  
  bool isValidTunisianPhone(String phone) {
    return phoneController.isValidTunisianPhone; // Use the extension method
  }
  
  // ---------------- LOCATION HELPERS ----------------
  
  void onLocationSelected(TunisianLocation? governorate, TunisianDelegation? delegation) {
    selectedGovernorate.value = governorate;
    selectedDelegation.value = delegation;
    print('Location selected - Gov: ${governorate?.id}, Del: ${delegation?.id}'); // Debug log
  }
  
  void setAvatar(File? file) {
    selectedAvatar.value = file;
    print('Avatar selected: ${file?.path}'); // Debug log
  }
  
  // ---------------- PRIVATE HELPERS ----------------
  
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
    selectedRole.value = 'farmer';
    selectedGovernorate.value = null;
    selectedDelegation.value = null;
    selectedAvatar.value = null;
  }
  
  void _handleError(dynamic error) {
    String message = 'something_went_wrong'.tr;
    
    print('Error details: $error'); // Debug log
    
    if (error is DioException) {
      print('Dio error response: ${error.response?.data}'); // Debug log
      
      if (error.response?.data != null) {
        if (error.response!.data is Map && error.response!.data['error'] != null) {
          message = error.response!.data['error'];
        } else if (error.response!.data is Map && error.response!.data['message'] != null) {
          message = error.response!.data['message'];
        } else if (error.response!.data is Map && error.response!.data['errors'] != null) {
          // Handle validation errors
          final errors = error.response!.data['errors'] as List;
          if (errors.isNotEmpty) {
            message = errors.first['msg'] ?? errors.first.toString();
          }
        }
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
      duration: const Duration(seconds: 4),
    );
  }
}