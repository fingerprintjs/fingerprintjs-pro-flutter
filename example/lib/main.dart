import 'dart:async';
import 'dart:convert';

import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/region.dart';

const tags = {
  'a': 'a',
  'b': 0,
  'c': {
    'foo': true,
    'bar': [1, 2, 3]
  },
  'd': false
};

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
  String _checksResult = 'Not runned';
  final String _apiKey = dotenv.env['API_KEY'] ?? 'test_api_key';
  final bool _useProxyIntegration = dotenv.env['PROXY_INTEGRATION_PATH'] != '';
  final String _proxyIntegrationPath =
      dotenv.env['PROXY_INTEGRATION_PATH'] ?? 'no_proxy_integration';
  final String _proxyIntegrationRequestPath =
      dotenv.env['PROXY_INTEGRATION_REQUEST_PATH'] ?? 'no_proxy_integration';
  final String? _proxyIntegrationScriptPath =
      dotenv.env['PROXY_INTEGRATION_SCRIPT_PATH'] ?? 'no_proxy_integration';
  final String _region = dotenv.env['REGION'] ?? 'us';

  @override
  void initState() {
    super.initState();
    _initFpjs(_apiKey);
  }

  Region? _parseRegion(String region) {
    switch (region) {
      case 'us':
        return Region.us;
      case 'eu':
        return Region.eu;
      case 'ap':
        return Region.ap;
    }
    return null;
  }

  Future<void> _initFpjs(String apiToken) async {
    if (_useProxyIntegration) {
      final region = _parseRegion(_region);
      final regionQueryParam = (region != null && region != Region.us)
          ? "?region=${region.stringValue}"
          : '';
      await FpjsProPlugin.initFpjs(apiToken,
          extendedResponseFormat: true,
          endpoint:
              "$_proxyIntegrationPath/$_proxyIntegrationRequestPath$regionQueryParam",
          scriptUrlPattern:
              "$_proxyIntegrationPath/$_proxyIntegrationScriptPath",
          region: region);
    } else {
      await FpjsProPlugin.initFpjs(apiToken, extendedResponseFormat: true);
    }
  }

  /// The native FingerprintJS libraries expose a method called `getVisitorId`
  /// to stay consistent with the original Javascript library used for browser identification.
  /// However in the mobile application context a more accurate name would be something like `getDeviceId`.
  Future<void> _getDeviceId() async {
    String deviceId;
    try {
      deviceId = await FpjsProPlugin.getVisitorId(
              tags: tags, linkedId: 'some linkedId') ??
          'Unknown';
    } on FingerprintProError {
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

  Future<String> _getDeviceData() async {
    String identificationInfo;
    try {
      const encoder = JsonEncoder.withIndent('    ');
      final deviceData = await FpjsProPlugin.getVisitorData(
          tags: tags, linkedId: 'some linkedId');
      identificationInfo = encoder.convert(deviceData);
    } on FingerprintProError catch (error) {
      identificationInfo = "Failed to get device info.\n$error";
    }
    return identificationInfo;
  }

  Future<void> _runChecks() async {
    setState(() {
      _checksResult = 'Running';
    });
    try {
      var checks = [
        () async => FpjsProPlugin.getVisitorId(),
        () async => FpjsProPlugin.getVisitorData(),
        () async => FpjsProPlugin.getVisitorId(linkedId: 'checkId'),
        () async => FpjsProPlugin.getVisitorData(linkedId: 'checkData'),
        () async => FpjsProPlugin.getVisitorId(tags: tags),
        () async => FpjsProPlugin.getVisitorData(tags: tags),
        () async =>
            FpjsProPlugin.getVisitorId(linkedId: 'checkIdWithTag', tags: tags),
        () async => FpjsProPlugin.getVisitorData(
            linkedId: 'checkDataWithTag', tags: tags),
      ];

      for (var _check in checks) {
        await _check();
        setState(() {
          _checksResult += '.';
        });
      }
      setState(() {
        _checksResult = 'Success!';
      });
    } catch (e) {
      setState(() {
        _checksResult = 'Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FPJS Pro Flutter plugin'),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
              onPressed: () => _runChecks(), child: const Text('Run tests!')),
          Text('Checks result: $_checksResult\n'),
          ElevatedButton(
              onPressed: () => _getDeviceId(), child: const Text('Identify!')),
          Text('The device id is: $_deviceId\n'),
          _ExtendedResultDialog(handleIdentificate: _getDeviceData)
        ])),
      ),
    );
  }
}

class _ExtendedResultDialog extends StatelessWidget {
  const _ExtendedResultDialog({Key? key, required this.handleIdentificate})
      : super(key: key);

  final AsyncCallback handleIdentificate;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {
        handleIdentificate().then((identificationInfo) => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Extended result'),
                content: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(identificationInfo as String),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ))
      },
      child: const Text('Identify with extended result!'),
    );
  }
}
