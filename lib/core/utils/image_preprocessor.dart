import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  /// Crops, resizes, and normalizes an image for MobileFaceNet inference.
  /// Output is a 1D float list of size 112 * 112 * 3.
  static Float32List preprocessImage(Uint8List imageBytes, ui.Rect boundingBox) {
    // 1. Decode image
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw Exception('Failed to decode image.');
    }

    // 2. Crop the face based on the bounding box
    // Ensure we don't go out of bounds
    final int x = boundingBox.left.toInt().clamp(0, decodedImage.width - 1);
    final int y = boundingBox.top.toInt().clamp(0, decodedImage.height - 1);
    final int w = boundingBox.width.toInt().clamp(1, decodedImage.width - x);
    final int h = boundingBox.height.toInt().clamp(1, decodedImage.height - y);

    final img.Image croppedImage = img.copyCrop(
      decodedImage,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    // 3. Resize to 112x112 (required by MobileFaceNet)
    final img.Image resizedImage = img.copyResize(
      croppedImage,
      width: 112,
      height: 112,
    );

    // 4. Normalize to Float32 Tensor
    // MobileFaceNet requires normalization: (pixel - 127.5) / 128.0
    final Float32List float32list = Float32List(112 * 112 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        final img.Pixel pixel = resizedImage.getPixel(x, y);

        // Extract RGB channels
        final num r = pixel.r;
        final num g = pixel.g;
        final num b = pixel.b;

        // Normalize and store
        float32list[pixelIndex++] = (r - 127.5) / 128.0;
        float32list[pixelIndex++] = (g - 127.5) / 128.0;
        float32list[pixelIndex++] = (b - 127.5) / 128.0;
      }
    }

    return float32list;
  }
  
  /// Helper method for images that are already cropped and resized.
  static Float32List normalize(img.Image resizedImage) {
    final Float32List float32list = Float32List(resizedImage.width * resizedImage.height * 3);
    int pixelIndex = 0;

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        final img.Pixel pixel = resizedImage.getPixel(x, y);
        float32list[pixelIndex++] = (pixel.r - 127.5) / 128.0;
        float32list[pixelIndex++] = (pixel.g - 127.5) / 128.0;
        float32list[pixelIndex++] = (pixel.b - 127.5) / 128.0;
      }
    }
    return float32list;
  }
}
