class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://oracleapex.com/ords/topg';

  // Products
  static const String getProducts           = '/products/GetProducts';
  static const String insertProduct         = '/products/InsertProduct';
  static const String updateItem            = '/products/UpdateItem';
  static const String updateItemImages      = '/products/UpdateItemImages';
  static const String insertProductDetails  = '/products/InsertProductDetails';
  static const String deleteItemDetails     = '/products/DeleteItemDetails';
  static const String getItemDetails        = '/products/GetItemDetails';
  static const String getItemImages         = '/products/GetItemImages';
  static const String getSizes              = '/products/GetSizes';
  static const String getSizeGroups         = '/products/GetGroupsSize';

  // Favourites
  static const String getUserFavorites      = '/products/GetUserFavorites';
  static const String toggleFavoriteItem    = '/products/ToggleFavoriteItem';

  // Comments / Ratings
  static const String addItemComment        = '/products/AddItemComment';

  // Cart
  static const String getItemCart           = '/products/GetItemCart';
  static const String addItemToCart         = '/products/AddItemToCart';
  static const String deleteItemCart        = '/products/DeleteItemCart';

  // Orders
  static const String getOrders             = '/products/GetOrders';

  // Users
  static const String sendOtp               = '/users/SendOTP';
  static const String verifyOtp             = '/users/VerifyOTP';
  static const String forgetPassword        = '/users/ForgetPassword';
  static const String login                 = '/users/Login';
  static const String register              = '/users/Register';

  static const Duration timeout = Duration(seconds: 10);
}
