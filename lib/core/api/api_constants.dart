class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://oracleapex.com/ords/topg';

  // Products
  static const String getProducts = '/products/GetProducts';
  static const String insertProduct = '/products/InsertProduct';
  static const String updateItem = '/products/UpdateItem';
  static const String updateItemImages = '/products/UpdateItemImages';
  static const String insertItemImages = '/products/InsertItemImages';
  static const String insertProductDetails = '/products/InsertProductDetails';
  static const String deleteItemDetails = '/products/DeleteItemDetails';
  static const String getItemDetails = '/products/GetItemDetails';
  static const String getItemImages = '/products/GetItemImages';
  static const String getSizes = '/products/GetSizes';
  static const String getSizeGroups = '/products/GetGroupsSize';

  // Favourites
  static const String getUserFavorites = '/products/GetUserFavorites';
  static const String toggleFavoriteItem = '/products/ToggleFavoriteItem';

  // Comments / Ratings
  static const String getItemComment = '/products/GetItemComment';
  static const String addItemComment = '/products/AddItemComment';
  static const String checkUserItemOrder = '/products/check_user_item_order';

  // Cart
  static const String getItemCart = '/products/GetItemCart';
  static const String addItemToCart = '/products/AddItemToCart';
  static const String deleteItemCart = '/products/DeleteItemCart';

  // Orders
  static const String getOrders = '/products/GetOrders';
  static const String getOrderDetails = '/products/GetOrderDetails';
  static const String checkout = '/products/CheckOut';
  static const String searchByImage = '/products/SearchByImage';

  // Users
  static const String sendOtp = '/users/SendOTP';
  static const String verifyOtp = '/users/VerifyOTP';
  static const String forgetPassword = '/users/ForgetPassword';
  static const String login = '/users/Login';
  static const String register = '/users/Register';
  static const String getUserAddress = '/users/GetUserAddress';
  static const String addUserAddress = '/users/AddUserAddress';
  static const String updateUserAddress = '/users/UpdateUserAddress';
  static const String deleteUserAddress = '/users/DeleteUserAddress';
  static const String updateUser = '/users/UpdateUser';

  static const Duration timeout = Duration(seconds: 10);
}
