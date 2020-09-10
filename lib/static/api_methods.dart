const API_URL = 'http://176.99.5.64';
const API_HOST = 'g2r.market';

const CLIENT_ID = '91789803-d774-4296-b897-d36e85853d43';
const CLIENT_SECRET = 'yCPkP0jrZVnAeH2uQ7kZhJ2N7rakaDq7QFgZjr51';

const REDIRECT_URL = 'http://localhost/';

class MarketApi {

  static String authUrl = '$API_URL/oauth/token';
  static String saveDevice = '$API_URL/api/mobile/device/save';
  static String registerUrl = '$API_URL/api/mobile/register';

  static String mainUrl = '$API_URL/api/mobile/categories?type=popular';

  static String fullCatalog = '$API_URL/api/mobile/categories';
  static String getCategoriesList = '$API_URL/api/mobile/categories/list';

  static String getProducts = '$API_URL/api/mobile/catalog';
  static String getProduct = '$API_URL/api/mobile/catalog/product';

  static String favoriteProductAdd = '$API_URL/api/mobile/favorite/product/add';
  static String favoriteProductRemove = '$API_URL/api/mobile/favorite/product/remove';
  static String favoriteProductGet = '$API_URL/api/mobile/favorite/product';

  //Кабинет менеджера
  static String getCompanies = '$API_URL/api/mobile/companies';
  static String getCompanyProfiles = '$API_URL/api/mobile/company/profiles';
  static String createCompany = '$API_URL/api/mobile/company/store';
  static String approveCompanyProfile = '$API_URL/api/mobile/company/approval/';

  //Кабинет пользователя
  static String accountInfo = '$API_URL/api/mobile/account';
  static String accountInfoUpdate = '$API_URL/api/mobile/account/edit';

  static String getBuyers = '$API_URL/api/mobile/profile/buyer';
  static String getSellers = '$API_URL/api/mobile/profile/seller';
  static String getProfileInfo = '$API_URL/api/mobile/profile/index';

  static String getProductCabinet = '$API_URL/api/mobile/products';

  static String getChats = '$API_URL/api/mobile/chat/get';
  static String getMessagesSupport = '$API_URL/api/mobile/chat/get/support/';
  static String getMessages = '$API_URL/api/mobile/chat/get/profile/';
  static String sendSupport = '$API_URL/api/mobile/chat/send/support/';
  static String sendProfile = '$API_URL/api/mobile/chat/send/profile/';

  static String createSeller = '$API_URL/api/mobile/create/profile';
}