import 'package:asset_yug_debugging/features/Assets/domain/usecases/asset_files_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/asset_files_model.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/no_data_found.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// Assume you have a provider for AssetsRepositoryImpl
final assetsRepositoryProvider =
    Provider<AssetsRepositoryImpl>((ref) => AssetsRepositoryImpl());

class AssetFilesPage extends ConsumerStatefulWidget {
  final String objectId;
  const AssetFilesPage({super.key, required this.objectId});

  @override
  ConsumerState<AssetFilesPage> createState() => _AssetFilesPageState();
}

class _AssetFilesPageState extends ConsumerState<AssetFilesPage> {
  List<AssetFilesModel> files = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    print("objectId: ${widget.objectId}");
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final repository = ref.read(assetsRepositoryProvider);
      print("Attempting to load files for objectId: ${widget.objectId}");

      if (widget.objectId == null || widget.objectId.isEmpty) {
        throw Exception("Invalid objectId: ${widget.objectId}");
      }

      final response = await repository.getAssetFiles(widget.objectId);
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final String responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");

        if (responseBody.isNotEmpty) {
          final List<dynamic> jsonData = json.decode(responseBody);
          setState(() {
            files =
                jsonData.map((data) => AssetFilesModel.fromJson(data)).toList();
          isLoading = false;
          });
          print("Parsed ${files.length} files");

        } else {
          setState(() {
            files = [];
            isLoading = false;
          });
          print("No files found");
        }
      } else {
        throw Exception('Failed to load files: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in _loadFiles: $e");
      setState(() {
        error = 'Error loading files: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddFileRow(context),
        Expanded(child: _buildFilesList()),
      ],
    );
  }

  Widget _buildFilesList() {
    if (isLoading) {
      return const Center(
        child:
            SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
      );
    } else if (error != null) {
      return Text('Error: $error');
    } else if (files.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(dPadding),
          child: ListView.separated(
            itemCount: files.length,
            itemBuilder: (context, index) {
              return _buildFileContainer(data: files[index]);
            },
            separatorBuilder: (context, index) {
              return const DGap();
            },
          ),
        ),
      );
    } else {
      return const NoDataFoundPage();
    }
  }

  SizedBox _buildAddFileRow(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width / 1.2,
          ),
          IconButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();

              if (result != null) {
                setState(() {
                  isLoading = true;
                });
                File file = File(result.files.single.path!);
                String fileName = result.files.single.name;
                print("fileName: $fileName");
                try {
                  final repository = ref.read(assetsRepositoryProvider);
                  final response =
                      await repository.addAssetFile(file, widget.objectId);

                  // Read the streamed response
                  final responseBody = await response.stream.bytesToString();
                  print('Response body: $responseBody');

                  // Check if the response is valid JSON
                  try {
                    final responseData = json.decode(responseBody);
                    print('Parsed response: $responseData');
                    // setState(() {
                    //   isLoading = false;
                    // });
                    dSnackBar(context, "File uploaded successfully!",
                        TypeSnackbar.success);
                  } catch (jsonError) {
                    print('Error parsing JSON: $jsonError');
                    print(
                        'First character of response: ${responseBody.isNotEmpty ? responseBody[0] : "Empty response"}');
                    dSnackBar(context, "Unexpected server response",
                        TypeSnackbar.error);
                  }

                  // Optionally, refresh the file list
                  await _loadFiles();
                } catch (e) {
                  print('Error uploading file: $e');
                  setState(() {
                    isLoading = false;
                  });
                  dSnackBar(
                      context, "Error uploading file: $e", TypeSnackbar.error);
                }
              } else {
                dSnackBar(context, "No file selected", TypeSnackbar.info);
              }
            },
            alignment: Alignment.center,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _buildFileContainer extends StatelessWidget {
  const _buildFileContainer({
    super.key,
    required this.data,
  });

  final AssetFilesModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: dPadding * 2, vertical: dPadding),

      decoration: BoxDecoration(
          color: tPrimary,
          border: Border.all(width: D_BORDER_WIDTH, color: lighterGrey),
          // boxShadow: dBoxShadow(),
          borderRadius: BorderRadius.circular(dBorderRadius)),
      // height: 40,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(

            child: Text(
              data.fileName.isNotEmpty ? data.fileName : "Unnamed File",
              textAlign: TextAlign.start,
              style: body(weight: FontWeight.w500, size: 16, color: tWhite),
            ),
          ),
          IconButton(
            onPressed: () async {
              // bool isWaitingToLoadFile = false;
              // setState(() {
              //   isWaitingToLoadFile = true;
              // });
              await AssetFilesFunctions(
                      binaryString: data.assetFile, fileName: data.fileName)
                  .downloadAndOpenFile();
              // }, icon: isWaitingToLoadFile? const CircularProgressIndicator():const Icon(Icons.download))
            },
            icon: const Icon(Icons.download),
            color: tWhite,
          )
        ],
      ),
    );
  }
}
