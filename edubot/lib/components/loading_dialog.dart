import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Return a material that mimics a dialog (primarily used when loading conversation 
    // to avoid using Buildcontext across asyncronous gaps)
    return const Material(
      color: Colors.black54,
      child: Center(child: CircularProgressIndicator(color: Colors.blue)),
    );
  }
}
