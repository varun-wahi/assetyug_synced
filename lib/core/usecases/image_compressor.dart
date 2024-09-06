import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
   Future<File> _compressImage(File imageFile) async {
  // Read the image from file
  final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

  // Compress the image
  final img.Image compressedImage = img.copyResize(image, width: 600);

  // Get the directory to save the compressed image
  final directory = await getTemporaryDirectory();
  final path = '${directory.path}/compressed_image.jpg';

  // Save the compressed image
  final compressedImageFile = File(path)..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 85));

  return compressedImageFile;
}
}