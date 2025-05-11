import 'dart:convert';
import 'dart:io';

import 'package:asset_yug_debugging/core/utils/constants/strings.dart';
import 'package:asset_yug_debugging/features/Assets/data/data_sources/asset_category_data.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/features/Auth/data/repository/auth_token_repository_impl.dart';
import 'package:asset_yug_debugging/features/Customers/data/data_sources/customer_names_data.dart';
import 'package:asset_yug_debugging/features/Assets/data/data_sources/asset_status_data.dart';
import 'package:asset_yug_debugging/features/Assets/data/models/assets_model.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/features/Assets/presentation/widgets/custom_text_field.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/widgets/my_elevated_button.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _serialField = TextEditingController();
  // final _customerIDField = TextEditingController();
  // final _assetIDField = TextEditingController();
  final _nameField = TextEditingController();
  final _assetLocationField = TextEditingController();

  File? _image;
  String? base64Image;
  String? _assetStatus = activeStatusString;
  String? _assetCategory;
  String? _customer;

  bool loadingAssetInsertion = false;

  late AuthTokenRepositoryImpl assetsTokenRepo;
  late String companyId;
  late String userEmail;
  late Box box;

  void _changeStatusValue(String? option) => _assetStatus = option;
  void _changeCustomerValue(String? option) => _customer = option;
  void _changeCategoryValue(String? option) => _assetCategory = option;

  @override
  void initState() {
    createBox();
    super.initState();
  }

  Future<void> _fetchUserInfo() async {
    final assetsTokenRepo = AuthTokenRepositoryImpl();
    //!TODO: GET EMAIL ID AUTOMATICALLY
    userEmail = box.get('email');
    companyId = box.get('companyId');
  }

  void createBox() async {
    box = await Hive.openBox('auth_data');
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //ON TAPPING OUTSIDE DESELCT TEXTFORMFIELDS
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Add Asset"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(dPadding * 2),
              padding: const EdgeInsets.all(dPadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Show Asset Image
                  buildAssetImageCard(),

                  SingleChildScrollView(
                    child: Column(
                      //TEXT FIELDS COLUMN
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildCustomTextField(
                            "Asset Name", TextInputType.text, _nameField, true),
                        const DGap(),
                        // buildCustomTextField("Asset ID", TextInputType.number,
                        //     _assetIDField, true),
                        // const DGap(),
                        buildCustomTextField("Serial Number",
                            TextInputType.text, _serialField, true),
                        const DGap(),
                        // buildCustomTextField("Category", TextInputType.text,
                        // categoryField, false),
                        DDropdown(
                          label: "Category",
                          items: assetCategoryTypeMenuItems,
                          onChanged: (value) => _changeCategoryValue(value),
                          value: _assetCategory,
                        ),

                        const DGap(),
                        DDropdown(
                          label: "Customer",
                          items: customerNamesMenuItems,
                          onChanged: (value) => _changeCustomerValue(value),
                          isMandatory: true,
                          value: _customer,
                        ),

                        // buildCustomTextField("Customer", TextInputType.text,
                        //     _customerField, true),
                        // const DGap(),
                        // buildCustomTextField("Customer ID", TextInputType.text,
                        //     _customerIDField, true),
                        const DGap(),
                        buildCustomTextField("Location", TextInputType.text,
                            _assetLocationField, true),

                        // buildCustomTextField("Location", TextInputType.text,
                        //     _locationField, false),
                        const DGap(),
                        DDropdown(
                          label: "Status",
                          items: assetStatusMenuItems,
                          value: _assetStatus,
                          onChanged: (value) => _changeStatusValue(value),
                          isMandatory: true,
                        ),
                        const DGap(),
                      ],
                    ),
                  ),
                  const DGap(),
                  DElevatedButton(
                      buttonColor: tPrimary,
                      textColor: tWhite,
                      onPressed: () {
                        setState(() {
                          loadingAssetInsertion = true;
                        });
                        //INSERT ENTRY HERE
                        //Error detection also to make

                        if (!validateFields([
                          _serialField.text,
                          _nameField.text,
                          _customer ?? "",
                          _assetStatus ?? "",
                        ])) {
                          setState(() {
                            loadingAssetInsertion = false;
                          });
                          dSnackBar(context, "Fill all required fields",
                              TypeSnackbar.error);
                        } else {
                          try {
                            _insertAssetData(
                                _nameField.text,
                                _serialField.text,
                                _assetCategory ?? "",
                                _customer ?? "",
                                _assetLocationField.text,
                                _assetStatus ?? "");
                          } on Exception {
                            setState(() {
                              loadingAssetInsertion = false;
                            });
                            // Anything else that is an exception
                            dSnackBar(
                                context,
                                'ERROR! Asset ID should be a number',
                                TypeSnackbar.error);
                          } catch (e) {
                            setState(() {
                              loadingAssetInsertion = false;
                            });
                            dSnackBar(
                                context,
                                "Unknown error occured. Try again ${e.toString()}",
                                TypeSnackbar.error);
                          }
                        }
                      },
                      child: loadingAssetInsertion
                          ? const SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(color: tWhite))
                          : const Text("Add Asset"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //ADD IMAGE
  Column buildAssetImageCard() {
    return Column(
      children: [
        _image == null
            ? ClipOval(
                child: Container(
                  color: Colors.grey[300],
                  height: 150.0, // Adjust the height as needed
                  width: 150.0, // Adjust the width as needed
                  child: Icon(
                    Icons.camera_alt,
                    size: 50.0,
                    color: Colors.grey[800],
                  ),
                ),
              )
            : ClipOval(
                child: Image.file(
                  _image!,
                  height: 150.0, // Adjust the height as needed
                  width: 150.0, // Adjust the width as needed
                  fit: BoxFit.cover,
                ),
              ),
        const DGap(),
        DElevatedButton(
            onPressed: () => _showImageSourceActionSheet(context),
            child: const Text("Add Image")),
        const DGap(),
      ],
    );
  }

  bool validateFields(List<String> values) {
    int errorCount = 0;
    for (String value in values) {
      print("Value: $value");
      if (value.isEmpty) {
        errorCount++;
      }
    }
    if (errorCount != 0) {
      return false;
    }
    return true;
  }

  Future<void> _insertAssetData(
    String name,
    String serialNumber,
    String category,
    String customer,
    String location,
    String status,
  ) async {
    final assetsRepo = AssetsRepositoryImpl();

    // Check if image is not null and encode it to base64
    if (_image != null) {
      List<int> imageBytes = await _image!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    // Create the AssetsModel instance
    final data = AssetsModel(
        name: name,
        serialNumber: serialNumber,
        category: category,
        customer: customer,
        customerId: "1",
        location: location,
        status: status,
        image: base64Image,
        companyId: companyId);

    // Convert the model to JSON
    final jsonData = json.encode(data.toJson());
    print("json data $jsonData");

    // Send the POST request using the addNewAsset method
    final response = await assetsRepo.addNewAsset(jsonData);

    // Handle response
    if (response.statusCode == 200) {
      print("response: ${response.body}");
      final newAssetObjectId = jsonDecode(response.body)["id"];

      final checkInData = {
        'assetId': newAssetObjectId,
        'status': checkInString,
        'employee': customer,
        'notes': null,
        'location': location,
        'date':DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };
      print("checkIn Date: ${checkInData['date']}");

      try {
        final checkInResponse =
            await assetsRepo.addCheckInOut(json.encode(checkInData));
        if (checkInResponse.statusCode == 200) {
          print('Check in/out successful');
        } else {
          print('Failed to check in/out: ${checkInResponse.body}');
        }
      } catch (e) {
        print('Error during check in/out: $e');
      }

      if (mounted) {
        dSnackBar(context, "Asset Inserted Successfully", TypeSnackbar.success);
      }
      clearFields();
    } else {
      if (mounted) {
        dSnackBar(context, "Failed to insert asset", TypeSnackbar.error);
      }
    }

    setState(() {
      loadingAssetInsertion = false;
    });
  }

  // Future<void> _insertAssetData(
  //   String serialNumber,
  //   String name,
  //   int assetId,
  //   String customer,
  //   String customerId,
  //   String category,
  //   String location,
  //   String status,
  // ) async {
  //   //MAKE OBJECT ID
  //   var id = mongo.ObjectId();

  //   //NULL CHECK HERE
  //   if (_image != null) {
  //     List<int> imageBytes = await _image!.readAsBytes();
  //     base64Image = base64Encode(imageBytes);
  //   }

  //     //THIS WILL GENERATE ID
  //     final data = AssetsModel(
  //       id: id,
  //       // email: ,
  //       assetId: assetId, //!AUTO ASSIGN
  //       name: name,
  //       serialNumber: serialNumber,
  //       category: category,
  //       customer: customer,
  //       // customerId: customerId, //!AUTO ASSIGN
  //       location: location,

  //       status: status,

  //       image: base64Image,
  //     );
  //     var result = await AssetsMongoDB.insertEntry(data, "");
  //     print("result: $result");

  //     //SHOW SUCCESS MESSAGE
  //     if (mounted) {
  //       dSnackBar(context, "Asset Inserted Successfully",TypeSnackbar.success);
  //     }
  //     clearFields();

  //   setState(() {
  //     loadingAssetInsertion = false;
  //   });
  // }

  void clearFields() {
    setState(() {
      _nameField.text = "";
      _serialField.text = "";
      _assetLocationField.text = '';
      _changeCategoryValue(null);
      _changeCustomerValue(null);
      _changeStatusValue(activeStatusString);
      _image = null;
      _assetCategory = null;
      _customer = null;

      // Reset dropdowns
    });
  }

  //
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final compressedImage = await _compressImage(File(image.path));
      setState(() {
        _image = compressedImage;
        // _image = File(image.path);
      });
    }
  }

  Future<File> _compressImage(File imageFile) async {
    // Read the image from file
    final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

    // Compress the image
    final img.Image compressedImage = img.copyResize(image, width: 500);

    // Get the directory to save the compressed image
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/compressed_image.jpg';

    // Save the compressed image
    final compressedImageFile = File(path)
      ..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 55));

    return compressedImageFile;
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take picture'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
