import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
// Only import html for web
import 'dart:html' as html if (dart.library.io) 'dart:io';

import '../models/document.dart';

class ConversionResult {
  final bool success;
  final String? filePath;
  final Uint8List? fileBytes;
  final String? fileName;
  final String? error;

  ConversionResult({
    required this.success,
    this.filePath,
    this.fileBytes,
    this.fileName,
    this.error,
  });
}

class DocumentConversionService {
  Future<ConversionResult> convertDocument({
    required Document document,
    required String targetFormat,
    Uint8List? fileBytes, // Optional: pass file bytes directly for web
  }) async {
    try {
      final sourceExtension = _getFileExtension(document.fileName);
      
      // Get file data - either from passed bytes or by reading file
      final data = fileBytes ?? await _getFileData(document);
      
      switch ('${sourceExtension}_to_$targetFormat') {
        case 'pdf_to_jpg':
        case 'pdf_to_png':
          return await _convertPdfToImage(data, targetFormat);
        
        case 'jpg_to_pdf':
        case 'jpeg_to_pdf':
        case 'png_to_pdf':
          return await _convertImageToPdf(data, document.fileName);
        
        case 'jpg_to_png':
        case 'jpeg_to_png':
          return await _convertJpgToPng(data);
        
        case 'png_to_jpg':
          return await _convertPngToJpg(data);
        
        case 'doc_to_pdf':
        case 'docx_to_pdf':
          return await _convertWordToPdf(data);
        
        case 'txt_to_pdf':
          return await _convertTxtToPdf(data);
        
        default:
          return ConversionResult(
            success: false,
            error: 'Unsupported conversion type',
          );
      }
    } catch (e) {
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  Future<Uint8List> _getFileData(Document document) async {
    if (kIsWeb) {
      // For web, you might store file data in IndexedDB or memory
      // This is a placeholder - implement based on your storage method
      throw UnimplementedError('Implement web file retrieval based on your storage method');
    } else {
      // For Android, read from file system
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${document.fileName}');
      return await file.readAsBytes();
    }
  }

  Future<String?> _saveFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // On web, we don't save to file system
      return null;
    } else {
      // On Android, save to app documents directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }

  Future<ConversionResult> _convertPdfToImage(Uint8List pdfBytes, String format) async {
    try {
      // This is complex and requires platform-specific implementation
      // For a production app, consider:
      // 1. Server-side conversion API
      // 2. Platform channels for native implementation
      // 3. Using pdf_render package (has limitations)
      
      return ConversionResult(
        success: false,
        error: 'PDF to image conversion requires additional implementation. Consider using a server-side API.',
      );
    } catch (e) {
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ConversionResult> _convertImageToPdf(Uint8List imageBytes, String originalFileName) async {
    try {
      final pdf = pw.Document();
      
      // Decode image to get dimensions
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return ConversionResult(
          success: false,
          error: 'Failed to decode image',
        );
      }

      // Create PDF with image
      final pdfImage = pw.MemoryImage(imageBytes);
      
      // Calculate page size to fit image
      double width = image.width.toDouble();
      double height = image.height.toDouble();
      
      // Scale down if image is too large for A4
      final a4Width = PdfPageFormat.a4.width;
      final a4Height = PdfPageFormat.a4.height;
      
      if (width > a4Width || height > a4Height) {
        final scale = (a4Width / width).clamp(0.0, a4Height / height);
        width *= scale;
        height *= scale;
      }
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                width: width,
                height: height,
                child: pw.Image(pdfImage),
              ),
            );
          },
        ),
      );

      // Generate file name
      final baseFileName = originalFileName.split('.').first;
      final outputFileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      // Save PDF
      final pdfData = await pdf.save();
      final filePath = await _saveFile(pdfData, outputFileName);

