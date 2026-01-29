
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constant/colors.dart';

class HomeTitleSubTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String svgAssetPath;

  const HomeTitleSubTitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.svgAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 131,
      width: 282,
      decoration: BoxDecoration(
        color: kbg2lightblack300, // Dark background
        borderRadius: BorderRadius.circular(18), // Rounded edges
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          SvgPicture.asset(svgAssetPath, height: 31, width: 31),
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center, // ✅ Center text
              style: TextStyle(
                color: kwhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat-SemiBold',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center, // ✅ Center text
            style: TextStyle(
              color: kwhite,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat-Regular',
            ),
          ),
        ],
      ),
    );
  }
}