import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

class UpdateDisplayNamePage extends StatefulWidget {
  const UpdateDisplayNamePage({super.key});

  @override
  State<UpdateDisplayNamePage> createState() => _UpdateDisplayNamePageState();
}

class _UpdateDisplayNamePageState extends State<UpdateDisplayNamePage> {
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the display name controller with the current user's display name
    AuthManager authManager = AuthManager();
    _displayNameController.text = authManager.getCurrentUser()?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF074F67)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Display Name",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF074F67),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 27.0,
                    right: 27,
                    top: 10,
                  ),
                  child: Center(
                    child: Text(
                      "The name that will be used to address you in conversations with EduBot. You can change it at any time.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 16,
                        color: Color(0xFF364B55),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 50),

                PrimaryTextField(
                  controller: _displayNameController,
                  label: "Display Name",
                  obscureText: false,
                ),

                SizedBox(height: 25),

                PrimaryButton(
                  text: "Save Changes",
                  height: 45,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
