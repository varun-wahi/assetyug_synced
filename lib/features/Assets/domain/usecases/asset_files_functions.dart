import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';


import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

class AssetFilesFunctions {
  final String binaryString;
  final String fileName;

  AssetFilesFunctions({required this.binaryString, required this.fileName});

  Future<void> downloadAndOpenFile() async {
    try {
      print("REACHED DOWNLOAD FUNC");
      File file = await convertBinaryStringToFile(binaryString, fileName);
      // Ensure OpenFile.open is awaited
      final result = await OpenFile.open(file.path);
      print("File opened with result: ${result.message}");
    } catch (e) {
      print("Error in downloadAndOpenFile: $e");
    }
  }

  Future<File> convertBinaryStringToFile(String binaryString, String fileName) async {
    try {
      Uint8List bytes = base64.decode(binaryString);
      Directory tempDir = await getTemporaryDirectory();
      print("REACHED CONVERT BINARY FUNC");
      String tempPath = tempDir.path;
      File file = File('$tempPath/$fileName');
      return await file.writeAsBytes(bytes);
    } catch (e) {
      print("Error in convertBinaryStringToFile: $e");
      rethrow; // Re-throwing to allow the caller to handle it
    }
  }
}