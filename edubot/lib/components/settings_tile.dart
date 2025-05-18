import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  // Initialize the required variables
  final String title;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Set the tile style
      contentPadding: EdgeInsets.symmetric(horizontal: 27, vertical: 8),
      leading: Icon(icon, color: Color(0xFF1A1A1A)),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Nunito",
          fontSize: 16,
          color: Color(0xFF1A1A1A),
        ),
      ),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF364B55)),
    );
  }
}
