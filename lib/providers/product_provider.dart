import 'package:curemix_healtcare_flutter_app/services/cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService(); // ✅ Add this

  // State variables
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ ADD THESE for search
  List<Product> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  String _lastSearchQuery = '';

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

  // ✅ ADD THESE getters
  List<Product> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  Future<void> _precacheProductImages(
    BuildContext context,
    List<Product> products,
  ) async {
    for (final product in products) {
      // Make sure product.image or product.imageUrl is not null
      final imageUrl = product.imageUrl ?? '';
      if (imageUrl.isNotEmpty) {
        try {
          await precacheImage(NetworkImage(imageUrl), context);
        } catch (e) {
          debugPrint('⚠️ Failed to precache $imageUrl: $e');
        }
      }
    }
  }

  Future<void> fetchProducts({
    required BuildContext context,
    bool loadMore = false,
  }) async {
    if (kDebugMode) {
      print('🔵 fetchProducts - loadMore: $loadMore, page: $_currentPage');
    }

    // ✅ Load from cache first (only on initial load)
    if (!loadMore && _products.isEmpty && _cacheService.hasCache()) {
      if (kDebugMode) {
        print('🔵 Loading from cache...');
      }
      _products = _cacheService.getCachedProducts();
      notifyListeners();
      // Continue to fetch fresh data in background
    }

    // Prevent multiple simultaneous loads
    if (loadMore && _isLoadingMore) {
      if (kDebugMode) {
        print('🔴 Already loading more');
      }
      return;
    }

    if (loadMore && !_hasMoreProducts) {
      if (kDebugMode) {
        print('🔴 No more products');
      }
      return;
    }

    if (loadMore && _isLoading) {
      if (kDebugMode) {
        print('🔴 Already loading');
      }
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

      if (kDebugMode) {
        print('🔵 Got ${response.data?.length ?? 0} products from API');
      }

      if (response.success && response.data != null) {
        if (loadMore) {
          _products.addAll(response.data!);
        } else {
          _products = response.data!;

          // ✅ Save to cache (only on initial load)
          await _cacheService.saveProducts(_products);
          if (kDebugMode) {
            print('🔵 Saved ${_products.length} products to cache');
          }
        }

        // ✅ Precache images after loading
        // (You’ll need to pass BuildContext when calling fetchProducts)
        // await _precacheProductImages(context, response.data!);

        _hasMoreProducts = response.data!.length >= 10;

        if (loadMore) {
          _currentPage++;
          _isLoadingMore = false;
        }

        _errorMessage = null;

        if (kDebugMode) {
          print(
          '🔵 Total products: ${_products.length}, hasMore: $_hasMoreProducts',
        );
        }
      } else {
        _errorMessage = response.message;
        if (!loadMore && !_cacheService.hasCache()) {
          _products = [];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error: $e');
      }
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
  Future<void> refreshProducts({required BuildContext context}) async {
    await fetchProducts(context: context);
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

  // // Search products (works offline)
  // List<Product> searchProducts(String query) {
  //   if (query.isEmpty) {
  //     return [];
  //   }

  //   final lowerQuery = query.toLowerCase();

  //   return _products.where((product) {
  //     final nameMatch = product.name.toLowerCase().contains(lowerQuery);
  //     final descMatch = product.description.toLowerCase().contains(lowerQuery);
  //     final categoryMatch =
  //         product.category?.toLowerCase().contains(lowerQuery) ?? false;
  //     final skuMatch = product.sku?.toLowerCase().contains(lowerQuery) ?? false;

  //     return nameMatch || descMatch || categoryMatch || skuMatch;
  //   }).toList();
  // }
  // ✅ Search products via API
  Future<void> searchProducts(String query) async {
    // If query is empty, clear results
    if (query.trim().isEmpty) {
      _searchResults = [];
      _lastSearchQuery = '';
      _searchError = null;
      notifyListeners();
      return;
    }

    // Avoid duplicate searches
    if (query == _lastSearchQuery && _isSearching) {
      return;
    }

    _lastSearchQuery = query;
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔍 Searching for: $query');
      }

      final response = await _apiService.searchProducts(
        query,
        page: 1,
        perPage: 50, // Get more results for search
      );

      if (response.success && response.data != null) {
        _searchResults = response.data!;
        _searchError = null;

        if (kDebugMode) {
          print('🔍 Found ${_searchResults.length} results');
        }
      } else {
        _searchResults = [];
        _searchError = response.message;
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Search error: $e');
      }
      _searchResults = [];
      _searchError = 'Search failed. Please try again.';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // ✅ Clear search results
  void clearSearch() {
    _searchResults = [];
    _lastSearchQuery = '';
    _searchError = null;
    _isSearching = false;
    notifyListeners();
  }

  Future<void> init() async {
   await Hive.openBox<Product>('products');
  notifyListeners();
}
}
