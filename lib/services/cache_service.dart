import 'package:hive/hive.dart';
import '../models/product_model.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Get products box
  Box<Product> get _productsBox => Hive.box<Product>('products');

  // Save products to cache
  Future<void> saveProducts(List<Product> products) async {
    await _productsBox.clear(); // Clear old data
    
    // Save with product ID as key
    for (var product in products) {
      await _productsBox.put(product.id, product);
    }
  }

  // Get cached products in reverse order
List<Product> getCachedProducts() {
  return _productsBox.values.toList().reversed.toList();
}

  // Check if cache exists
  bool hasCache() {
    return _productsBox.isNotEmpty;
  }

  // Get single product by ID
  Product? getProductById(String id) {
    return _productsBox.get(id);
  }

  // Clear cache
  Future<void> clearCache() async {
    await _productsBox.clear();
  }

  // Get cache timestamp (for refresh logic)
  DateTime? getLastCacheTime() {
    // You can store this separately if needed
    return null; // Implement if needed
  }
}