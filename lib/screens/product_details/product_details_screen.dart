import 'package:curemix_healtcare_flutter_app/widgets/image_fullscreen_viewer.dart';
import 'package:curemix_healtcare_flutter_app/widgets/product_image_gallery.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../core/constants/app_colors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.share_outlined),
          //   onPressed: () {
          //     // TODO: Implement share
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.favorite_border),
          //   onPressed: () {
          //     // TODO: Implement wishlist
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel
                  _buildImageCarousel(),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Rating
                        if (widget.product.rating != null)
                          _buildRatingSection(),

                        const SizedBox(height: 16),

                        // Price Section
                        // _buildPriceSection(),
                        const SizedBox(height: 16),

                        // Stock & SKU
                        // _buildStockAndSku(),
                        const SizedBox(height: 16),

                        // Categories
                        if (widget.product.categories.isNotEmpty)
                          _buildCategoriesSection(),

                        const SizedBox(height: 20),

                        // Divider
                        const Divider(),

                        const SizedBox(height: 16),

                        // Description
                        _buildDescriptionSection(),

                        const SizedBox(height: 80), // Space for fixed button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Add to Cart Button
          // _buildAddToCartButton(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images.map((e) => e.src).toList()
        : [widget.product.imageUrl];

    return Container(
      color: Colors.grey.shade50,
      height: 380,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ImageFullscreenViewer(
                      imageUrls: images,
                      initialIndex: _currentImageIndex,
                    ),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: ProductImageGallery(
                imageUrls: images,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: images.length,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppColors.primary,
                  dotColor: Colors.grey.shade300,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // // Image Carousel Widget using PageView
  // Widget _buildImageCarousel() {
  //   final images = widget.product.images.isNotEmpty
  //       ? widget.product.images
  //       : [ProductImage(id: 0, src: widget.product.imageUrl)];

  //   return Container(
  //     color: Colors.grey.shade50,
  //     height: 380,
  //     child: Column(
  //       children: [
  //         Expanded(
  //           child: PageView.builder(
  //             controller: _pageController,
  //             itemCount: images.length,
  //             onPageChanged: (index) {
  //               setState(() {
  //                 _currentImageIndex = index;
  //               });
  //             },
  //             itemBuilder: (context, index) {
  //               return GestureDetector(
  //                 onTap: () {
  //                   // TODO: Open full screen image viewer
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16),
  //                   child: CachedNetworkImage(
  //                     memCacheWidth: 400, // ✅ Resize for memory efficiency
  //                     memCacheHeight: 400, // ✅ Resize for memory efficiency
  //                     fadeInDuration: const Duration(
  //                       milliseconds: 200,
  //                     ), // ✅ Faster fade
  //                     imageUrl: images[index].src,
  //                     fit: BoxFit.contain,
  //                     cacheKey: images[index].id.toString(),
  //                     placeholder: (context, url) => Container(
  //                       color: Colors.grey.shade200,
  //                       child: const Center(
  //                         child: CircularProgressIndicator(),
  //                       ),
  //                     ),
  //                     errorWidget: (context, url, error) => Container(
  //                       color: Colors.grey.shade200,
  //                       child: const Icon(
  //                         Icons.image_not_supported,
  //                         size: 60,
  //                         color: Colors.grey,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),

  //         // Image Indicators
  //         if (images.length > 1) ...[
  //           const SizedBox(height: 12),
  //           SmoothPageIndicator(
  //             controller: _pageController,
  //             count: images.length,
  //             effect: WormEffect(
  //               dotHeight: 8,
  //               dotWidth: 8,
  //               activeDotColor: AppColors.primary,
  //               dotColor: Colors.grey.shade300,
  //             ),
  //             onDotClicked: (index) {
  //               _pageController.animateToPage(
  //                 index,
  //                 duration: const Duration(milliseconds: 300),
  //                 curve: Curves.easeIn,
  //               );
  //             },
  //           ),
  //           const SizedBox(height: 16),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // Rating Section
  Widget _buildRatingSection() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          widget.product.rating!.toStringAsFixed(1),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          '(${widget.product.totalSales ?? 0} reviews)',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Price Section
  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Current Price
          Text(
            widget.product.formattedPrice,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          // MRP (strikethrough)
          if (widget.product.mrp != null && widget.product.hasDiscount) ...[
            Text(
              widget.product.formattedMrp,
              style: TextStyle(
                fontSize: 18,
                decoration: TextDecoration.lineThrough,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),

            // Discount Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${widget.product.discountPercentage}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Stock and SKU Section
  Widget _buildStockAndSku() {
    return Row(
      children: [
        // Stock Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.product.isInStock
                ? Colors.green.shade50
                : Colors.red.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.product.isInStock
                  ? Colors.green.shade200
                  : Colors.red.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.product.isInStock ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: widget.product.isInStock ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                widget.product.isInStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.product.isInStock
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),

        // SKU
        if (widget.product.hasSku) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'SKU: ${widget.product.sku}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ],
    );
  }

  // Categories Section
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.product.categories.map((category) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Description Section
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Short Description
        if (widget.product.shortDescription != null &&
            widget.product.shortDescription!.isNotEmpty) ...[
          Text(
            _stripHtmlTags(widget.product.shortDescription!),
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Full Description
        if (widget.product.description.isNotEmpty)
          Text(
            _stripHtmlTags(widget.product.description),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
      ],
    );
  }

  // Add to Cart Button
  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.product.isInStock
                ? () {
                    // TODO: Add to cart functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.name} added to cart'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.product.isInStock
                      ? 'Add to Cart - ${widget.product.formattedPrice}'
                      : 'Out of Stock',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Strip HTML tags from description
  String _stripHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '').trim();
  }
}
