import 'dart:io';
import '../models/product_model.dart';
import 'pdf/product_pdf_service.dart';
import 'package:path_provider/path_provider.dart';

class PdfGeneratorService {
  
  /// Proxy wrapper to protect legacy UI calls from breaking.
  /// Delegates generation to the new highly-optimized multi-product framework.
  static Future<File> generateProductPdf(Product product) async {
    return await ProductPdfService.generatePdf([product]);
  }

  static Future<File> savePdfToDownloads(Product product) async {
    try {
      final saveStopwatch = Stopwatch()..start();
      print('🚀 [Download Service] Initiating PDF download request...');
      
      // 1. Validate Generate
      final sourceFile = await generateProductPdf(product);
      if (!sourceFile.existsSync() || await sourceFile.length() == 0) {
        throw Exception('The generated PDF file is missing or empty.');
      }

      // 2. Resolve Path based on Platform
      String? newPath;
      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          try {
            directory.createSync(recursive: true);
          } catch (e) {
            // Android 11+ scoped storage fallback
            final appDir = await getExternalStorageDirectory();
            if (appDir != null) newPath = '${appDir.path}/${sourceFile.path.split('/').last}';
          }
        }
        newPath ??= '${directory.path}/${sourceFile.path.split('/').last}';
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        newPath = '${directory.path}/${sourceFile.path.split('/').last}';
      } else {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          newPath = '${directory.path}/${sourceFile.path.split('/').last}';
        }
      }

      if (newPath == null) {
        throw Exception('Could not resolve download path for this device platform.');
      }

      // 3. Save via FileSystem
      final savedFile = await sourceFile.copy(newPath);
      
      saveStopwatch.stop();
      print('💾 [Download Service] Successfully copied to public downloads in ${saveStopwatch.elapsedMilliseconds}ms.');
      return savedFile;
      
    } on FileSystemException catch (e) {
      if (e.message.toLowerCase().contains('permission denied')) {
        throw Exception('Storage permission denied. Please allow file access to save PDFs.');
      }
      throw Exception('File Error: ${e.message}');
    } catch (e) {
      print('❌ [Download Service] Save error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
