import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PdfImageOptimizer {
  /// Resolves an optimized image for the PDF. 
  /// Resizes large images efficiently reducing memory and output file size.
  static Future<pw.ImageProvider?> resolveOptimizedImage(String url, {int width = 1000}) async {
    if (url.isEmpty) return null;
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      
      // Native flutter resize before giving it to pdf compress stream
      final provider = ResizeImage(FileImage(file), width: width);
      return await flutterImageProvider(provider);
    } catch (e) {
      print('PdfImageOptimizer failed to load image $url: $e');
      return null;
    }
  }

  /// Resolves multiple URLs concurrently into a list of exact pw.ImageProviders
  static Future<List<pw.ImageProvider>> resolveMultiple(List<String> urls, {int width = 1000, int maxImages = 4}) async {
    final validUrls = urls.where((url) => url.isNotEmpty).take(maxImages).toList();
    if (validUrls.isEmpty) return [];

    final futures = validUrls.map((url) => resolveOptimizedImage(url, width: width));
    final resolved = await Future.wait(futures);
    
    return resolved.whereType<pw.ImageProvider>().toList();
  }
}
