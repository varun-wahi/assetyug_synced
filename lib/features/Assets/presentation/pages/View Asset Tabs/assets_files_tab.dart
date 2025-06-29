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
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final repository = ref.read(assetsRepositoryProvider);

      if (widget.objectId.isEmpty) {
        throw Exception("Invalid objectId: ${widget.objectId}");
      }

      final response = await repository.getAssetFiles(widget.objectId);

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();

        if (responseBody.isNotEmpty) {
          final List<dynamic> jsonData = json.decode(responseBody);
          setState(() {
            files = jsonData.map((data) => AssetFilesModel.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            files = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load files: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Error loading files: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() => isLoading = true);

      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      try {
        final repository = ref.read(assetsRepositoryProvider);
        final response = await repository.addAssetFile(file, widget.objectId);

        final responseBody = await response.stream.bytesToString();

        try {
          json.decode(responseBody); // Just to verify it's valid
          dSnackBar(context, "File uploaded successfully!", TypeSnackbar.success);
        } catch (_) {
          dSnackBar(context, "Unexpected server response", TypeSnackbar.error);
        }

        await _loadFiles(); // Refresh
      } catch (e) {
        dSnackBar(context, "Error uploading file: $e", TypeSnackbar.error);
        setState(() => isLoading = false);
      }
    } else {
      dSnackBar(context, "No file selected", TypeSnackbar.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: tPrimary,
        onPressed: _pickAndUploadFile,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(child: _buildFilesList()),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    if (isLoading) {
      return const Center(
        child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
      );
    } else if (error != null) {
      return Center(child: Text('Error: $error'));
    } else if (files.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(dPadding),
        child: ListView.separated(
          itemCount: files.length,
          itemBuilder: (context, index) =>
              _buildFileContainer(data: files[index]),
          separatorBuilder: (_, __) => const DGap(),
        ),
      );
    } else {
      return const NoDataFoundPage();
    }
  }

  Widget _buildFileContainer({required AssetFilesModel data}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: dPadding * 2, vertical: dPadding),
      decoration: BoxDecoration(
        color: tPrimary,
        border: Border.all(width: D_BORDER_WIDTH, color: lighterGrey),
        borderRadius: BorderRadius.circular(dBorderRadius),
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              data.fileName.isNotEmpty ? data.fileName : "Unnamed File",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: body(weight: FontWeight.w400, size: 15, color: tWhite),
            ),
          ),
          IconButton(
            onPressed: () async {
              await AssetFilesFunctions(
                binaryString: data.assetFile,
                fileName: data.fileName,
              ).downloadAndOpenFile();
            },
            icon: const Icon(Icons.download, color: tWhite),
          ),
        ],
      ),
    );
  }
}