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
  
  // Search Pagination State
  int _searchCurrentPage = 1;
  bool _hasMoreSearchResults = false;
  bool _isLoadingMoreSearch = false;

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
  bool get isLoadingMore => _isLoadingMore;

  // ✅ ADD THESE getters
  List<Product> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  bool get isLoadingMoreSearch => _isLoadingMoreSearch;
  bool get hasMoreSearchResults => _hasMoreSearchResults;

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
          // ✅ Merge paginated items into local cache without wiping
          await _cacheService.saveProducts(response.data!, clearFirst: false);
        } else {
          _products = response.data!;

          // ✅ Save fresh data to cache, wiping old
          await _cacheService.saveProducts(_products, clearFirst: true);
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
  // ✅ Search products via API (with Pagination)
  Future<void> searchProducts(String query, {bool loadMore = false}) async {
    // If query is empty, clear results
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    // Avoid duplicate searches or overlapping loads
    if (query == _lastSearchQuery && _isSearching && !loadMore) return;
    if (loadMore && _isLoadingMoreSearch) return;
    if (loadMore && !_hasMoreSearchResults) return;
    
    if (!loadMore) {
      _lastSearchQuery = query;
      _isSearching = true;
      _searchCurrentPage = 1;
      _hasMoreSearchResults = false;
      _searchResults = [];
    } else {
      _isLoadingMoreSearch = true;
    }
    
    _searchError = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔍 Searching for: $query, page: $_searchCurrentPage');
      }

      final response = await _apiService.searchProducts(
        query,
        page: _searchCurrentPage,
        perPage: 20, // 20 results per page for search
      );

      // ✅ Race Condition Guard: If the user typed a new query while this one was executing,
      // discard this response immediately to prevent UI from showing mismatched results.
      if (!loadMore && _lastSearchQuery != query) {
        if (kDebugMode) print('🔍 Discarding stale search results for: $query');
        return;
      }

      if (response.success && response.data != null) {
        if (loadMore) {
          _searchResults.addAll(response.data!);
        } else {
          _searchResults = response.data!;
        }
        
        _hasMoreSearchResults = response.data!.length >= 20;

        if (loadMore) {
          _searchCurrentPage++;
        } else if (_hasMoreSearchResults) {
           _searchCurrentPage++;
        }
        _searchError = null;

        if (kDebugMode) {
          print('🔍 Found ${_searchResults.length} total results. HasMore: $_hasMoreSearchResults');
        }
      } else {
        if (!loadMore) _searchResults = [];
        _searchError = response.message;
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Search error: $e');
      }
      if (!loadMore) _searchResults = [];
      _searchError = 'Search failed. Please try again.';
    } finally {
      if (loadMore) {
        _isLoadingMoreSearch = false;
      } else {
        _isSearching = false;
      }
      notifyListeners();
    }
  }

  // ✅ Clear search results
  void clearSearch() {
    _searchResults = [];
    _lastSearchQuery = '';
    _searchError = null;
    _isSearching = false;
    _searchCurrentPage = 1;
    _hasMoreSearchResults = false;
    _isLoadingMoreSearch = false;
    notifyListeners();
  }

  Future<void> init() async {
   await Hive.openBox<Product>('products');
  notifyListeners();
}
}
