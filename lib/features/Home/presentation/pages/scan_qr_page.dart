import 'dart:typed_data';

import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/pages/view_asset_page.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final ImagePicker _picker = ImagePicker();
  final MobileScannerController _cameraController = MobileScannerController();
  
  bool isQrDetected = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      final String imagePath = image.path;
      _detectQRCodeFromImage(imagePath, imageData);
    }
  }

  void _detectQRCodeFromImage(String imagePath, Uint8List imageData) {
    try {
      _cameraController.analyzeImage(imagePath).then((capture) {
        final List<Barcode>? barcodes = capture?.barcodes;

        if (barcodes != null) {
          for (final barcode in barcodes) {
            print('Barcode found! ${barcode.rawValue}');
          }
          String? barcodeValue = barcodes.first.rawValue;

          if (barcodeValue!.isNotEmpty &&
              barcodeValue.split("id?").first.toLowerCase() == "assets/") {
            String assetObjectId = barcodeValue.split("id?").last;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewAssetPage(assetObjectId: assetObjectId)));
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: Text(
                    "Asset not found.\nText found = ${barcodeValue.split("id?").first.toLowerCase()}",
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"))
                  ],
                );
              },
            );
          }
        } else {
          dSnackBar(context, "QR not found. Try again", TypeSnackbar.error);
        }
      });
    } catch (e) {
      dSnackBar(context, e.toString(), TypeSnackbar.error);
    }
  }

void _onDetect(BarcodeCapture capture) {
  if (isQrDetected) return; // Exit early if QR code has already been detected

  final List<Barcode> barcodes = capture.barcodes;
  final Uint8List? image = capture.image;
  for (final barcode in barcodes) {
    print('Barcode found! ${barcode.rawValue}');
  }
  
  if (barcodes.isNotEmpty) {
    setState(() {
      isQrDetected = true; // Update flag to prevent further scanning
    });

    String? barcodeValue = barcodes.first.rawValue;
  
    if (barcodeValue!.isNotEmpty &&
        barcodeValue.split("id?").first.toLowerCase() == "assets/") {
      String assetObjectId = barcodeValue.split("id?").last;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ViewAssetPage(assetObjectId: assetObjectId)));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(
              "Asset not found.\nText found = ${barcodeValue.split("id?").first.toLowerCase()}",
            ),
            actions: [
              TextButton(
                  onPressed: () { Navigator.pop(context); setState(() {
                    isQrDetected = false;
                  });},
                  child: const Text("OK"))
            ],
          );
        },
      );
    }
  }
}

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new,)),
        title: const Text('Scan QR Code' ),
        centerTitle: true,
        backgroundColor: tWhite,
        elevation: 5.0,
        foregroundColor: tBlack,
        actions: [
          IconButton(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_rounded))
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),
          _buildOverlay(context),
        ],
      ),
    );
  }

Widget _buildOverlay(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    // color: Colors.black.withOpacity(0.2), // Semi-transparent background for the outer box
    child: Center(
      child: Container(
        height: MediaQuery.sizeOf(context).width / 1.2,
        width: MediaQuery.sizeOf(context).width / 1.2,
        decoration: BoxDecoration(
          color: Colors.transparent, // Transparent background for the inner box
          border: Border.all(color: tBlue, ), // Blue border for the inner box
        ),
      ),
    ),
  );
}

}
