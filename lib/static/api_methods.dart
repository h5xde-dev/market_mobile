const API_URL = 'http://176.99.5.64';

const CLIENT_ID = '910c3c97-998d-4c24-b3d5-1cbd25bd7c5c';
const CLIENT_SECRET = 'zhu2KbmN8TPT2DEsJY2LIGhdVo2jTUGDSRtWHcvG';

const REDIRECT_URL = 'http://localhost/';

class MarketApi {

  static String authUrl = '$API_URL/oauth/token';

  static String mainUrl = '$API_URL/api/mobile/categories?type=popular';

  static String fullCatalog = '$API_URL/api/mobile/categories';

  static String accountInfo = '$API_URL/api/mobile/account';

  static String getProducts = '$API_URL/api/mobile/catalog';
  static String getProduct = '$API_URL/api/mobile/catalog/product';
}