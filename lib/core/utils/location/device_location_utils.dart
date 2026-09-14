import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationCaptureException implements Exception {
  final String message;

  LocationCaptureException(this.message);

  @override
  String toString() => message;
}

class DeviceLocationPayload {
  final String userLatitude;
  final String userLongitude;
  final String ipAddress;
  final String userLocation;

  const DeviceLocationPayload({
    required this.userLatitude,
    required this.userLongitude,
    required this.ipAddress,
    required this.userLocation,
  });

  bool get hasCoordinates =>
      userLatitude.trim().isNotEmpty && userLongitude.trim().isNotEmpty;

  Map<String, String> toJson() => {
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'ipAddress': ipAddress,
        'userLocation': userLocation,
      };
}

class DeviceLocationUtils {
  static const _headers = {
    'Accept': 'application/json',
    'User-Agent': 'AssetYug/1.0',
  };

  static Future<DeviceLocationPayload> captureRequired() async {
    await ensureLocationPermission();

    final position = await _fetchGpsRequired();
    var ipAddress = '';
    var userLocation = '';

    try {
      final ipPayload = await _fetchIpLocation();
      ipAddress = ipPayload.ipAddress;
      userLocation = ipPayload.userLocation;
    } catch (e) {
      print('Failed to fetch IP location: $e');
    }

    return DeviceLocationPayload(
      userLatitude: position.latitude.toString(),
      userLongitude: position.longitude.toString(),
      ipAddress: ipAddress,
      userLocation: userLocation,
    );
  }

  static Future<void> ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw LocationCaptureException(
        'Please enable location services to check in/out.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationCaptureException(
        'Location permission is required to check in/out.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw LocationCaptureException(
        'Location permission is required. Enable it in Settings.',
      );
    }
  }

  static Future<Position> _fetchGpsRequired() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      print('getCurrentPosition failed: $e');
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;

    throw LocationCaptureException(
      'Unable to get GPS location. Please try again.',
    );
  }

  static Future<DeviceLocationPayload> _fetchIpLocation() async {
    final errors = <String>[];

    for (final fetcher in [_fromIpWho, _fromIpApiCo, _fromIpify]) {
      try {
        return await fetcher();
      } catch (e) {
        errors.add(e.toString());
      }
    }

    throw Exception('All IP lookups failed: $errors');
  }

  static Future<DeviceLocationPayload> _fromIpWho() async {
    final response = await http
        .get(Uri.parse('https://ipwho.is/'), headers: _headers)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('ipwho.is failed (${response.statusCode})');
    }

    final jsonData = json.decode(response.body);
    if (jsonData is! Map<String, dynamic> || jsonData['success'] == false) {
      throw Exception('ipwho.is invalid response');
    }

    return DeviceLocationPayload(
      userLatitude: jsonData['latitude']?.toString() ?? '',
      userLongitude: jsonData['longitude']?.toString() ?? '',
      ipAddress: jsonData['ip']?.toString() ?? '',
      userLocation: _formatUserLocation(
        city: jsonData['city']?.toString() ?? '',
        region: jsonData['region']?.toString() ?? '',
        countryCode: jsonData['country_code']?.toString() ?? '',
        postal: jsonData['postal']?.toString() ?? '',
      ),
    );
  }

  static Future<DeviceLocationPayload> _fromIpApiCo() async {
    final response = await http
        .get(Uri.parse('https://ipapi.co/json/'), headers: _headers)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('ipapi.co failed (${response.statusCode})');
    }

    final jsonData = json.decode(response.body);
    if (jsonData is! Map<String, dynamic>) {
      throw Exception('ipapi.co invalid response');
    }

    return DeviceLocationPayload(
      userLatitude: jsonData['latitude']?.toString() ?? '',
      userLongitude: jsonData['longitude']?.toString() ?? '',
      ipAddress: jsonData['ip']?.toString() ?? '',
      userLocation: _formatUserLocation(
        city: jsonData['city']?.toString() ?? '',
        region: jsonData['region']?.toString() ?? '',
        countryCode: jsonData['country_code']?.toString() ?? '',
        postal: jsonData['postal']?.toString() ?? '',
      ),
    );
  }

  static Future<DeviceLocationPayload> _fromIpify() async {
    final response = await http
        .get(
          Uri.parse('https://api.ipify.org?format=json'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('ipify failed (${response.statusCode})');
    }

    final jsonData = json.decode(response.body);
    return DeviceLocationPayload(
      userLatitude: '',
      userLongitude: '',
      ipAddress: jsonData['ip']?.toString() ?? '',
      userLocation: '',
    );
  }

  static String _formatUserLocation({
    required String city,
    required String region,
    required String countryCode,
    required String postal,
  }) {
    final locality = [city, region, countryCode]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');

    if (postal.trim().isEmpty) return locality;
    if (locality.isEmpty) return postal;
    return '$locality - $postal';
  }
}
