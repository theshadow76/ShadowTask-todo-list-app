import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAuthBTMBar extends StatelessWidget {
  const CustomAuthBTMBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
        onTap: () => launchUrl(Uri.parse('https://www.instagram.com/tienda_shadowtech_software/')),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50,
            width: 50,
            child: Image.asset("assets/images/instagram.png"),
          ),
        ),
      ),
      GestureDetector(
        onTap: () => launchUrl(Uri.parse('http://www.theshadowtech.com/')),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50,
            width: 50,
            child: Image.asset("assets/images/web.png"),
          ),
        ),
      ),
    ]);
  }
}
