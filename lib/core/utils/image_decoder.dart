import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ImageDecoder {
  static const MethodChannel _channel = MethodChannel('passport_reader/image_decoder');

  /// Decodes JPEG2000 (JP2) or JPEG bytes to standard JPEG/PNG bytes.
  /// If the image is already standard JPEG, it returns the bytes unchanged.
  static Future<Uint8List?> decodeImage(Uint8List bytes) async {
    if (bytes.isEmpty) return null;

    if (_isJpeg2000(bytes)) {
      try {
        final Uint8List? decoded = await _channel.invokeMethod('decodeJp2k', {'bytes': bytes});
        return decoded;
      } on PlatformException catch (e) {
        // Log or handle the exception if needed
        debugPrint("Error decoding JP2: ${e.message}");
        return null;
      }
    }

    // Assume standard JPEG or PNG if it's not JP2
    return bytes;
  }

  /// Checks if the image bytes represent a JPEG2000 file.
  /// JP2 files typically start with 0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20
  static bool _isJpeg2000(Uint8List bytes) {
    if (bytes.length < 8) return false;
    
    // JP2 signature
    return bytes[0] == 0x00 &&
           bytes[1] == 0x00 &&
           bytes[2] == 0x00 &&
           bytes[3] == 0x0C &&
           bytes[4] == 0x6A &&
           bytes[5] == 0x50 &&
           bytes[6] == 0x20 &&
           bytes[7] == 0x20;
  }
}
