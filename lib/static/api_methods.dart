const API_URL = 'http://176.99.5.64';
const API_HOST = 'g2r-market.su';

const CLIENT_ID = '915e2e84-6d36-44a1-8af5-2323d25643e6';
const CLIENT_SECRET = 'THsXjDr9HwF5rc9vfI2wiIfC6q8GFXZgKjQoC6Yc';

const REDIRECT_URL = 'http://localhost/';

class MarketApi {

  static String authUrl = '$API_URL/oauth/token';
  static String registerUrl = '$API_URL/api/mobile/register';

  static String mainUrl = '$API_URL/api/mobile/categories?type=popular';

  static String getChats = '$API_URL/api/mobile/chat/get';
  static String getMessagesSupport = '$API_URL/api/mobile/chat/get/support/';
  static String getMessages = '$API_URL/api/mobile/chat/get/profile/';
  static String sendSupport = '$API_URL/api/mobile/chat/send/support/';
  static String sendProfile = '$API_URL/api/mobile/chat/send/profile/';

  static String fullCatalog = '$API_URL/api/mobile/categories';

  static String accountInfo = '$API_URL/api/mobile/account';
  static String accountInfoUpdate = '$API_URL/api/mobile/account/edit';

  static String getBuyers = '$API_URL/api/mobile/profile/buyer';
  static String getSellers = '$API_URL/api/mobile/profile/seller';

  static String getProfileInfo = '$API_URL/api/mobile/profile/index';

  static String getProducts = '$API_URL/api/mobile/catalog';
  static String getProduct = '$API_URL/api/mobile/catalog/product';

  static String favoriteProductAdd = '$API_URL/api/mobile/favorite/product/add';
  static String favoriteProductRemove = '$API_URL/api/mobile/favorite/product/remove';
  static String favoriteProductGet = '$API_URL/api/mobile/favorite/product';
}