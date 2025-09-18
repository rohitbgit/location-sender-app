import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseHelper {
  static Future<void> init() async {
    await Firebase.initializeApp();
  }

  static DatabaseReference get locationsRef =>
      FirebaseDatabase.instance.ref('locations');
}
