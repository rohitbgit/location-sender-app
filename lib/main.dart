import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sender_location_tracker/ui/location_sender_screen.dart';
import 'package:sender_location_tracker/ui/provider/location_sender_provider.dart';
import 'core/firebase_helper.dart';
import 'data/location_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseHelper.init();

  final repo = LocationRepository(FirebaseHelper.locationsRef);
  final prefs = await SharedPreferences.getInstance();
  final senderId = prefs.getString('senderId') ?? '';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              LocationSenderProvider(repository: repo, senderId: senderId),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sender App',
      home: SenderHome(),
    );
  }
}