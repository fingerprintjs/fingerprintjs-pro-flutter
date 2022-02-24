import 'dart:async';

import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';

Future main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceId = 'Unknown';
  final String _apiKey = dotenv.env['API_KEY'] ?? 'test_api_key';

  @override
  void initState() {
    super.initState();
    initFpjs(_apiKey);
  }

  Future<void> initFpjs(String apiToken) async {
    await FpjsProPlugin.initFpjs(apiToken);
  }

  /// The native FingerprintJS libraries expose a methid called `getVisitorId`
  /// to stay consistent with the original Javascript library used for browser identification.
  /// However in the mobile application context a more accurate name would be something like `getDeviceId`.
  Future<void> getDeviceId() async {
    String deviceId;
    try {
      deviceId = await FpjsProPlugin.getVisitorId() ?? 'Unknown';
    } on PlatformException {
      deviceId = 'Failed to get device id.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _deviceId = deviceId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FPJS Pro Flutter plugin'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: getDeviceId, child: const Text('Identify!')),
            Text('The device id is: $_deviceId\n'),
          ],
        )),
      ),
    );
  }
}
