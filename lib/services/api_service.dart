import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/api_response_model.dart';
import 'api_constants.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Fetch all products
Future<ApiResponse<List<Product>>> getProducts({int page = 1, int perPage = 10}) async {
    try {
      final response = await http
          .get(
             Uri.parse(ApiConstants.productsUrl(page: page, perPage: perPage)),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        
        
        // Parse products from response
        final List<dynamic> productsJson = json.decode(response.body);
        final List<Product> products = productsJson
            .map((json) => Product.fromJson(json))
            .toList();

        return ApiResponse.success(
          message:  'Products loaded successfully',
          data: products,
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to load products',
          error: 'Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('e: $e');
      return ApiResponse.error(
        message: 'Something went wrong',
        error: e.toString(),
      );
    }
  }

  // Fetch single product details
  Future<ApiResponse<Product>> getProductDetails(String productId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConstants.productDetailsUrl(productId)),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.connectionTimeout);

if (response.statusCode == 200) {
        // WooCommerce returns product object directly
        final jsonData = json.decode(response.body);
        final Product product = Product.fromJson(jsonData);

        return ApiResponse.success(
          message: 'Product details loaded',
          data: product,
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to load product details',
          error: 'Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Something went wrong',
        error: e.toString(),
      );
    }
  }

  // Search products
Future<ApiResponse<List<Product>>> searchProducts(String query)  async {
    // try {
    //   final uri = Uri.parse(ApiConstants.searchUrl).replace(
    //     queryParameters: {'q': query},
    //   );

    //   final response = await http
    //       .get(uri, headers: ApiConstants.headers)
    //       .timeout(ApiConstants.connectionTimeout);

    //   if (response.statusCode == 200) {
    //     final jsonData = json.decode(response.body);
    //     final List<dynamic> productsJson = jsonData['data'] ?? [];
    //     final List<Product> products = productsJson
    //         .map((json) => Product.fromJson(json))
    //         .toList();

    //     return ApiResponse.success(
    //       message: 'Search completed',
    //       data: products,
    //     );
    //   } else {
    //     return ApiResponse.error(
    //       message: 'Search failed',
    //       error: 'Status code: ${response.statusCode}',
    //     );
    //   }
    // } catch (e) {
    //   return ApiResponse.error(
    //     message: 'Something went wrong',
    //     error: e.toString(),
    //   );
    // }
    return ApiResponse.error(
      message: 'Search not implemented',
      error: 'Search functionality is currently not implemented.',
    );
  }
}