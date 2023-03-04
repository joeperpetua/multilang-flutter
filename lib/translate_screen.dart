import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  static const platform = MethodChannel('app.channel.shared.data');
  String dataShared = '';

  @override
  void initState() {
    super.initState();
    getSharedText();
  }

  Future<void> getSharedText() async {
    var intentText = await platform.invokeMethod('getSharedText');
    debugPrint("DEBUG: asking for intent");
    if (intentText != null) {
      debugPrint("DEBUG: INTENT=$intentText");
      setState(() {
        dataShared = intentText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Home page (Translate): $dataShared',
          ),
        ],
      ),
    );
  }
}
