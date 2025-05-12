import 'package:edubot/pages/register_account_page.dart';
import 'package:edubot/pages/user_login_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  // Create a boolean variable to track the current page
  final bool showLoginPage;

  const LoginOrRegister({super.key, required this.showLoginPage});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();  
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  late bool _showLoginPage; // Local mutable instance of showLoginPage

  // Initialize the state with the value from the widget
  @override
  void initState() {
    super.initState();
    _showLoginPage = widget.showLoginPage;
  }

  // Function to toggle between login and register pages
  void togglePages() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return the appropriate page based on the boolean value
    if (_showLoginPage) {
      return UserLoginPage(onTap: togglePages,);
    } else {
      return RegisterAccountPage(onTap: togglePages,);
    }
  }
}