      return ConversionResult(
        success: true,
        filePath: filePath,
        fileBytes: pdfData,
        fileName: outputFileName,
      );
    } catch (e) {
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ConversionResult> _convertJpgToPng(Uint8List jpgBytes) async {
    try {
      // Decode JPG
      final image = img.decodeJpg(jpgBytes);
      if (image == null) {
        return ConversionResult(
          success: false,
          error: 'Failed to decode JPG',
        );
      }

      // Encode as PNG
      final pngBytes = img.encodePng(image);
      final outputFileName = 'converted_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // Save file
      final filePath = await _saveFile(Uint8List.fromList(pngBytes), outputFileName);

      return ConversionResult(
        success: true,
        filePath: filePath,
        fileBytes: Uint8List.fromList(pngBytes),
        fileName: outputFileName,
      );
    } catch (e) {
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ConversionResult> _convertPngToJpg(Uint8List pngBytes) async {
    try {
      // Decode PNG
      final image = img.decodePng(pngBytes);
      if (image == null) {
        return ConversionResult(
          success: false,
          error: 'Failed to decode PNG',
        );
      }

      // Encode as JPG with good quality
      final jpgBytes = img.encodeJpg(image, quality: 90);
      final outputFileName = 'converted_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Save file
      final filePath = await _saveFile(Uint8List.fromList(jpgBytes), outputFileName);

      return ConversionResult(
        success: true,
        filePath: filePath,
        fileBytes: Uint8List.fromList(jpgBytes),
        fileName: outputFileName,
      );
    } catch (e) {
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ConversionResult> _convertWordToPdf(Uint8List wordBytes) async {
    try {
      // Word to PDF conversion requires:
      // 1. Server-side API (recommended for both web and mobile)
      // 2. Or use a cloud service like CloudConvert
      
      // Example implementation with a hypothetical API:
      /*
      final response = await http.post(
        Uri.parse('https://your-api.com/convert/word-to-pdf'),
        body: wordBytes,
        headers: {'Content-Type': 'application/octet-stream'},
      );
      
      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        final outputFileName = 'converted_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = await _saveFile(pdfBytes, outputFileName);
        
        return ConversionResult(
          success: true,
          filePath: filePath,
          fileBytes: pdfBytes,
          fileName: outputFileName,
        );
      }
      */
      
      return ConversionResult(
        success: false,
        error: 'Word to PDF conversion requires server-side implementation',
      );
    } catch (e) {
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ConversionResult> _convertTxtToPdf(Uint8List txtBytes) async {
    try {
      final pdf = pw.Document();
      final content = utf8.decode(txtBytes);
      
      // Split content into pages
      final lines = content.split('\n');
      const linesPerPage = 45;
      
      // Add custom font for better text rendering
      final font = await _loadFont();
      
      for (int i = 0; i < lines.length; i += linesPerPage) {
        final pageLines = lines.skip(i).take(linesPerPage).toList();
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Add page header
                  pw.Container(
                    padding: const pw.EdgeInsets.only(bottom: 20),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.grey300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: pw.Text(
                      'Page ${(i ~/ linesPerPage) + 1}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                        font: font,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  // Page content
                  ...pageLines.map((line) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      line,
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: font,
                        lineSpacing: 1.5,
                      ),
                    ),
                  )).toList(),
                ],
              );
            },
          ),
        );
      }

      // Generate file name
      final outputFileName = 'text_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      // Save PDF
      final pdfData = await pdf.save();
      final filePath = await _saveFile(pdfData, outputFileName);

      return ConversionResult(
        success: true,
        filePath: filePath,
        fileBytes: pdfData,
        fileName: outputFileName,
      );
    } catch (e) {
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<pw.Font> _loadFont() async {
    // For better text rendering, you can load a custom font
    // For now, return the default font
    return pw.Font.helvetica();
  }

  // Static method to download files on web
  static void downloadFileWeb(Uint8List bytes, String fileName) {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      
      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      
      html.Url.revokeObjectUrl(url);
    }
  }

  // Helper method to check supported conversions
  static bool isConversionSupported(String fromFormat, String toFormat) {
    final supported = {
      'jpg': ['pdf', 'png'],
      'jpeg': ['pdf', 'png'],
      'png': ['pdf', 'jpg'],
      'txt': ['pdf'],
      'pdf': ['jpg', 'png'], // Limited support
      'doc': ['pdf'], // Requires server
      'docx': ['pdf'], // Requires server
    };
    
    return supported[fromFormat.toLowerCase()]?.contains(toFormat.toLowerCase()) ?? false;
  }
}