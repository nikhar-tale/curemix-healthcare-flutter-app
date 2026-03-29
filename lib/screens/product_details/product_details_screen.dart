import 'package:curemix_healtcare_flutter_app/widgets/image_fullscreen_viewer.dart';
import 'package:curemix_healtcare_flutter_app/widgets/product_image_gallery.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../models/product_model.dart';
import '../../core/constants/app_colors.dart';
import '../../services/pdf_generator_service.dart';
import '../../core/utils/notification_helper.dart';
import '../../main.dart';
import '../../core/utils/responsive_helper.dart';
import '../pdf_viewer/pdf_viewer_screen.dart';

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
        centerTitle: true,
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                final savedFile = await NotificationHelper.runWithSmoothProgress<File>(
                  title: 'Downloading Product PDF...',
                  task: () => PdfGeneratorService.savePdfToDownloads(widget.product),
                );

                NotificationHelper.showProgressSnackBar(
                  title: 'Download Complete!',
                  progressNotifier: ValueNotifier(1.0),
                  onViewPdf: () {
                    CuremixApp.navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          pdfFile: savedFile,
                          productName: widget.product.name,
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                if (context.mounted) {
                  NotificationHelper.showNotification(
                    'Failed to generate PDF. Please try again.',
                    isError: true,
                  );
                }
                debugPrint('Error downloading product PDF: $e');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to wishlist')),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = ResponsiveHelper.isTablet(context);
          
          if (isTablet) {
            return _buildTabletLayout();
          }
          
          return _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(),
                _buildProductInfo(),
              ],
            ),
          ),
        ),
        _buildStickyBottomBar(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildImageCarousel(isTablet: true),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        Container(width: 1, color: Colors.grey.shade200),

        Expanded(
          flex: 6,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _buildProductInfo(isTablet: true),
                ),
              ),
              _buildStickyBottomBar(isTablet: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo({bool isTablet = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: TextStyle(
            fontSize: isTablet ? 32 : 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        if (widget.product.rating != null)
          _buildRatingSection(isTablet: isTablet),

        const SizedBox(height: 16),

        _buildPriceSection(isTablet: isTablet),
        const SizedBox(height: 16),

        if (widget.product.categories.isNotEmpty)
          _buildCategoriesSection(isTablet: isTablet),

        const SizedBox(height: 20),

        const Divider(),

        const SizedBox(height: 16),

        _buildDescriptionSection(isTablet: isTablet),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImageCarousel({bool isTablet = false}) {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images.map((e) => e.src).toList()
        : [widget.product.imageUrl];

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: isTablet ? 450 : 320,
            child: Stack(
              children: [
                GestureDetector(
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

                Positioned(
                  bottom: 12,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Tap to zoom',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

                if (images.length > 1)
                  Positioned(
                    top: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (images.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = _currentImageIndex == index;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          memCacheWidth: 100,
                          memCacheHeight: 100,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSection({bool isTablet = false}) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: isTablet ? 24 : 18),
        const SizedBox(width: 4),
        Text(
          widget.product.rating!.toStringAsFixed(1),
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${widget.product.totalSales ?? 0} sold)',
          style: TextStyle(
            fontSize: isTablet ? 16 : 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection({bool isTablet = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(
            widget.product.formattedPrice,
            style: TextStyle(
              fontSize: isTablet ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

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

  Widget _buildCategoriesSection({bool isTablet = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
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
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: isTablet ? 15 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection({bool isTablet = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Product Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Short Description (Highlights)
              if (widget.product.shortDescription != null &&
                  widget.product.shortDescription!.isNotEmpty) ...[
                Text(
                  _stripHtmlTags(widget.product.shortDescription!),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
              ],

              // Full Description
              if (widget.product.description.isNotEmpty)
                Text(
                  _stripHtmlTags(widget.product.description),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: Colors.grey.shade800,
                  ),
                ),
              
              if (widget.product.description.isEmpty && (widget.product.shortDescription == null || widget.product.shortDescription!.isEmpty))
                const Text(
                  'No description available for this product.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Specifications / More Info
        Row(
          children: [
            const Icon(Icons.list_alt_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSpecRow('SKU', widget.product.sku ?? 'N/A'),
              const Divider(height: 24),
              _buildSpecRow('Categories', widget.product.allCategoryNames.join(', ')),
              const Divider(height: 24),
              _buildSpecRow('Stock Status', widget.product.isInStock ? 'In Stock' : 'Out of Stock'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Sticky Bottom Bar
  Widget _buildStickyBottomBar({bool isTablet = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isTablet ? Border(top: BorderSide(color: Colors.grey.shade200)) : null,
        boxShadow: isTablet ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !isTablet,
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.product.mrp != null && widget.product.hasDiscount)
                    Text(
                      widget.product.formattedMrp,
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (widget.product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.product.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Stock Badge (compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.product.isInStock
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.product.isInStock
                      ? Colors.green.shade300
                      : Colors.red.shade300,
                ),
              ),
              child: Text(
                widget.product.isInStock ? 'In Stock' : 'Out',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.product.isInStock
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Share Button (primary action)
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final file = await NotificationHelper.runWithSmoothProgress(
                    title: 'Preparing PDF for Sharing...',
                    task: () => PdfGeneratorService.generateProductPdf(widget.product),
                  );

                  await Share.shareXFiles([
                    XFile(file.path),
                  ], text: 'Check out this product: ${widget.product.name}');
                } catch (e) {
                  print('Error sharing product PDF: $e');
                }
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
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
