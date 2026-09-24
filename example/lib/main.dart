import 'dart:async';
import 'dart:convert';

import 'package:env_flutter/env_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:geolocator/geolocator.dart';

const tags = {
  'a': 'a',
  'b': 0,
  'c': {
    'foo': true,
    'bar': [1, 2, 3],
  },
  'd': false,
};

const runChecksButtonKey = ValueKey('run-checks-button');
const identifyButtonKey = ValueKey('identify-button');
const visitorDataButtonKey = ValueKey('visitor-data-button');

enum InitializationState { initializing, created, error }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Flutter web needs its accessibility DOM for external UI automation.
    // https://docs.maestro.dev/get-started/supported-platform/flutter
    SemanticsBinding.instance.ensureSemantics();
  }
  // Explicitly define which files to load to avoid
  // console warnings about not finding other possible .env files
  await dotenv.load(fileNames: ['.env', '.env.local']);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceId = 'Unknown';
  String _checksResult = 'Not run';
  InitializationState _initializationState = InitializationState.initializing;
  String? _initializationError;
  Fingerprint? _client;
  final String? _apiKey = dotenv.env['API_KEY'];
  final String? _region = dotenv.env['REGION'];
  final String? _endpoints = dotenv.env['ENDPOINTS'];
  final bool _disableLocationCollection =
      dotenv.env['DISABLE_LOCATION_COLLECTION']?.toLowerCase() == 'true';

  @override
  void initState() {
    super.initState();
    _createClient();
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

  void _createClient() {
    try {
      if (_apiKey == null || _apiKey.isEmpty) {
        throw Exception('Set the API_KEY environment variable');
      }
      _client = Fingerprint(
        apiKey: _apiKey,
        region: _parseRegion(_region),
        endpoints: _endpoints == null || _endpoints.isEmpty ? null : [_endpoints],
        android: AndroidOptions(
          allowUseOfLocationData: !_disableLocationCollection,
          locationTimeout: const Duration(milliseconds: 6000),
        ),
        ios: IosOptions(allowUseOfLocationData: !_disableLocationCollection),
      );
      _initializationState = InitializationState.created;
    } catch (error) {
      _initializationState = InitializationState.error;
      _initializationError = 'Failed to create Fingerprint client: $error';
    }
  }

  Future<void> requestLocationPermission() async {
    if (kIsWeb || _disableLocationCollection) {
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permissions are denied');
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }
      return;
    }
  }

  Future<void> _getDeviceId() async {
    await requestLocationPermission();
    String deviceId;
    try {
      final result = await _client!.get(tags: tags, linkedId: 'some linkedId');
      deviceId = result.visitorId ?? 'Unknown';
    } catch (error) {
      deviceId = 'Failed to get device id: $error';
    }

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
      final result = await _client!.get(tags: tags, linkedId: 'some linkedId');
      var sealedResult = result.sealedResult;
      if (sealedResult != null && sealedResult.length > 10) {
        sealedResult = sealedResult.replaceRange(
          10,
          sealedResult.length,
          '...',
        );
      }
      identificationInfo = encoder.convert({
        'eventId': result.eventId,
        'visitorId': result.visitorId,
        'suspectScore': result.suspectScore,
        'sealedResult': sealedResult,
        'cacheHit': result.cacheHit,
      });
    } on FingerprintError catch (error) {
      identificationInfo = 'Failed to get device info.\n$error';
    }
    return identificationInfo;
  }

  Future<void> _runChecks() async {
    await requestLocationPermission();
    setState(() {
      _checksResult = 'Running';
    });
    try {
      final client = _client!;
      var checks = [
        () => client.get(),
        () => client.get(linkedId: 'checkId'),
        () => client.get(tags: tags),
        () => client.get(linkedId: 'checkIdWithTag', tags: tags),
        () => client.get(timeout: const Duration(milliseconds: 5000)),
      ];

      var timeoutChecks = [
        () => client.get(timeout: const Duration(milliseconds: 5)),
      ];

      // The timeout checks cancel a request mid-flight. On iOS the call right after
      // such a cancellation fails with "NetworkError: The network connection was
      // lost", so run them first and leave the plain checks last.
      for (var check in timeoutChecks) {
        try {
          await check();
          throw Exception('Expected timeout error');
        } on FingerprintError {
          if (!mounted) return;
          setState(() {
            _checksResult += '!';
          });
        }
      }
      for (var check in checks) {
        await check();
        if (!mounted) return;
        setState(() {
          _checksResult += '.';
        });
      }
      if (!mounted) return;
      setState(() {
        _checksResult = 'Success!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checksResult = 'Failed: $e';
      });
    }
  }

  String get _initializationStatus {
    switch (_initializationState) {
      case InitializationState.initializing:
        return 'Creating Fingerprint client...';
      case InitializationState.created:
        return 'Fingerprint client created';
      case InitializationState.error:
        return _initializationError!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreated = _initializationState == InitializationState.created;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('FPJS Pro Flutter plugin')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_initializationStatus),
              ElevatedButton(
                key: runChecksButtonKey,
                onPressed: isCreated ? _runChecks : null,
                child: const Text('Run tests!'),
              ),
              const Text('Checks result:'),
              Text(_checksResult),
              ElevatedButton(
                key: identifyButtonKey,
                onPressed: isCreated ? _getDeviceId : null,
                child: const Text('Identify!'),
              ),
              const Text('The device id is:'),
              Text(_deviceId),
              _VisitorDataDialog(
                enabled: isCreated,
                loadVisitorData: _getDeviceData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitorDataDialog extends StatelessWidget {
  const _VisitorDataDialog({
    required this.enabled,
    required this.loadVisitorData,
  });

  final bool enabled;
  final Future<String> Function() loadVisitorData;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: visitorDataButtonKey,
      onPressed: enabled
          ? () async {
              final resultContext = context;
              String identificationInfo;
              try {
                identificationInfo = await loadVisitorData();
              } catch (e) {
                identificationInfo = 'Identification error: $e';
              }
              if (resultContext.mounted) {
                showDialog<String>(
                  context: resultContext,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Visitor data'),
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
            }
          : null,
      child: const Text('Get visitor data!'),
    );
  }
}
