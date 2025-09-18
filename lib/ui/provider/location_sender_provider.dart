import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sender_location_tracker/core/background%20task/location_background_task.dart';
import 'package:sender_location_tracker/data/location_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocationSenderProvider extends ChangeNotifier {
  final LocationRepository repository;
  String senderId;
  bool _isSharing = false;
  Position? lastPosition;
  Timer? _foregroundTimer;
  String? lastAddress;

  LocationSenderProvider({required this.repository, required this.senderId});

  bool get isSharing => _isSharing;

  Future<void> initSenderId() async {
    if (senderId.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('senderId');
    if (id == null) {
      id = Uuid().v4();
      await prefs.setString('senderId', id);
    }
    senderId = id;
  }

  Future<bool> _ensurePermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint("❌ Location service is disabled, requesting enable...");

      await Geolocator.openLocationSettings();
      return false;
    }

    // Foreground permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return false;
    }
    if (perm == LocationPermission.deniedForever) return false;

    // Background permission (Android only)
    if (Platform.isAndroid) {
      var status = await Permission.locationAlways.status;
      if (!status.isGranted) {
        status = await Permission.locationAlways.request();
        if (!status.isGranted) return false;
      }
    }

    debugPrint("✅ All location permissions + service enabled");
    return true;
  }

  Future<void> startSharing() async {
    await initSenderId();

    final ok = await _ensurePermissions();
    if (!ok) throw Exception('Location permissions not granted');

    // Start foreground service
    await FlutterForegroundTask.startService(
      notificationTitle: 'Sharing Location',
      notificationText: 'App is sending location...',
      callback: backgroundTaskEntryPoint,
    );

    // Foreground updates for UI
    _foregroundTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      lastPosition = pos;
      _updateAddressFromPosition(pos);
      await repository.pushLocation(senderId, pos.latitude, pos.longitude);
      notifyListeners();
    });

    _isSharing = true;
    notifyListeners();
  }

  Future<void> stopSharing() async {
    _foregroundTimer?.cancel();
    await FlutterForegroundTask.stopService();
    _isSharing = false;
    notifyListeners();
  }
  Future<void> _updateAddressFromPosition(Position pos) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        lastAddress = "${place.street}, ${place.locality}, ${place.administrativeArea}";
      } else {
        lastAddress = "Unknown location";
      }
    } catch (e) {
      lastAddress = "Unable to fetch address";
      debugPrint("⚠️ Address fetch failed: $e");
    }
  }
}