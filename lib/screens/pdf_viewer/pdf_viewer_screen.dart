import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatelessWidget {
  final File pdfFile;
  final String productName;

  const PdfViewerScreen({
    super.key,
    required this.pdfFile,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Brochure',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              productName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'Share PDF',
            onPressed: () => _sharePdf(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PdfPreview(
        // Use the cached file bytes — avoids regenerating the PDF
        build: (_) async {
          final Uint8List bytes = await pdfFile.readAsBytes();
          return bytes;
        },
        // Clean, minimal toolbar — user just needs the page view
        allowSharing: false,  // We have our own share button
        allowPrinting: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: '${productName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_brochure.pdf',
        actions: const [],
        loadingWidget: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Loading PDF...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final XFile xFile = XFile(pdfFile.path, mimeType: 'application/pdf');
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Check out this product brochure from Curemix Healthcare!',
          subject: '$productName - Curemix Brochure',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not share PDF. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
