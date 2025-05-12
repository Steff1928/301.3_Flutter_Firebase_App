import 'package:flutter/material.dart';

class LoadingAnim extends StatefulWidget {
  const LoadingAnim({super.key});

  @override
  State<LoadingAnim> createState() => LoadingAnimState();
}

class LoadingAnimState extends State<LoadingAnim>
    with SingleTickerProviderStateMixin {
  // Create AnimationController
  late AnimationController _controller;

  // Initialise animation state
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(); // Loops the rotation
  }

  // Dispose of the animation controller upon being removed from the animation tree
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _controller, child: Icon(Icons.sync),);
  }
}
