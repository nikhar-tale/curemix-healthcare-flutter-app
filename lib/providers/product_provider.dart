import 'package:curemix_healtcare_flutter_app/services/cache_service.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService(); // ✅ Add this

  // State variables
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMoreProducts = true;
  bool _isLoadingMore = false; // Add this at top of class

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasProducts => _products.isNotEmpty;

  // Add getters
  int get currentPage => _currentPage;
  bool get hasMoreProducts => _hasMoreProducts;

  Future<void> fetchProducts({bool loadMore = false}) async {
    print('🔵 fetchProducts - loadMore: $loadMore, page: $_currentPage');

    // ✅ Load from cache first (only on initial load)
    if (!loadMore && _products.isEmpty && _cacheService.hasCache()) {
      print('🔵 Loading from cache...');
      _products = _cacheService.getCachedProducts();
      notifyListeners();
      // Continue to fetch fresh data in background
    }

    // Prevent multiple simultaneous loads
    if (loadMore && _isLoadingMore) {
      print('🔴 Already loading more');
      return;
    }

    if (loadMore && !_hasMoreProducts) {
      print('🔴 No more products');
      return;
    }

    if (loadMore && _isLoading) {
      print('🔴 Already loading');
      return;
    }

    // Reset for initial load
    if (!loadMore) {
      _currentPage = 1;
      // Don't clear products if loading from cache
      if (!_cacheService.hasCache()) {
        _products = [];
      }
      _hasMoreProducts = true;
    }

    if (loadMore) {
      _isLoadingMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts(
        page: _currentPage,
        perPage: 10,
      );

      print('🔵 Got ${response.data?.length ?? 0} products from API');

      if (response.success && response.data != null) {
        if (loadMore) {
          _products.addAll(response.data!);
        } else {
          _products = response.data!;

          // ✅ Save to cache (only on initial load)
          await _cacheService.saveProducts(_products);
          print('🔵 Saved ${_products.length} products to cache');
        }

        _hasMoreProducts = response.data!.length >= 10;

        if (loadMore) {
          _currentPage++;
          _isLoadingMore = false;
        }

        _errorMessage = null;

        print(
          '🔵 Total products: ${_products.length}, hasMore: $_hasMoreProducts',
        );
      } else {
        _errorMessage = response.message;
        if (!loadMore && !_cacheService.hasCache()) {
          _products = [];
        }
      }
    } catch (e) {
      print('🔴 Error: $e');
      _errorMessage = 'Failed to load products';

      // ✅ If failed and no cache, show empty
      if (!loadMore && !_cacheService.hasCache()) {
        _products = [];
      }
    } finally {
      _isLoading = false;
      if (loadMore) {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  //   // Fetch all products
  //  Future<void> fetchProducts({bool loadMore = false}) async {
  //     print('🔵 fetchProducts - loadMore: $loadMore, page: $_currentPage, isLoading: $_isLoading');

  //     // Prevent multiple simultaneous loads
  //     if (loadMore && _isLoadingMore) {
  //       print('🔴 Already loading more');
  //       return;
  //     }

  //     if (loadMore && !_hasMoreProducts) {
  //       print('🔴 No more products');
  //       return;
  //     }

  //     if (loadMore && _isLoading) {
  //       print('🔴 Already loading');
  //       return;
  //     }

  //     // Reset for initial load
  //     if (!loadMore) {
  //       _currentPage = 1;
  //       _products = [];
  //       _hasMoreProducts = true;
  //     }

  //     if (loadMore) {
  //       _isLoadingMore = true;
  //     }

  //     _isLoading = true;
  //     _errorMessage = null;
  //     notifyListeners();

  //     try {
  //       final response = await _apiService.getProducts(
  //         page: _currentPage,
  //         perPage: 10,
  //       );

  //       print('🔵 Got ${response.data?.length ?? 0} products');

  //       if (response.success && response.data != null) {
  //         if (loadMore) {
  //           _products.addAll(response.data!);
  //         } else {
  //           _products = response.data!;
  //         }

  //         // ✅ CRITICAL FIX: Match your perPage value
  //         _hasMoreProducts = response.data!.length >= 10;

  //         if (loadMore) {
  //           _currentPage++;
  //           _isLoadingMore = false;
  //         }

  //         _errorMessage = null;

  //         print('🔵 Total products: ${_products.length}, hasMore: $_hasMoreProducts, nextPage: $_currentPage');
  //       } else {
  //         _errorMessage = response.message;
  //         if (!loadMore) {
  //           _products = [];
  //         }
  //       }
  //     } catch (e) {
  //       print('🔴 Error: $e');
  //       _errorMessage = 'Failed to load products';
  //       if (!loadMore) {
  //         _products = [];
  //       }
  //     } finally {
  //       _isLoading = false;
  //       if (loadMore) {
  //         _isLoadingMore = false;
  //       }
  //       notifyListeners();
  //     }
  //   }

  // Refresh products
  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter products by category
  List<Product> getProductsByCategory(String category) {
    return _products
        .where(
          (product) =>
              product.category?.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // Get products in stock only
  List<Product> get inStockProducts {
    return _products.where((product) => product.isInStock).toList();
  }
}
