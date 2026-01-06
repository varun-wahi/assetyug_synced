import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';

import '../../data/models/inspection models/inspection_step_model.dart';

class InspectionFormField extends StatefulWidget {
  final InspectionStepModel step;
  final Function(dynamic value) onValueChanged;

  const InspectionFormField({
    super.key,
    required this.step,
    required this.onValueChanged,
  });

  @override
  State<InspectionFormField> createState() => _InspectionFormFieldState();
}

class _InspectionFormFieldState extends State<InspectionFormField> {
  final TextEditingController _textController = TextEditingController();
  bool _checkboxValue = false;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeValue();
  }

  void _initializeValue() {
    if (widget.step.value != null) {
      switch (widget.step.type) {
        case 'TEXT':
        case 'NUMBER':
          _textController.text = widget.step.value.toString();
          break;
        case 'CHECKBOX':
          _checkboxValue = widget.step.value == true || widget.step.value == 'true';
          break;
        case 'IMAGE':
          _imageBase64 = widget.step.value.toString();
          break;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _imageBase64 = base64String;
        });
        widget.onValueChanged(base64String);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Image Source', style: body(weight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Camera', style: body()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Gallery', style: body()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.step.name,
          style: body(weight: FontWeight.w500, size: 14),
        ),
        const SizedBox(height: 8),
        _buildFieldByType(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFieldByType() {
    switch (widget.step.type) {
      case 'TEXT':
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.step.name}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: widget.onValueChanged,
        );

      case 'NUMBER':
        return TextFormField(
          controller: _textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.step.name}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: widget.onValueChanged,
        );

      case 'CHECKBOX':
        return CheckboxListTile(
          value: _checkboxValue,
          onChanged: (value) {
            setState(() {
              _checkboxValue = value ?? false;
            });
            widget.onValueChanged(_checkboxValue);
          },
          title: Text('Check if applicable', style: body(size: 14)),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );

      case 'IMAGE':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: Text(_imageBase64 == null ? 'Add Image' : 'Change Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tPrimary,
                foregroundColor: tWhite,
              ),
            ),
            if (_imageBase64 != null) ...[
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: lighterGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(_imageBase64!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        );

      default:
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: widget.onValueChanged,
        );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}