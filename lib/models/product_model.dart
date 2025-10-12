import 'package:hive/hive.dart';

part 'product_model.g.dart'; // ✅ Add this line

@HiveType(typeId: 2) // ✅ Add this
class Product {
  @HiveField(0) // ✅ Add this before each field
  final String id;
  @HiveField(1) // ✅ Add this before each field
  final String name;
  @HiveField(2) // ✅ Add this before each field
  final String description;
  @HiveField(3) // ✅ Add this before each field
  final double price;
  @HiveField(4) // ✅ Add this before each field
  final double? mrp;
  @HiveField(5) // ✅ Add this before each field
  final int? discountPercentage;
  @HiveField(6) // ✅ Add this before each field
  final String imageUrl;
  @HiveField(7) // ✅ Add this before each field
  final String? category;
  @HiveField(8) // ✅ Add this before each field
  final String stockStatus;
  @HiveField(9) // ✅ Add this before each field
  final double? rating;
  @HiveField(10) // ✅ Add this before each field
  final bool prescriptionRequired;

  @HiveField(11) // ✅ Add this before each field
  // ✅ NEW FIELDS
  final String? shortDescription;
  @HiveField(12) // ✅ Add this before each field
  final String? sku;
  @HiveField(13) // ✅ Add this before each field
  final bool onSale;
  @HiveField(14) // ✅ Add this before each field
  final List<ProductImage> images;
  @HiveField(15) // ✅ Add this before each field
  final List<ProductCategory> categories;
  @HiveField(16) // ✅ Add this before each field
  final String? permalink;
  @HiveField(17) // ✅ Add this before each field
  final bool featured;
  @HiveField(18) // ✅ Add this before each field
  final int? totalSales;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.mrp,
    this.discountPercentage,
    required this.imageUrl,
    this.category,
    this.stockStatus = 'in_stock',
    this.rating,
    this.prescriptionRequired = false,

    // ✅ NEW PARAMETERS
    this.shortDescription,
    this.sku,
    this.onSale = false,
    this.images = const [],
    this.categories = const [],
    this.permalink,
    this.featured = false,
    this.totalSales,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ Parse all images for gallery
    List<ProductImage> allImages = [];
    if (json['images'] != null && json['images'] is List) {
      allImages = (json['images'] as List)
          .map((img) => ProductImage.fromJson(img as Map<String, dynamic>))
          .toList();
    }

    // Get first image URL (for backward compatibility)
    String imageUrl = '';
    if (allImages.isNotEmpty) {
      imageUrl = allImages[0].src;
    }

    // ✅ Parse all categories
    List<ProductCategory> allCategories = [];
    if (json['categories'] != null && json['categories'] is List) {
      allCategories = (json['categories'] as List)
          .map((cat) => ProductCategory.fromJson(cat as Map<String, dynamic>))
          .toList();
    }

    // Get first category name (for backward compatibility)
    String? category;
    if (allCategories.isNotEmpty) {
      category = allCategories[0].name;
    }

    // Parse price
    double price = 0.0;
    if (json['price'] != null && json['price'].toString().isNotEmpty) {
      price = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    // Parse regular price (MRP)
    double? mrp;
    if (json['regular_price'] != null &&
        json['regular_price'].toString().isNotEmpty) {
      mrp = double.tryParse(json['regular_price'].toString());
    }

    // Calculate discount percentage
    int? discountPercentage;
    if (mrp != null && mrp > 0 && price > 0 && price < mrp) {
      discountPercentage = (((mrp - price) / mrp) * 100).round();
    }

    // Parse rating
    double? rating;
    if (json['average_rating'] != null &&
        json['average_rating'].toString().isNotEmpty) {
      rating = double.tryParse(json['average_rating'].toString());
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: price,
      mrp: mrp,
      discountPercentage: discountPercentage,
      imageUrl: imageUrl,
      category: category,
      stockStatus: json['stock_status']?.toString() ?? 'instock',
      rating: rating,
      prescriptionRequired: false,

      // ✅ NEW FIELDS
      shortDescription: json['short_description']?.toString(),
      sku: json['sku']?.toString(),
      onSale: json['on_sale'] ?? false,
      images: allImages,
      categories: allCategories,
      permalink: json['permalink']?.toString(),
      featured: json['featured'] ?? false,
      totalSales: json['total_sales'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'mrp': mrp,
      'discount_percentage': discountPercentage,
      'image_url': imageUrl,
      'category': category,
      'stock_status': stockStatus,
      'rating': rating,
      'prescription_required': prescriptionRequired,

      // ✅ ADD THESE
      'short_description': shortDescription,
      'sku': sku,
      'on_sale': onSale,
      'images': images.map((img) => img.toJson()).toList(),
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'permalink': permalink,
      'featured': featured,
      'total_sales': totalSales,
    };
  }

  // Helper method to safely parse double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Computed properties
  bool get isInStock => stockStatus.toLowerCase() == 'in_stock';
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get formattedMrp => mrp != null ? '₹${mrp!.toStringAsFixed(0)}' : '';

  // Check if SKU exists
  bool get hasSku => sku != null && sku!.isNotEmpty;
  List<String> get allImageUrls => images.map((img) => img.src).toList();
  List<String> get allCategoryNames =>
      categories.map((cat) => cat.name).toList();
  bool get hasMultipleImages => images.length > 1;
  // Get short or full description
  String get displayDescription =>
      shortDescription?.isNotEmpty == true ? shortDescription! : description;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? mrp,
    int? discountPercentage,
    String? imageUrl,
    String? category,
    String? stockStatus,
    double? rating,
    bool? prescriptionRequired,

    // ✅ ADD THESE
    String? shortDescription,
    String? sku,
    bool? onSale,
    List<ProductImage>? images,
    List<ProductCategory>? categories,
    String? permalink,
    bool? featured,
    int? totalSales,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stockStatus: stockStatus ?? this.stockStatus,
      rating: rating ?? this.rating,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,

      // ✅ ADD THESE
      shortDescription: shortDescription ?? this.shortDescription,
      sku: sku ?? this.sku,
      onSale: onSale ?? this.onSale,
      images: images ?? this.images,
      categories: categories ?? this.categories,
      permalink: permalink ?? this.permalink,
      featured: featured ?? this.featured,
      totalSales: totalSales ?? this.totalSales,
    );
  }
}

// Helper class for product images
@HiveType(typeId: 0)
class ProductImage {
  @HiveField(0) // ✅ Add this
  final int id;
  @HiveField(1) // ✅ Add this
  final String src;
  @HiveField(2) // ✅ Add this
  final String? alt;

  ProductImage({required this.id, required this.src, this.alt});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      src: json['src'] ?? '',
      alt: json['alt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'src': src, 'alt': alt};
  }
}

// Helper class for product categories
@HiveType(typeId: 1) // ✅ Add this
class ProductCategory {
  @HiveField(0) // ✅ Add this
  final int id;
  @HiveField(1) // ✅ Add this
  final String name;
  @HiveField(2) // ✅ Add this
  final String slug;

  ProductCategory({required this.id, required this.name, required this.slug});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
