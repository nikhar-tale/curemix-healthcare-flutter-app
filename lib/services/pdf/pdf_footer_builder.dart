import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_constants.dart';

class PdfFooterBuilder {
  static pw.Widget build(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 25),
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#006666'), // Darker Teal
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Left: QR Code + CTA
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(4)),
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: 'https://wa.me/${PdfConstants.branchPhone}',
                  width: 35,
                  height: 35,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Scan to Order', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 2),
                  pw.Text(PdfConstants.websiteUrl, style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#B2DFDB'))), // Light Teal Text
                ]
              )
            ]
          ),
          
          // Right: Branding & Pagination
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Curemix Healthcare - Trust & Care',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#B2DFDB')),
              ),
            ]
          )
        ]
      )
    );
  }
}

