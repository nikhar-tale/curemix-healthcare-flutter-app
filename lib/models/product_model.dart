class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? mrp;
  final int? discountPercentage;
  final String imageUrl;
  final String? category;
  final String stockStatus;
  final double? rating;
  final bool prescriptionRequired;

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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Get first image or empty string
    String imageUrl = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['src'] ?? '';
    }
    
    // Get first category or null
    String? category;
    if (json['categories'] != null && (json['categories'] as List).isNotEmpty) {
      category = json['categories'][0]['name'];
    }
    
    // Parse price
    double price = 0.0;
    if (json['price'] != null && json['price'].toString().isNotEmpty) {
      price = double.tryParse(json['price'].toString()) ?? 0.0;
    }
    
    // Parse regular price (MRP)
    double? mrp;
    if (json['regular_price'] != null && json['regular_price'].toString().isNotEmpty) {
      mrp = double.tryParse(json['regular_price'].toString());
    }
    
    // Calculate discount percentage
    int? discountPercentage;
    if (mrp != null && mrp > 0 && price > 0 && price < mrp) {
      discountPercentage = (((mrp - price) / mrp) * 100).round();
    }
    
    // Parse rating
    double? rating;
    if (json['average_rating'] != null && json['average_rating'].toString().isNotEmpty) {
      rating = double.tryParse(json['average_rating'].toString());
    }
    
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? json['short_description']?.toString() ?? '',
      price: price,
      mrp: mrp,
      discountPercentage: discountPercentage,
      imageUrl: imageUrl,
      category: category,
      stockStatus: json['stock_status']?.toString() ?? 'instock',
      rating: rating,
      prescriptionRequired: false, // WooCommerce doesn't have this by default
    );
  }

  // To JSON
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
  
  // Copy with method for updates
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
    );
  }
}