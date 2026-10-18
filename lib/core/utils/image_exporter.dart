import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportResultStatus {
  success,
  permissionDenied,
  renderError,
  fileSystemError,
}

class ExportResult {
  final ExportResultStatus status;
  final String message;
  final String? filePath;
  final Uint8List? bytes;

  const ExportResult({
    required this.status,
    required this.message,
    this.filePath,
    this.bytes,
  });

  bool get isSuccess => status == ExportResultStatus.success;
}

class ImageExporter {
  /// Captures the widget subtree enclosed by [repaintKey] using [RenderRepaintBoundary.toImage].
  ///
  /// With [pixelRatio] set to 3.0, a 360-pixel wide preview canvas renders to a crisp
  /// 1080px high-definition PNG ready for commercial printing and social media compression.
  static Future<ExportResult> capturePngBytes({
    required GlobalKey repaintKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        return const ExportResult(
          status: ExportResultStatus.renderError,
          message: 'कैनवास रेंडर बाउंड्री नहीं मिली। कृपया पुनः प्रयास करें।',
        );
      }

      // Check if boundary is still painting
      if (boundary.debugNeedsPaint) {
        // Wait a frame if repaint boundary is not yet painted
        await Future.delayed(const Duration(milliseconds: 60));
      }

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const ExportResult(
          status: ExportResultStatus.renderError,
          message: 'इमेज बाइट्स बनाने में विफल।',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      return ExportResult(
        status: ExportResultStatus.success,
        message: 'सफलतापूर्वक रेंडर किया गया',
        bytes: pngBytes,
      );
    } catch (e, stack) {
      debugPrint('Export Capture Error: $e\n$stack');
      return ExportResult(
        status: ExportResultStatus.renderError,
        message: 'पोस्टर तैयार करते समय त्रुटि: ${e.toString()}',
      );
    }
  }

  /// Saves the rendered PNG bytes directly to a temporary file on the device.
  static Future<File?> writeBytesToTempFile(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'deshi_poster_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      debugPrint('Write to Temp File Error: $e');
      return null;
    }
  }

  /// Exports the poster and saves directly to the user's device gallery using [Gal].
  static Future<ExportResult> saveToGallery({
    required GlobalKey repaintKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      // 1. Capture PNG bytes from RepaintBoundary
      final captureResult = await capturePngBytes(
        repaintKey: repaintKey,
        pixelRatio: pixelRatio,
      );

      if (!captureResult.isSuccess || captureResult.bytes == null) {
        return captureResult;
      }

      final bytes = captureResult.bytes!;

      // 2. Check and request Gallery permissions via Gal
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          return const ExportResult(
            status: ExportResultStatus.permissionDenied,
            message:
                'गैलरी में सेव करने के लिए स्टोरेज परमिशन की आवश्यकता है। कृपया सेटिंग्स में अनुमति दें।',
          );
        }
      }

      // 3. Write directly into the Android MediaStore / iOS Photos
      final fileName =
          'poster_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(
        bytes,
        name: fileName,
      );

      return ExportResult(
        status: ExportResultStatus.success,
        message: 'पोस्टर सफलतापूर्वक आपकी फोन गैलरी में सुरक्षित हो गया!',
        bytes: bytes,
      );
    } on GalException catch (e) {
      debugPrint('Gal Exception: ${e.type.message}');
      return ExportResult(
        status: ExportResultStatus.renderError,
        message: 'गैलरी में सेव करते समय त्रुटि: ${e.type.message}',
      );
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return ExportResult(
        status: ExportResultStatus.renderError,
        message: 'सेव करने में विफल: ${e.toString()}',
      );
    }
  }

  /// Renders and opens the native system share sheet (WhatsApp, Instagram, etc.) via [SharePlus].
  static Future<ExportResult> sharePoster({
    required GlobalKey repaintKey,
    String? message,
    double pixelRatio = 3.0,
  }) async {
    try {
      // 1. Capture PNG bytes
      final captureResult = await capturePngBytes(
        repaintKey: repaintKey,
        pixelRatio: pixelRatio,
      );

      if (!captureResult.isSuccess || captureResult.bytes == null) {
        return captureResult;
      }

      // 2. Write to temp file for sharing
      final file = await writeBytesToTempFile(captureResult.bytes!);
      if (file == null) {
        return const ExportResult(
          status: ExportResultStatus.fileSystemError,
          message: 'अस्थायी फ़ाइल तैयार करने में असमर्थ।',
        );
      }

      // 3. Launch native Share dialog
      final xFile = XFile(file.path, mimeType: 'image/png');
      await Share.shareXFiles(
        [xFile],
        text: message ?? 'मेरा नया पोस्टर - देसी पोस्टर मेकर द्वारा निर्मित',
      );

      return ExportResult(
        status: ExportResultStatus.success,
        message: 'शेयरिंग डायलॉग खोला गया',
        filePath: file.path,
        bytes: captureResult.bytes,
      );
    } catch (e) {
      debugPrint('Share poster error: $e');
      return ExportResult(
        status: ExportResultStatus.renderError,
        message: 'शेयर करते समय त्रुटि: ${e.toString()}',
      );
    }
  }
}
