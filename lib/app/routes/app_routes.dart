class Routes {
  Routes._();
  
  // Authentication Routes
  static const String WELCOME = '/welcome';
  static const String REGISTER = '/register';
  static const String LOGIN = '/login';
  static const String OTP_VERIFICATION = '/otp-verification';
  
  // Main App Routes
  static const String MAIN = '/main';
  static const String HOME = '/home';
  static const String MARKETPLACE = '/marketplace';
  static const String MY_ORDERS = '/my-orders';
  static const String CHAT = '/chat';
  static const String PROFILE = '/profile';
  
  // Product Routes
  static const String PRODUCT_DETAILS = '/product-details';
  static const String ADD_PRODUCT = '/add-product';
  static const String EDIT_PRODUCT = '/edit-product';
  static const String MY_PRODUCTS = '/my-products';
  
  // Service Routes
  static const String SERVICES = '/services';
  static const String SERVICE_DETAILS = '/service-details';
  
  // Order Routes
  static const String ORDER_DETAILS = '/order-details';
  static const String CREATE_ORDER = '/create-order';
  
  // Chat Routes
  static const String CONVERSATION = '/conversation';
  static const String CONVERSATIONS_LIST = '/conversations-list';
  
  // Feed Routes
  static const String FEED = '/feed';
  static const String POST_DETAILS = '/post-details';
  
  // Profile Routes
  static const String EDIT_PROFILE = '/edit-profile';
  static const String SETTINGS = '/settings';
  
  // Other Routes
  static const String NOTIFICATIONS = '/notifications';
  static const String SEARCH = '/search';
  static const String LOCATION_PICKER = '/location-picker';
}