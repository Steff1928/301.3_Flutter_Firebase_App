import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/chat/chat_provider.dart';
//import 'package:edubot/themes/dark_mode.dart';
import 'package:edubot/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
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
    return MaterialApp(
      title: "EduBot",
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: lightmode,
      //darkTheme: darkmode,
    );
  }
}
