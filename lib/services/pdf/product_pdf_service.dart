import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../models/product_model.dart';

import 'pdf_template_builder.dart';
import 'pdf_header_builder.dart';
import 'pdf_footer_builder.dart';
import 'pdf_image_optimizer.dart';

class ProductPdfService {
  static pw.Font? _cachedFontRegular;
  static pw.Font? _cachedFontBold;
  static pw.MemoryImage? _cachedLogo;

  static Future<void> _initResources() async {
    _cachedFontRegular ??= await PdfGoogleFonts.robotoRegular();
    _cachedFontBold ??= await PdfGoogleFonts.robotoBold();

    if (_cachedLogo == null) {
      try {
        final ByteData bytes = await rootBundle.load(
          'assets/images/curemix_logo.webp',
        );
        _cachedLogo = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {}
    }
  }

  /// Generates a highly optimized PDF for a single product or a multiple product catalog.
  static Future<File> generatePdf(List<Product> products) async {
    final stopwatch = Stopwatch()..start();
    print('🚀 [PDF Engine] Started generation pipeline...');

    final pdf = pw.Document(compress: true);

    await _initResources();

    final theme = pw.ThemeData.withFont(
      base: _cachedFontRegular,
      bold: _cachedFontBold,
    );

    for (var product in products) {
      // 1. Fetch Main Image (High Quality - 600px width)
      final fetchStopwatch = Stopwatch()..start();
      pw.ImageProvider? mainResolved;
      if (product.images.isNotEmpty && product.images.first.src.isNotEmpty) {
        mainResolved = await PdfImageOptimizer.resolveOptimizedImage(
          product.images.first.src,
          width: 600,
        );
      } else if (product.imageUrl.isNotEmpty) {
        mainResolved = await PdfImageOptimizer.resolveOptimizedImage(
          product.imageUrl,
          width: 600,
        );
      }

      // 2. Fetch Gallery Images (Low Quality - 300px width)
      // The gallery images are rendered much smaller, so scaling them down to 300px drastically cuts file size.
      List<pw.ImageProvider> galleryResolved = [];
      if (product.images.length > 1) {
        final galleryUrls = product.images
            .skip(1)
            .where((i) => i.src.isNotEmpty)
            .map((i) => i.src)
            .take(3)
            .toList();

        galleryResolved = await PdfImageOptimizer.resolveMultiple(
          galleryUrls,
          width: 300,
        );
      }

      // Combine for the template builder
      final resolvedImages = <pw.ImageProvider>[];
      if (mainResolved != null) resolvedImages.add(mainResolved);
      resolvedImages.addAll(galleryResolved);
      
      print('⏱️ [PDF Engine] Downloaded & Optimized ${resolvedImages.length} images in ${fetchStopwatch.elapsedMilliseconds}ms.');

      // Page 1: Main Product Brochure Page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: theme,
          header: (pw.Context context) => PdfHeaderBuilder.build(_cachedLogo),
          footer: (pw.Context context) => PdfFooterBuilder.build(context),
          build: (pw.Context context) {
            return PdfTemplateBuilder.buildProductPage(product, resolvedImages);
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final sanitizedName = products.length == 1
        ? products.first.name
              .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
              .toLowerCase()
        : 'curemix_catalog';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${output.path}/${sanitizedName}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    stopwatch.stop();
    print('✅ [PDF Engine] PDF successfully compiled and saved to cache in ${stopwatch.elapsedMilliseconds}ms.');

    return file;
  }
}
