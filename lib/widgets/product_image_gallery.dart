import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ProductImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final bool isFullscreen;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;

  const ProductImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.isFullscreen = false,
    this.controller,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final PageController pageController =
        controller ?? PageController(initialPage: initialIndex);

    // Fullscreen version
    if (isFullscreen) {
      return PhotoViewGallery.builder(
        pageController: pageController,
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(imageUrls[index]),
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          );
        },
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        onPageChanged: onPageChanged,
      );
    }

    // Normal in-page carousel
    return PageView.builder(
      controller: pageController,
      itemCount: imageUrls.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Hero(
          tag: imageUrls[index],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              memCacheWidth: 400,
              memCacheHeight: 400,
              fadeInDuration: const Duration(milliseconds: 200),
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
