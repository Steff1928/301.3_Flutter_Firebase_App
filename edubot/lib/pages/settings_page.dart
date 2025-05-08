import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // logout
  void logout(BuildContext context) async {
    final AuthManager authManager = AuthManager();
    final navigator = Navigator.of(context);

    await authManager.signOut();

    if (authManager.getCurrentUser() == null) {
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthGate()),
          (route) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Navgiation bar
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF074F67)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actionsPadding: EdgeInsets.only(top: 10),
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "Settings",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF074F67),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 24, color: Color(0xFFCC0000)),
            onPressed: () => logout(context),
          ),
        ],
      ),
    );
  }
}
