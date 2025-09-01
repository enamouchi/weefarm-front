import 'package:get/get.dart';

import 'app_routes.dart';

// Views
import '../modules/auth/views/welcome_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_verification_view.dart';
import '../modules/main/views/main_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/marketplace/views/marketplace_view.dart';

// Controllers
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/main/controllers/main_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/marketplace/controllers/marketplace_controller.dart';

class AppPages {
  AppPages._();

  static final routes = [
    // Authentication Routes
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    
    GetPage(
      name: Routes.OTP_VERIFICATION,
      page: () => const OtpVerificationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),

    // Main App Routes
    GetPage(
      name: Routes.MAIN,
      page: () => const MainView(),
      bindings: [
        BindingsBuilder(() {
          Get.lazyPut<MainController>(() => MainController());
          Get.lazyPut<AuthController>(() => AuthController());
          Get.lazyPut<HomeController>(() => HomeController());
          Get.lazyPut<MarketplaceController>(() => MarketplaceController());
        }),
      ],
    ),

    // Home Route
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),

    // Marketplace Routes
    GetPage(
      name: Routes.MARKETPLACE,
      page: () => const MarketplaceView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MarketplaceController>(() => MarketplaceController());
      }),
    ),

    // TODO: Add remaining routes as controllers are created
    // GetPage(name: Routes.PRODUCT_DETAILS, page: () => const ProductDetailsView()),
    // GetPage(name: Routes.ADD_PRODUCT, page: () => const AddProductView()),
    // GetPage(name: Routes.MY_ORDERS, page: () => const OrdersView()),
    // GetPage(name: Routes.CHAT, page: () => const ConversationsView()),
    // GetPage(name: Routes.PROFILE, page: () => const ProfileView()),
  ];
}