// import 'package:flutter/material.dart';

// class CustomElevatedButton extends StatefulWidget {
//   String text;
//   final VoidCallback onPressed;
//    CustomElevatedButton({super.key, required this.text, required this.onPressed});

//   @override
//   State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
// }

// class _CustomElevatedButtonState extends State<CustomElevatedButton> {
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(onPressed: widget.onPressed, child: Text(widget.text));
//   }
// }
import 'package:flutter/material.dart';

import '../constant/colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kblueaccent, // button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2, // halka shadow
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}