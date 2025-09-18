import 'dart:isolate';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entry point for the background task (must be a top-level function).
@pragma('vm:entry-point')
void backgroundTaskEntryPoint() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(LocationBackgroundTask());
}

/// Handles the background task logic
class LocationBackgroundTask extends TaskHandler {
  Timer? _timer;
  DatabaseReference? _ref;
  String? _senderId;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      await Firebase.initializeApp();
      _ref = FirebaseDatabase.instance.ref('locations');
    } catch (e) {
      print("Firebase init failed in background: $e");
    }

    // Load senderId
    final prefs = await SharedPreferences.getInstance();
    _senderId = prefs.getString('senderId') ?? 'default-sender';

    // Send location every 5 sec
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        if (_ref != null && _senderId != null) {
          await _ref!.child(_senderId!).push().set({
            'lat': pos.latitude,
            'lng': pos.longitude,
            'clientTs': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        print("Background location error: $e");
      }
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _timer?.cancel();
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Not needed for now
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Not used in this project
  }
}