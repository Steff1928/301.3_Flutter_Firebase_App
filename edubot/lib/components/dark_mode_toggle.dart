import 'package:edubot/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DarkModeToggle extends StatefulWidget {
  const DarkModeToggle({super.key});

  @override
  State<DarkModeToggle> createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends State<DarkModeToggle> {
  @override
  Widget build(BuildContext context) {
    // Get themeProvider and systemBrightness to keep track of platform theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    // Determine switch state for app theme
    final isDark = switch (themeProvider.mode) {
      AppThemeMode.dark => true,
      AppThemeMode.light => false,
      AppThemeMode.system => systemBrightness == Brightness.dark,
    };

    return SwitchListTile(
      // Set the tile style
      contentPadding: EdgeInsets.symmetric(horizontal: 27),
      activeColor: Color(0xFF1A1A1A),
      inactiveThumbColor: Color(0xFF1A1A1A),
      activeTrackColor: Color(0xFF99DAE6),
      title: Text(
        "Dark Mode",
        style: TextStyle(
          fontFamily: "Nunito",
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      // Set the value and toggle the theme upon value changed
      value: isDark,
      onChanged: (bool value) {
        themeProvider.toggleTheme(value);
      },
      secondary: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.onSecondary),
    );
  }
}
