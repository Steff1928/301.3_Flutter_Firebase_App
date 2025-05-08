import 'package:flutter/material.dart';

class SsoTile extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  const SsoTile({super.key, required this.imagePath, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            fixedSize: Size(width, height),
            side: BorderSide(width: 1, color: Color(0xFF074F67)),
            backgroundColor: Color(0xFFFAFAFA),
            foregroundColor: Color(0xFF364B55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Image.asset(imagePath, width: 24, height: 24,),
              ),
              Text(
                "Continue with Google",
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF364B55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
