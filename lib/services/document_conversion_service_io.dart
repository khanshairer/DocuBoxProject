// lib/services/document_conversion_service_io.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../models/document.dart';

/// Result of a document conversion.
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

  @override
  String toString() {
    return 'ConversionResult(success=$success, fileName=$fileName, error=$error)';
  }
}

/// Service for converting documents on mobile/desktop.
class DocumentConversionService {
  Future<ConversionResult> convertDocument({
    required Document document,
    required String targetFormat,
    Uint8List? fileBytes,
  }) async {
    // Normalize and debug operation key
    final srcExt = _getFileExtension(document.fileName).trim();
    final tgt = targetFormat.toLowerCase().trim();
    final op = '${srcExt}_to_$tgt';
    print('[Conversion] Starting $op for ${document.fileName}');

    try {
      final data = fileBytes ?? await _getFileData(document);
      print('[Conversion] Fetched ${data.lengthInBytes} bytes');

      switch (op) {
        case 'pdf_to_jpg':
        case 'pdf_to_png':
          return ConversionResult(
            success: false,
            error: 'PDF→Image conversion not implemented',
          );

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
          return ConversionResult(
            success: false,
            error: 'Word→PDF conversion requires server-side API',
          );

        case 'txt_to_pdf':
          return await _convertTxtToPdf(data);

        default:
          return ConversionResult(
            success: false,
            error: 'Unsupported conversion operation: $op',
          );
      }
    } catch (e, stack) {
      print('[Conversion] ERROR $op: $e\n$stack');
      return ConversionResult(
        success: false,
        error: e.toString(),
      );
    }
  }


  String _getFileExtension(String fn) {
    final parts = fn.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Fetch bytes from HTTP(S), gs://, or local file.
  Future<Uint8List> _getFileData(Document document) async {
    final url = document.downloadUrl;
    print('[Conversion] _getFileData(), downloadUrl="$url"');
    if (url.isNotEmpty) {
      if (url.startsWith('http')) {
        print('[Conversion] Downloading via HTTP');
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          return resp.bodyBytes;
        }
        throw Exception('HTTP ${resp.statusCode} downloading $url');
      }
      if (url.startsWith('gs://')) {
        print('[Conversion] Downloading via FirebaseStorage');
        final ref = FirebaseStorage.instance.refFromURL(url);
        final data = await ref.getData(50 * 1024 * 1024);
        if (data != null) return data;
        throw Exception('No data at $url');
      }
    }

    print('[Conversion] Falling back to local file');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${document.fileName}');
    if (!await file.exists()) {
      throw Exception('Local file not found: ${file.path}');
    }
    return await file.readAsBytes();
  }

  Future<String?> _saveFile(Uint8List bytes, String fn) async {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/$fn');
    await f.writeAsBytes(bytes);
    return f.path;
  }

  Future<ConversionResult> _convertImageToPdf(Uint8List imgBytes, String origName) async {
    print('[Conversion] _convertImageToPdf()');
    try {
      final pdf = pw.Document();
      final image = img.decodeImage(imgBytes);
      if (image == null) return ConversionResult(success: false, error: 'decodeImage failed');

      final pdfImg = pw.MemoryImage(imgBytes);
      final a4 = PdfPageFormat.a4;
      final scale = (a4.width / image.width).clamp(0.0, a4.height / image.height);
      final w = image.width * scale, h = image.height * scale;

      pdf.addPage(pw.Page(
        pageFormat: a4,
        build: (c) => pw.Center(child: pw.Image(pdfImg, width: w, height: h)),
      ));

      final base = origName.split('.').first;
      final out = '${base}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final data = await pdf.save();
      final path = await _saveFile(data, out);

      return ConversionResult(success: true, filePath: path, fileBytes: data, fileName: out);
    } catch (e, st) {
      print('[Conversion] _convertImageToPdf ERROR: $e\n$st');
      return ConversionResult(success: false, error: e.toString());
    }
  }

  Future<ConversionResult> _convertJpgToPng(Uint8List bytes) async {
    print('[Conversion] _convertJpgToPng()');
    try {
      final image = img.decodeJpg(bytes);
      if (image == null) return ConversionResult(success: false, error: 'decodeJpg failed');
      final png = img.encodePng(image);
      final out = 'converted_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = await _saveFile(Uint8List.fromList(png), out);
      return ConversionResult(success: true, filePath: path, fileBytes: Uint8List.fromList(png), fileName: out);
    } catch (e, st) {
      print('[Conversion] _convertJpgToPng ERROR: $e\n$st');
      return ConversionResult(success: false, error: e.toString());
    }
  }

  Future<ConversionResult> _convertPngToJpg(Uint8List bytes) async {
    print('[Conversion] _convertPngToJpg()');
    try {
      final image = img.decodePng(bytes);
      if (image == null) return ConversionResult(success: false, error: 'decodePng failed');
      final jpg = img.encodeJpg(image, quality: 90);
      final out = 'converted_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = await _saveFile(Uint8List.fromList(jpg), out);
      return ConversionResult(success: true, filePath: path, fileBytes: Uint8List.fromList(jpg), fileName: out);
    } catch (e, st) {
      print('[Conversion] _convertPngToJpg ERROR: $e\n$st');
      return ConversionResult(success: false, error: e.toString());
    }
  }

  Future<ConversionResult> _convertTxtToPdf(Uint8List bytes) async {
    print('[Conversion] _convertTxtToPdf()');
    try {
      final pdf = pw.Document();
      final text = utf8.decode(bytes);
      final lines = text.split('\n');
      final font = await _loadFont();

      const perPage = 45;
      for (var i = 0; i < lines.length; i += perPage) {
        final chunk = lines.skip(i).take(perPage).toList();
        pdf.addPage(pw.Page(
          margin: const pw.EdgeInsets.all(40),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
                ),
                child: pw.Text(
                  'Page ${(i ~/ perPage) + 1}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, font: font),
                ),
              ),
              ...chunk.map((l) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(l, style: pw.TextStyle(fontSize: 12, font: font)),
              )),
            ],
          ),
        ));
      }

      final out = 'text_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final data = await pdf.save();
      final path = await _saveFile(data, out);

      return ConversionResult(success: true, filePath: path, fileBytes: data, fileName: out);
    } catch (e, st) {
      print('[Conversion] _convertTxtToPdf ERROR: $e\n$st');
      return ConversionResult(success: false, error: e.toString());
    }
  }

  Future<pw.Font> _loadFont() async => pw.Font.helvetica();
}
