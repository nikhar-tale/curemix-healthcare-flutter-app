class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://curemixhealthcare.in';
  
  // WooCommerce API path
  static const String apiPath = '/wp-json/wc/v3';
  
  // Auth credentials
  static const String consumerKey = 'ck_d11f698348a638c75184cd25a39168cad720b0d2';
  static const String consumerSecret = 'cs_5c0fd4c11129c7e978e8da5ce57025dd4ce7d050';
  
  // Endpoints
  static const String products = '$apiPath/products';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Build URL with auth
  static String productsUrl({int page = 1, int perPage = 10}) {
    return '$baseUrl$products?consumer_key=$consumerKey&consumer_secret=$consumerSecret&per_page=$perPage&page=$page';
  }
  
  static String productDetailsUrl(String id) {
    return '$baseUrl$products/$id?consumer_key=$consumerKey&consumer_secret=$consumerSecret';
  }
  
  static String searchUrl(String query, {int page = 1, int perPage = 10}) {
  return '$baseUrl$products?consumer_key=$consumerKey&consumer_secret=$consumerSecret&search=$query&per_page=$perPage&page=$page';
}
}