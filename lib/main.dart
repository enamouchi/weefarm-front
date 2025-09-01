import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/values/app_theme.dart';
import 'app/core/services/storage_service.dart';
import 'app/core/services/api_service.dart';
import 'app/core/utils/app_translations.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize services
  await _initializeServices();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(WeeFarmApp());
}

Future<void> _initializeServices() async {
  // Initialize core services
  Get.put(StorageService(), permanent: true);
  Get.put(ApiService(), permanent: true);
}

class WeeFarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WeeFarm',
      debugShowCheckedModeBanner: false,
      
      // Localization
      translations: AppTranslations(),
      locale: const Locale('ar', 'TN'), // Arabic Tunisia
      fallbackLocale: const Locale('fr', 'TN'), // French Tunisia
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Routing
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
      
      // Right-to-left support for Arabic
      builder: (context, child) {
        return Directionality(
          textDirection: Get.locale?.languageCode == 'ar' 
              ? TextDirection.rtl 
              : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
  
  String _getInitialRoute() {
    final storageService = Get.find<StorageService>();
    
    // Check if user is logged in
    if (storageService.hasValidToken()) {
      return Routes.MAIN;
    } else {
      return Routes.WELCOME;
    }
  }
}