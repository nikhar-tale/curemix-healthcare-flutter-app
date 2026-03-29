import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/image_cache_manager.dart';
import '../../../models/product_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/pdf_generator_service.dart';
import '../../../core/utils/notification_helper.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Keep widget alive when scrolling

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // ✅ Must call super when using AutomaticKeepAliveClientMixin

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      // cacheManager setup
                      cacheManager: ImageCacheManager.instance, // ✅ Global cache
                      cacheKey: widget.product.id, // ✅ Explicit cache key
                      memCacheWidth: 400, // ✅ Resize for memory efficiency
                      memCacheHeight: 400, // ✅ Resize for memory efficiency
                      fadeInDuration: const Duration(
                        milliseconds: 200,
                      ), // ✅ Faster fade
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.medical_services,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Quick Share Button (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          try {
                            final file = await NotificationHelper.runWithSmoothProgress(
                              title: 'Preparing PDF for Sharing...',
                              task: () => PdfGeneratorService.generateProductPdf(widget.product),
                            );

                            await Share.shareXFiles(
                              [XFile(file.path)],
                              text: 'Check out this product: ${widget.product.name}',
                            );
                          } catch (e) {
                            print('Error sharing product PDF: $e');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.share,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (widget.product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
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
                    ),

                  // Prescription Required Badge
                  if (widget.product.prescriptionRequired)
                    Positioned(
                      top: 38,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.note_alt_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Visual Stock Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.product.isInStock
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.product.isInStock ? 'IN STOCK' : 'OUT OF STOCK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Category
                    if (widget.product.category != null)
                      Text(
                        widget.product.category!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),

                    // Packaging / Short Desc
                    if (widget.product.shortDescription != null &&
                        widget.product.shortDescription!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          widget.product.shortDescription!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Price Row
                    if (widget.product.price > 0)
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

