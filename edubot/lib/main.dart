import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/chat/chat_provider.dart';
//import 'package:edubot/themes/dark_mode.dart';
import 'package:edubot/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Global navigator key to avoid using Buildcontext across asynchronous gaps
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    // Initialize the app within a ChangeNotifierProvider
    // to provide the ChatProvider to the entire app
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the app theme, itle and additional properties
    return MaterialApp(
      title: "EduBot",
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const AuthGate(),
      theme: lightmode,
      //darkTheme: darkmode,
    );
  }
}
