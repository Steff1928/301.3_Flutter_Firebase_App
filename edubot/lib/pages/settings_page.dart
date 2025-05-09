import 'package:edubot/components/settings_tile.dart';
import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final AuthManager authManager = AuthManager();

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
      ),

      // body: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     // Display name
      //     Padding(
      //       padding: const EdgeInsets.only(left: 27, top: 33),
      //       child: Text(
      //         "${authManager.getCurrentUser()?.displayName}",
      //         style: TextStyle(
      //           fontFamily: "Nunito",
      //           fontSize: 20,
      //           fontWeight: FontWeight.bold,
      //           color: Color(0xFF1A1A1A),
      //         ),
      //       ),
      //     ),

      //     SizedBox(height: 61),

      // Settings options
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display name
          Padding(
            padding: const EdgeInsets.only(left: 27, top: 33),
            child: Text(
              "${authManager.getCurrentUser()?.displayName}",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),

          SizedBox(height: 33),

          // Body Content

          // Parent widget
          Expanded(
            // Material widget to allow ListTile splash colours
            child: Material(
              color: Color(0xFFF1F5F8),
              borderRadius: BorderRadius.circular(12),

              // Container to allow padding
              child: Container(
                padding: EdgeInsets.only(top: 33),

                // Parent column for both settings options and logout list tile
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Secondary column for only settings tiles
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account header
                        Padding(
                          padding: const EdgeInsets.only(left: 27.0),
                          child: Text(
                            "ACCOUNT",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF364B55),
                            ),
                          ),
                        ),
                
                        SizedBox(height: 23),
                
                        // Email
                        SettingsTile(
                          title: "Email",
                          icon: Icons.email_outlined,
                          onTap: () {},
                        ),
                
                        SizedBox(height: 23),
                
                        // Appearance header
                        Padding(
                          padding: const EdgeInsets.only(left: 27.0),
                          child: Text(
                            "APPEARANCE",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF364B55),
                            ),
                          ),
                        ),
                
                        SizedBox(height: 23),
                
                        // Theme
                        SettingsTile(
                          title: "Theme",
                          icon: Icons.contrast,
                          onTap: () {},
                        ),
                
                        SizedBox(height: 23),
                
                        // Chatbot customisation header
                        Padding(
                          padding: const EdgeInsets.only(left: 27.0),
                          child: Text(
                            "CHATBOT PREFERENCES",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF364B55),
                            ),
                          ),
                        ),
                
                        SizedBox(height: 23),
                
                        // Theme
                        SettingsTile(
                          title: "Response Length",
                          icon: Icons.square_foot_rounded,
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: "Response Tone",
                          icon: Icons.record_voice_over_rounded,
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: "Vocabulary",
                          icon: Icons.spellcheck_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                
                    // SafeArea for logout list tile
                    SafeArea(
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 27),
                        leading: Icon(Icons.logout, color: Color(0xFFCC0000)),
                        title: Text(
                          "Logout",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 16,
                            color: Color(0xFFCC0000),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFFCC0000),
                        ),
                        onTap: () => logout(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
