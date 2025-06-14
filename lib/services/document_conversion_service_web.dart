// lib/services/document_conversion_service_web.dart

import 'dart:html' as html;
import 'dart:typed_data';
import '../models/document.dart';

/// Result of a document conversion operation (Web).
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

/// Service for converting documents in the browser (Web).
class DocumentConversionService {
  /// Web conversion expects bytes passed in, then triggers a download.
  Future<ConversionResult> convertDocument({
    required Document document,
    required String targetFormat,
    Uint8List? fileBytes,
  }) async {
    if (fileBytes == null) {
      return ConversionResult(
        success: false,
        error: 'On Web you must supply fileBytes when calling convertDocument',
      );
    }

    // Directly download the file
    downloadFileWeb(fileBytes, document.fileName);

    return ConversionResult(
      success: true,
      fileBytes: fileBytes,
      fileName: document.fileName,
    );
  }

  /// Downloads raw bytes as a file in the browser.
  static void downloadFileWeb(Uint8List bytes, String fileName) {
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
