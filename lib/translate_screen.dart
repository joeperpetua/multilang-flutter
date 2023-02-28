import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  static const platform = MethodChannel('app.channel.shared.data');
  String dataShared = 'No data';

  @override
  void initState() {
    super.initState();
    getSharedText();
  }

  Future<void> getSharedText() async {
    var sharedData = await platform.invokeMethod('getSharedText');
    debugPrint(
        "\n\n============================================== debug: INDENT=$sharedData ==============================================\n\n");
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
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
