import 'package:firebase_database/firebase_database.dart';

class LocationRepository {
  final DatabaseReference ref;
  LocationRepository(this.ref);

  Future<void> pushLocation(String senderId, double lat, double lng) async {
    await ref.child(senderId).push().set({
      'lat': lat,
      'lng': lng,
      'clientTs': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
