import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Client-side background removal and portrait cutout service using pure Flutter [dart:ui].
///
/// Executes on-device without third-party native dependencies or external API keys.
class BackgroundRemoverService {
  /// Removes background matching [targetColor] within Euclidean [tolerance]
  /// and applies [feather] edge smoothing.
  static Future<File?> removeColorBackground({
    required File sourceImageFile,
    required Color targetColor,
    double tolerance = 45.0,
    double feather = 15.0,
  }) async {
    try {
      final bytes = await sourceImageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final width = image.width;
      final height = image.height;

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) return null;

      final Uint8List pixels = byteData.buffer.asUint8List();
      final targetR = targetColor.red;
      final targetG = targetColor.green;
      final targetB = targetColor.blue;

      final tolSq = tolerance * tolerance;
      final maxDist = tolerance + feather;
      final maxDistSq = maxDist * maxDist;

      for (int i = 0; i < pixels.length; i += 4) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];
        final a = pixels[i + 3];

        if (a == 0) continue;

        final dr = r - targetR;
        final dg = g - targetG;
        final db = b - targetB;
        final distSq = (dr * dr + dg * dg + db * db).toDouble();

        if (distSq <= tolSq) {
          pixels[i + 3] = 0; // Complete transparent
        } else if (distSq < maxDistSq && feather > 0) {
          final dist = sqrt(distSq);
          final factor = ((dist - tolerance) / feather).clamp(0.0, 1.0);
          pixels[i + 3] = (a * factor).toInt().clamp(0, 255);
        }
      }

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        pixels,
        width,
        height,
        ui.PixelFormat.rgba8888,
        (result) => completer.complete(result),
      );

      final processedImage = await completer.future;
      final ByteData? pngBytes = await processedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (pngBytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/cutout_${DateTime.now().millisecondsSinceEpoch}.png';
      final outFile = File(outPath);
      await outFile.writeAsBytes(pngBytes.buffer.asUint8List(), flush: true);
      return outFile;
    } catch (e) {
      debugPrint('Background color removal error: $e');
      return null;
    }
  }

  /// Applies a soft bottom gradient fade-out mask (authentic Indian political / festival leader cutout).
  static Future<File?> applyPortraitBottomFade({
    required File sourceImageFile,
    double fadeStartFactor = 0.65, // Starts fading at 65% height down to bottom
  }) async {
    try {
      final bytes = await sourceImageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final width = image.width;
      final height = image.height;

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) return null;

      final Uint8List pixels = byteData.buffer.asUint8List();
      final fadeStartRow = (height * fadeStartFactor).toInt();
      final fadeRange = max(1, height - fadeStartRow);

      for (int y = fadeStartRow; y < height; y++) {
        final double factor = 1.0 - ((y - fadeStartRow) / fadeRange).clamp(0.0, 1.0);

        for (int x = 0; x < width; x++) {
          final index = (y * width + x) * 4;
          final currentAlpha = pixels[index + 3];
          if (currentAlpha > 0) {
            pixels[index + 3] = (currentAlpha * factor).toInt().clamp(0, 255);
          }
        }
      }

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        pixels,
        width,
        height,
        ui.PixelFormat.rgba8888,
        (result) => completer.complete(result),
      );

      final processedImage = await completer.future;
      final ByteData? pngBytes = await processedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (pngBytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/portrait_fade_${DateTime.now().millisecondsSinceEpoch}.png';
      final outFile = File(outPath);
      await outFile.writeAsBytes(pngBytes.buffer.asUint8List(), flush: true);
      return outFile;
    } catch (e) {
      debugPrint('Bottom fade cutout error: $e');
      return null;
    }
  }

  /// Automatically samples top-left corner color to remove standard solid studio backdrops
  static Future<Color?> sampleCornerColor(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return null;

      final Uint8List pixels = byteData.buffer.asUint8List();
      if (pixels.length < 4) return null;

      // Sample a small 5x5 patch at (x=4, y=4) to avoid edge artifacts
      int rSum = 0, gSum = 0, bSum = 0, count = 0;
      final w = image.width;
      for (int y = 2; y <= 6 && y < image.height; y++) {
        for (int x = 2; x <= 6 && x < image.width; x++) {
          final idx = (y * w + x) * 4;
          rSum += pixels[idx];
          gSum += pixels[idx + 1];
          bSum += pixels[idx + 2];
          count++;
        }
      }

      if (count == 0) return null;
      return Color.fromARGB(255, rSum ~/ count, gSum ~/ count, bSum ~/ count);
    } catch (e) {
      debugPrint('Corner color sample error: $e');
      return null;
    }
  }
}
