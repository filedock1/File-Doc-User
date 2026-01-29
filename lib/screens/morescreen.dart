import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../adwidgets/bannerad.dart';
import '../constant/colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // 🔗 Open external links safely
Future<void> _openLink(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    debugPrint('Could not launch $url');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        backgroundColor: kbg1black500,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svgicon/logo.svg',
              width: 33,
              height: 30,
            ),
            const SizedBox(width: 9),
            Image.asset(
              'assets/images/FileDock.png',
              width: 136,
              height: 36,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: kbg1black500,
          image: const DecorationImage(
            image: AssetImage('assets/images/dottedimg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔝 Top Banner Ad
                const CustomBannerAd(
                  bannerKey: 'morescreen_banner1',
                ),

                const SizedBox(height: 56),

                // 🔥 App Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'File',
                      style: TextStyle(
                        color: kwhite,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Syne-SemiBold',
                      ),
                    ),
                    Text(
                      'Dock',
                      style: TextStyle(
                        color: kblueaccent,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Syne-SemiBold',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Is a dynamic video player',
                  style: TextStyle(
                    color: kwhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat-Medium',
                  ),
                ),

                const SizedBox(height: 58),

                // 🌐 Follow Us
                Column(
                  children: [
                    Text(
                      'Follow us',
                      style: TextStyle(
                        color: kwhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat-Medium',
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Instagram
                        InkWell(
                          onTap: () => _openLink(
                            'https://www.instagram.com/filedock_?igsh=MWFrMjNnYzkzc3NqYQ==',
                          ),
                          child: SvgPicture.asset(
                            'assets/svgicon/instagram.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // YouTube
                        InkWell(
                          onTap: () => _openLink(
                            'https://youtube.com/@filedock-official?si=z8X8HuMpphjSyqKu',
                          ),
                          child: SvgPicture.asset(
                            'assets/svgicon/youtube.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Telegram
                        InkWell(
                          onTap: () => _openLink('https://t.me/FiledockTeam'),
                          child: SvgPicture.asset(
                            'assets/svgicon/telegram.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        const SizedBox(width: 10),

                        //discord
                        InkWell(
                          onTap: () => _openLink(
                            'https://discord.gg/filedock',
                          ),
                          child: SvgPicture.asset(
                            'assets/svgicon/discord.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 📩 Telegram Support
                    InkWell(
                      onTap: () => _openLink('https://t.me/FiledockTeam'),
                      child: Text(
                        'Telegram Support: @FiledockTeam',
                        style: TextStyle(
                          color: kblueaccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat-Medium',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 📜 Policy Links
                Column(
                  children: const [
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: kwhite200,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat-Medium',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Terms & Condition',
                      style: TextStyle(
                        color: kwhite200,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat-Medium',
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 🔻 Bottom Banner Ad
                const CustomBannerAd(
                  bannerKey: 'morescreen_banner2',
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
