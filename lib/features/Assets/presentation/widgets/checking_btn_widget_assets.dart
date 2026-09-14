import 'dart:convert';

import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/widgets/my_elevated_button.dart';
import 'package:asset_yug_debugging/features/Assets/data/repository/assets_repository_impl.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_dropdown.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Main/presentation/riverpod/refresh_provider.dart';
import '../../domain/usecases/switch_asset_status_string.dart';
import '../../data/models/assets_model.dart';
import '../../../../core/utils/constants/strings.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/location/device_location_utils.dart';
import '../riverpod/technical_users_provider.dart';

class AssetStatusButton extends ConsumerStatefulWidget {
  final AssetsModel data;
  final WidgetRef ref;
  final Function(String)? onStatusChanged;
  /// When provided (e.g. from advancedFilter/optimized), skips the status API.
  final String? initialCheckingStatus;

  const AssetStatusButton({
    super.key,
    required this.data,
    required this.ref,
    this.onStatusChanged,
    this.initialCheckingStatus,
  });

  @override
  _AssetStatusButtonState createState() => _AssetStatusButtonState();
}

class _AssetStatusButtonState extends ConsumerState<AssetStatusButton> {
  late Future<String> _statusFuture;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedEmployee;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCheckingStatus?.trim();
    if (initial != null && initial.isNotEmpty) {
      _statusFuture = Future.value(initial);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onStatusChanged?.call(initial);
      });
    } else {
      _statusFuture = _fetchCheckInOutStatus();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<String> _fetchCheckInOutStatus() async {
    final repository = AssetsRepositoryImpl();
    try {
      final response = await repository.getCheckInOutList(widget.data.id!);
      if (response.statusCode == 200 || response.statusCode == 202) {
        final List<dynamic> checkInOutList = json.decode(response.body);
        if (checkInOutList.isEmpty) return checkInString;
        // Choose the most recent entry by parsing dates (safer than .last)
        DateTime? latestDate;
        dynamic latestEntry;
        for (var entry in checkInOutList) {
          final dateStr = entry['date']?.toString();
          DateTime? dt;
          try {
            dt = dateStr != null ? DateTime.parse(dateStr) : null;
          } catch (_) {
            dt = null;
          }
          if (dt != null) {
            if (latestDate == null || dt.isAfter(latestDate)) {
              latestDate = dt;
              latestEntry = entry;
            }
          }
        }
        final chosen = latestEntry ?? checkInOutList.last;
        final status = chosen['status'] ?? checkInString;
        print("STATUS: $status");
        widget.onStatusChanged?.call(status);
        return status;
      } else {
        throw Exception('Failed to fetch check-in/out status');
      }
    } catch (e) {
      print('Error fetching check-in/out status: $e');
      widget.onStatusChanged?.call(checkInString);
      return checkInString; // Default to checked in if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _statusFuture,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 50.0,
            width: 50.0,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final assetCheckingStatus = snapshot.data;

          return DElevatedButton(
            borderRadius: 30,
            buttonColor: (assetCheckingStatus == checkInString)
                ? tCheckOutColor
                : tCheckInColor,
            onPressed: () {
              if (_isFetchingLocation) return;
              _startCheckInOut(assetCheckingStatus);
            },
            child: _isFetchingLocation
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tWhite,
                    ),
                  )
                : (assetCheckingStatus == checkInString)
                    ? Text("Check Out",
                        style:
                            subtitle(weight: FontWeight.w500, color: tWhite))
                    : Text("Check In",
                        style:
                            subtitle(weight: FontWeight.w500, color: tWhite)),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> _startCheckInOut(String? assetCheckingStatus) async {
    setState(() => _isFetchingLocation = true);

    try {
      await DeviceLocationUtils.ensureLocationPermission();
      if (!mounted) return;

      _showLocationLoadingDialog();
      final location = await DeviceLocationUtils.captureRequired();

      if (!mounted) return;
      _hideLocationLoadingDialog();
      setState(() => _isFetchingLocation = false);

      if (!location.hasCoordinates) {
        dSnackBar(
          context,
          'Location is required to check in/out.',
          TypeSnackbar.warning,
        );
        return;
      }

      await showCheckInOutDialog(context, assetCheckingStatus, location);
    } on LocationCaptureException catch (e) {
      if (!mounted) return;
      _hideLocationLoadingDialog();
      setState(() => _isFetchingLocation = false);
      dSnackBar(context, e.message, TypeSnackbar.warning);
    } catch (e) {
      if (!mounted) return;
      _hideLocationLoadingDialog();
      setState(() => _isFetchingLocation = false);
      dSnackBar(
        context,
        'Failed to get location. Please try again.',
        TypeSnackbar.error,
      );
      print('Check in/out location error: $e');
    }
  }

  bool _isLocationDialogVisible = false;

  void _showLocationLoadingDialog() {
    _isLocationDialogVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(vertical: 12.0),
          content: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Fetching information...'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _hideLocationLoadingDialog() {
    if (!_isLocationDialogVisible || !mounted) return;
    _isLocationDialogVisible = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> showCheckInOutDialog(
      BuildContext context,
      var assetCheckingStatus,
      DeviceLocationPayload location) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          scrollable: true,
          title: const Text('Check In/Out Details'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              minWidth: 300,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: <Widget>[
                Consumer(builder: (context, ref, child) {
                  final technicalUsersAsync = ref.watch(
                      technicalUsersProvider(widget.data.companyId.toString()));

                  return technicalUsersAsync.when(
                    data: (users) => StatefulBuilder(
                      builder: (context, setDialogState) {
                        // Initialize default selection to the first user
                        if ((_selectedEmployee == null || _selectedEmployee == '') &&
                            users.isNotEmpty) {
                          Future.microtask(() {
                            setDialogState(() => _selectedEmployee = users.first);
                          });
                        }
                        return DDropdown(
                          padding: EdgeInsets.zero,
                          label: "Employee",
                          items: users
                              .map((name) => DropdownMenuItem(
                                  value: name, child: Text(name)))
                              .toList(),
                          onChanged: (newValue) {
                            setDialogState(() => _selectedEmployee = newValue);
                            setState(() => _selectedEmployee = newValue);
                          },
                          value: _selectedEmployee,
                        );
                      },
                    ),
                    loading: () => DDropdown(
                      label: "Loading employees...",
                      items: const [],
                      onChanged: (val) {},
                      value: null,
                    ),
                    error: (err, stack) =>
                        const Text("Error loading technical users"),
                  );
                }),
                const DGap(),
                DTextField(
                  hasLabel: true,
                  hintText: "Notes",
                  maxLines: 3,
                  padding: EdgeInsets.zero,
                  controller: _notesController,
                ),
                const DGap(),
                DTextField(
                  hasLabel: true,
                  hintText: "Location",
                  padding: EdgeInsets.zero,
                  controller: _locationController,
                ),
              ],
            ),
          ),),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel")),
            DElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                Navigator.of(context).pop();

                // Prepare the data for addCheckInOut
                final data = {
                  'assetId': widget.data.id!,
                  'status': switchAssetCheckingStatus(assetCheckingStatus),
                  'employee': _selectedEmployee,
                  'companyId': widget.data.companyId,
                  'notes': _notesController.text,
                  'location': _locationController.text,
                  'date': DateTime.now().toIso8601String(),
                  ...location.toJson(),
                };
                final payload = json.encode(data);
                print('addCheckInOut payload: $payload');
                // Call addCheckInOut method
                final repository = AssetsRepositoryImpl();
                try {
                  final response = await repository.addCheckInOut(payload);
                  if (response.statusCode == 200) {
                    // Trigger global refresh for dashboard/home
                    ref.read(refreshProvider.notifier).state =
                        !ref.read(refreshProvider);
                    widget.onStatusChanged
                        ?.call(switchAssetCheckingStatus(assetCheckingStatus));
                  } else {
                    print('Failed to check in/out: ${response.body}');
                  }
                } catch (e) {
                  print('Error during check in/out: $e');
                }

                // Check if the widget is still mounted before calling setState
                if (mounted) {
                  setState(() {
                    _statusFuture = _fetchCheckInOutStatus();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
