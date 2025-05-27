import 'package:edubot/components/primary_button.dart';
import 'package:flutter/material.dart';

class UpdateResponseLengthPage extends StatefulWidget {
  const UpdateResponseLengthPage({super.key});

  @override
  State<UpdateResponseLengthPage> createState() => _UpdateResponseLengthPageState();
}

class _UpdateResponseLengthPageState extends State<UpdateResponseLengthPage> {
  double _currentValue = 0;

  final List<String> tokenLengths = ["Concise", "Normal", "Lengthy"];

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
            "Response Length",
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
                  padding: const EdgeInsets.only(left: 27.0, right: 27, top: 10),
                  child: Center(
                    child: Text(
                      "Adjust the slider to customise how long you wish EduBot's responses to be.",
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
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Center(
                    child: Text(
                      tokenLengths[_currentValue.toInt()],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Slider(
                    value: _currentValue,
                    min: 0,
                    max: 2,
                    activeColor: Colors.blue.shade400,
                    inactiveColor: Colors.blue.shade100,
                    divisions: 2,
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                      });
                    },
                  ),
                ),
            
                SizedBox(height: 15),
            
                PrimaryButton(text: "Save Changes", height: 45, onPressed: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }
}
