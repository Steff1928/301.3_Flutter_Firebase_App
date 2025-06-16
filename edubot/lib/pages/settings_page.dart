import 'package:edubot/components/dark_mode_toggle.dart';
import 'package:edubot/components/settings_tile.dart';
import 'package:edubot/pages/settings_pages/update_display_name_page.dart';
import 'package:edubot/pages/settings_pages/update_email_page.dart';
import 'package:edubot/pages/settings_pages/update_response_length_page.dart';
import 'package:edubot/pages/settings_pages/update_response_tone_page.dart';
import 'package:edubot/pages/settings_pages/update_vocab_page.dart';
import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final AuthManager authManager = AuthManager();

  // Logout method
  void logout(BuildContext context) async {
    // Get the AuthManager instance, navigator, and ChatProvider context
    final AuthManager authManager = AuthManager();
    final navigator = Navigator.of(context);
    final chatProviderContext = Provider.of<ChatProvider>(
      context,
      listen: false,
    );

    // Sign out the user and remove any messages from the chat provider
    await authManager.signOut();
    chatProviderContext.removeMessage();

    // Navigate to the AuthGate page and remove all previous routes
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
      resizeToAvoidBottomInset: false,
      // Top bar
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Settings",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),

      // Settings options
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display name (and Google Profile Pic if appplicable)
                    Row(
                      children: [
                        if (authManager.getCurrentUser()?.photoURL != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 23, top: 33),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                '${authManager.getCurrentUser()?.photoURL}',
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 23, top: 33),
                          child: Text(
                            "${authManager.getCurrentUser()?.displayName}",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 33),

                    // Settings options container

                    // Parent widget
                    Expanded(
                      child: Material(
                        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF364B55) : Color(0xFFF1F5F8),
                        borderRadius: BorderRadius.circular(12),

                        // Container to allow padding
                        child: Container(
                          padding: EdgeInsets.only(top: 33),

                          // Parent column for both settings options and logout list tile
                          child: SafeArea(
                            child: Column(
                              children: [
                                // Secondary column for only settings tiles
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Account header
                                    Padding(
                                      padding: const EdgeInsets.only(left: 27.0),
                                      child: Text(
                                        "GENERAL",
                                        style: TextStyle(
                                          fontFamily: "Nunito",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF99DAE6) : Color(0xFF364B55),
                                        ),
                                      ),
                                    ),
                            
                                    SizedBox(height: 23),
                            
                                    // Email
                                    SettingsTile(
                                      title: "Email",
                                      icon: Icons.email_outlined,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => UpdateEmailPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    // Display Name
                                    SettingsTile(
                                      title: "Display Name",
                                      icon: Icons.person_outline,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    UpdateDisplayNamePage(),
                                          ),
                                        );
                                      },
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
                                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF99DAE6) : Color(0xFF364B55),
                                        ),
                                      ),
                                    ),
                            
                                    SizedBox(height: 23),
                            
                                    // Theme
                                    DarkModeToggle(),
                            
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
                                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF99DAE6) : Color(0xFF364B55),
                                        ),
                                      ),
                                    ),
                            
                                    SizedBox(height: 23),
                            
                                    // Personalisation options
                                    SettingsTile(
                                      title: "Response Length",
                                      icon: Icons.square_foot_rounded,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    UpdateResponseLengthPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    SettingsTile(
                                      title: "Response Tone",
                                      icon: Icons.record_voice_over_outlined,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    UpdateResponseTonePage(),
                                          ),
                                        );
                                      },
                                    ),
                                    SettingsTile(
                                      title: "Vocabulary",
                                      icon: Icons.spellcheck_rounded,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => UpdateVocabPage(),
                                          ),
                                        );
                                      },
                                    ),
                            
                                    SizedBox(height: 23),
                            
                                    // Account header
                                    Padding(
                                      padding: const EdgeInsets.only(left: 27.0),
                                      child: Text(
                                        "ACCOUNT ACTIONS",
                                        style: TextStyle(
                                          fontFamily: "Nunito",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF99DAE6) : Color(0xFF364B55),
                                        ),
                                      ),
                                    ),
                            
                                    SizedBox(height: 23),
                            
                                    // Logout list tile
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 27,
                                      ),
                                      leading: Icon(
                                        Icons.logout,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      title: Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontFamily: "Nunito",
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      onTap: () => logout(context),
                                    ),
                            
                                    SizedBox(height: 23),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
