import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant/colors.dart';

class FileDockTextField extends StatelessWidget {
  final TextEditingController linkController;
  final VoidCallback? onTap;

  const FileDockTextField({
    super.key,
    required this.onTap,
    required this.linkController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 332,
      decoration: BoxDecoration(
        color: kbg2lightblack300, // Dark background
        borderRadius: BorderRadius.circular(14), // Rounded edges
      ),
      child: Row(
        children: [
          SizedBox(
            width: 270,
            height: 38,
            child: TextField(
              cursorColor: kwhite300,
              controller: linkController,
              style: TextStyle(
                color: kwhite,
                fontSize: 14,
                fontFamily: 'Montserrat-Regular',
                fontWeight: FontWeight.w400,
              ), // White text
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 12, bottom: 8), // 👈 replaces Padding
                border: InputBorder.none,
                hintText: "Input your FileDock link to access video",
                hintStyle: TextStyle(
                  color: kwhite300,
                  fontSize: 14,
                  fontFamily: 'Montserrat-Regular',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4,),
          GestureDetector(
            behavior: HitTestBehavior.translucent, // 👈 ensures taps register even on transparent parts
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/svgicon/Polygon 2.svg',
                width: 29,
                height: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
