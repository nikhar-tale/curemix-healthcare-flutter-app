import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_constants.dart';
import 'pdf_text_utils.dart';

class PdfFooterBuilder {
  static pw.Widget build(pw.Context context, {pw.Font? icons, pw.MemoryImage? playStoreLogo, pw.Font? fontRegular, pw.Font? fontBold}) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // 1. Promotional App Banner
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 25, bottom: 8),
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#E0F2F1'), // Very light teal
            border: pw.Border.all(color: PdfColor.fromHex('#004D40'), width: 1),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // 1. Play Store Logo (PNG from user)
              if (playStoreLogo != null)
                pw.Image(
                  playStoreLogo,
                  width: 18,
                  height: 18,
                )
              else if (icons != null)
                // Fallback to Icon if PNG fails to load
                pw.Icon(
                  const pw.IconData(0xe037), // play_arrow
                  font: icons,
                  size: 14,
                  color: PdfColor.fromHex('#4CAF50'), // Store Green
                ),
              pw.SizedBox(width: 6),
              pw.Text(
                PdfTextUtils.clean('Available on Google Play | '),
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#004D40'),
                ),
              ),
              pw.Text(
                PdfTextUtils.clean('Download to explore 1000+ products!'),
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 10,
                  color: PdfColor.fromHex('#004D40'),
                ),
              ),
              pw.SizedBox(width: 10),
              // Tiny Store QR Code
              pw.Container(
                padding: const pw.EdgeInsets.all(2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: PdfConstants.googlePlayUrl,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),

        // 2. Existing Footer
        pw.Container(
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
                      pw.Text(PdfTextUtils.clean('Scan to Order'), style: pw.TextStyle(font: fontBold, fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.SizedBox(height: 2),
                      pw.Text(PdfTextUtils.clean(PdfConstants.websiteUrl), style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColor.fromHex('#B2DFDB'))), // Light Teal Text
                    ]
                  )
                ]
              ),
              
                pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                  PdfTextUtils.clean('Curemix Healthcare - Trust & Care'),
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white, // Fixed: was #00796B (invisible on dark teal)
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  PdfTextUtils.clean('Address: 123 Pharma Park, Ahmedabad, Gujarat'),
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 8,
                    color: PdfColor.fromHex('#B2DFDB'), // Light teal — visible on dark teal
                  ),
                ),]
              )
            ]
          )
        ),
      ],
    );
  }
}

