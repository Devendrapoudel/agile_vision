import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFunctions get functions => FirebaseFunctions.instance;

  // Physical Android/iOS devices need the Mac's actual LAN IP — they cannot
  // reach 'localhost' or '10.0.2.2' (that alias is emulator-only).
  // Android emulators use 10.0.2.2. iOS simulators / web use localhost.
  //
  // Run `ipconfig getifaddr en0` on your Mac to find your LAN IP,
  // then set it below. Keep your phone and Mac on the same WiFi network.
  static const String _physicalDeviceHost = '192.168.1.128'; // ← your Mac's LAN IP

  static String get _emulatorHost {
    if (kIsWeb) return 'localhost';
    // Android: emulator uses 10.0.2.2, physical device uses LAN IP
    if (Platform.isAndroid) {
      // Heuristic: emulators report a build fingerprint containing "generic"
      // but the safest approach for a dev project is to use the LAN IP always
      // for Android since it works for both emulator-via-network and physical.
      return _physicalDeviceHost;
    }
    // iOS simulator uses localhost; physical iOS device needs LAN IP too
    return _physicalDeviceHost;
  }

  static void connectToEmulators() {
    final host = _emulatorHost;
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }
}
