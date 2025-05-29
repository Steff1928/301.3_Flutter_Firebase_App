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
      contentPadding: EdgeInsets.symmetric(horizontal: 27),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Nunito",
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.secondary),
    );
  }
}
