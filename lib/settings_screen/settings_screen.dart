import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:multilang/settings_screen/languages_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Languages'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguagesScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy'),
          onTap: () async {
            await _launchUrl(Uri.parse("https://joeperpetua.github.io/multilang/privacy-policy.html"));
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () async {
            await _launchUrl(Uri.parse("https://joeperpetua.github.io/#multilang"));
          },
        ),
      ],
    );
  }
}
