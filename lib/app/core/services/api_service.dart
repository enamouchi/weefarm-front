import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService extends getx.GetxService {
  late final Dio _dio;
  // FIXED: Changed baseUrl to work with AI endpoints
  final String baseUrl = 'http://127.0.0.1:3000/api';
  
  // Get storage service instance
  StorageService get _storage => getx.Get.find<StorageService>();
  
  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _addInterceptors();
  }
  
  void _addInterceptors() {
    // Request interceptor - Add JWT token to headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authorization header if token exists
          final token = _storage.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          log('🚀 ${options.method} ${options.path}');
          log('📤 Headers: ${options.headers}');
          if (options.data != null) {
            log('📤 Body: ${options.data}');
          }
          
          handler.next(options);
        },
        
        onResponse: (response, handler) {
          log('✅ ${response.statusCode} ${response.requestOptions.path}');
          log('📥 Response: ${response.data}');
          handler.next(response);
        },
        
        onError: (error, handler) async {
          log('❌ ${error.response?.statusCode} ${error.requestOptions.path}');
          log('❌ Error: ${error.response?.data}');
          
          // Handle token expiration - attempt refresh
          if (error.response?.statusCode == 401) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              // Retry the original request
              final options = error.requestOptions;
              final token = _storage.accessToken;
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              
              try {
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry also fails, proceed with original error
              }
            } else {
              // Refresh failed - logout user
              _handleLogout();
            }
          }
          
          handler.next(error);
        },
      ),
    );
    
    // Logging interceptor for development
   if (kDebugMode) {
  _dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: true,
    responseHeader: false,
    error: true,
    logPrint: (obj) => log(obj.toString()),
  ));
}
  }
  
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = _storage.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      
      final response = await _dio.post(
        '/v1/auth/refresh', // Updated path for existing auth
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      
      if (response.statusCode == 200 && response.data['tokens'] != null) {
        final tokens = response.data['tokens'];
        await _storage.saveTokens(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
        return true;
      }
      
      return false;
    } catch (e) {
      log('Token refresh failed: $e');
      return false;
    }
  }
  
  void _handleLogout() {
    _storage.logout();
    getx.Get.offAllNamed('/welcome');
    getx.Get.snackbar(
      'جلسة منتهية',
      'يرجى تسجيل الدخول مرة أخرى',
      backgroundColor: getx.Get.theme.colorScheme.error,
      colorText: getx.Get.theme.colorScheme.onError,
    );
  }
  
  // HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  // Multipart file upload using Dio (FIXED VERSION)
  Future<Response<T>> postMultipartDio<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options ?? Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response<T>> putMultipart<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options ?? Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // FIXED: Simple multipart upload for AI features
  Future<dynamic> postMultipart(String endpoint, File file, String field) async {
    try {
      // Create FormData for Dio
      final formData = FormData.fromMap({
        field: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // FIXED: Add missing helper methods
  Future<Map<String, String>> getHeaders() async {
    final token = _storage.accessToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Error handling
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
          statusCode: 408,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final responseData = e.response?.data;
        
        String message = 'حدث خطأ غير متوقع';
        
        if (responseData != null) {
          if (responseData is Map<String, dynamic>) {
            message = responseData['error'] ?? responseData['message'] ?? message;
          } else if (responseData is String) {
            message = responseData;
          }
        }
        
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      
      case DioExceptionType.cancel:
        return ApiException(
          message: 'تم إلغاء الطلب',
          statusCode: 0,
        );
      
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
      default:
        return ApiException(
          message: 'تحقق من اتصال الإنترنت وحاول مرة أخرى',
          statusCode: 0,
        );
    }
  }
  
  // Image URL helper
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '${baseUrl.replaceAll('/api', '')}/$cleanPath';
  }
  
  // Helper method to create FormData with files
  static Future<FormData> createFormData(
    Map<String, dynamic> fields, {
    Map<String, dynamic>? files,
  }) async {
    final formData = FormData();
    
    // Add regular fields
    fields.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });
    
    // Add files
    if (files != null) {
      for (final entry in files.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is List) {
          // Multiple files
          for (int i = 0; i < value.length; i++) {
            if (value[i] is MultipartFile) {
              formData.files.add(MapEntry('${key}[]', value[i]));
            }
          }
        } else if (value is MultipartFile) {
          // Single file
          formData.files.add(MapEntry(key, value));
        }
      }
    }
    
    return formData;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;
  
  const ApiException({
    required this.message,
    required this.statusCode,
    this.data,
  });
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
  
  bool get isNetworkError => statusCode == 0;
  bool get isServerError => statusCode >= 500;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 400;
}