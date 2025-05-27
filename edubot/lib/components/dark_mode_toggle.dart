import 'package:flutter/material.dart';

class DarkModeToggle extends StatefulWidget {
  const DarkModeToggle({super.key});

  @override
  State<DarkModeToggle> createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends State<DarkModeToggle> {
  bool _isEnabled = false;

  @override
  Widget build(BuildContext context) {
    
    return SwitchListTile(
      // Set the tile style
      contentPadding: EdgeInsets.symmetric(horizontal: 27),
      activeColor: Color(0xFFFAFAFA),
      inactiveThumbColor: Color(0xFF1A1A1A),
      activeTrackColor: Colors.blue,
      title: Text(
        "Dark Mode",
        style: TextStyle(
          fontFamily: "Nunito",
          fontSize: 16,
          color: Color(0xFF1A1A1A),
        ),
      ),
      value: _isEnabled,
      onChanged: (bool value) {
        setState(() {
          _isEnabled = value;
        });
        // TODO: Implement dark mode toggle functionality
      },
      secondary: Icon(Icons.dark_mode_outlined, color: Color(0xFF1A1A1A)),
    );
  }
}
