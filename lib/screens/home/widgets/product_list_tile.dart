import 'package:flutter/material.dart';
import '../../../../models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/pdf_generator_service.dart';
import '../../../../core/utils/notification_helper.dart';
import '../../../../core/utils/image_cache_manager.dart';

class ProductListTile extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Keep list items alive when scrolling

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Must call super

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Compact Image
            Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.contain,
                  cacheManager: ImageCacheManager.instance,
                  cacheKey: widget.product.id,
                  memCacheWidth: 400,
                  memCacheHeight: 400,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right: Dense Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges Row
                      Row(
                        children: [
                          if (widget.product.prescriptionRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: const Text(
                                'Rx',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          if (widget.product.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.product.category!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Stock Status
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, size: 18, color: AppColors.primary),
                            onPressed: () async {
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
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            widget.product.isInStock
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: widget.product.isInStock ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Price row (which was hidden in GridView)
                  if(widget.product.price > 0)
                  Row(
                    children: [
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (widget.product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          widget.product.formattedMrp,
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.product.discountPercentage}% OFF',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
