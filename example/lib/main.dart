import 'dart:async';
import 'dart:convert';

import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpjs_pro_plugin/error.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:fpjs_pro_plugin/region.dart';
import 'package:geolocator/geolocator.dart';

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
  // Explicitly define which files to load to avoid
  // console warnings about not finding other possible .env files
  await dotenv.load(fileNames: ['.env', '.env.local']);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceId = 'Unknown';
  String _checksResult = 'Not run';
  String? _initializationError;
  final String? _apiKey = dotenv.env['API_KEY'];
  final String? _region = dotenv.env['REGION'];
  final String? _endpoint = dotenv.env['ENDPOINT'];
  final String? _scriptUrlPattern = dotenv.env['SCRIPT_URL_PATTERN'];

  @override
  void initState() {
    super.initState();
    _initFpjs();
  }

  Region? _parseRegion(String? region) {
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

  Future<void> _initFpjs() async {
    try {
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception('Set the API_KEY environment variable');
      }
      // Must use ! because field promotion only available in Dart >3.2
      // https://dart.dev/tools/non-promotion-reasons#language-version
      await FpjsProPlugin.initFpjs(_apiKey!,
          endpoint: _endpoint,
          scriptUrlPattern: _scriptUrlPattern,
          region: _parseRegion(_region),
          allowUseOfLocationData: true,
          locationTimeoutMillis: 6000,
          extendedResponseFormat: true);
    } catch (error) {
      // print('Failed to initialize Fingerprint agent: $error');
      setState(() {
        _initializationError = 'Failed to initialize Fingerprint agent: $error';
      });
    }
  }

  Future<void> requestLocationPermission() async {
    if (kIsWeb) {
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  /// The native FingerprintJS libraries expose a method called `getVisitorId`
  /// to stay consistent with the original Javascript library used for browser identification.
  /// However in the mobile application context a more accurate name would be something like `getDeviceId`.
  Future<void> _getDeviceId() async {
    await requestLocationPermission();
    String deviceId;
    try {
      deviceId = await FpjsProPlugin.getVisitorId(
              tags: tags, linkedId: 'some linkedId') ??
          'Unknown';
    } catch (error) {
      deviceId = 'Failed to get device id: $error';
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
    await requestLocationPermission();
    String identificationInfo;
    try {
      const encoder = JsonEncoder.withIndent('    ');
      final deviceData = await FpjsProPlugin.getVisitorData(
          tags: tags, linkedId: 'some linkedId');
      final jsonDeviceData = deviceData.toJson();
      if (deviceData.sealedResult != null &&
          deviceData.sealedResult!.isNotEmpty) {
        jsonDeviceData["sealedResult"] = deviceData.sealedResult
            ?.replaceRange(10, deviceData.sealedResult?.length, '...');
      }
      identificationInfo = encoder.convert(jsonDeviceData);
    } on FingerprintProError catch (error) {
      identificationInfo = "Failed to get device info.\n$error";
    }
    return identificationInfo;
  }

  Future<void> _runChecks() async {
    await requestLocationPermission();
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
        () async => FpjsProPlugin.getVisitorId(timeoutMs: 5000),
        () async => FpjsProPlugin.getVisitorData(timeoutMs: 5000),
      ];

      var timeoutChecks = [
        () async => FpjsProPlugin.getVisitorId(timeoutMs: 5),
        () async => FpjsProPlugin.getVisitorData(timeoutMs: 5)
      ];

      for (var check in checks) {
        await check();
        setState(() {
          _checksResult += '.';
        });
      }
      for (var check in timeoutChecks) {
        try {
          await check();
          throw Exception('Expected timeout error');
        } on FingerprintProError {
          setState(() {
            _checksResult += '!';
          });
        }
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
          if (_initializationError != null) Text(_initializationError!),
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

  final Future<String> Function() handleIdentificate;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final resultContext = context;
        String identificationInfo;
        try {
          identificationInfo = await handleIdentificate();
        } catch (e) {
          identificationInfo = 'Identification error: $e';
        }
        if (resultContext.mounted) {
          showDialog<String>(
            context: resultContext,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Extended result'),
              content: FittedBox(
                fit: BoxFit.contain,
                child: Text(identificationInfo),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: const Text('Identify with extended result!'),
    );
  }
}
