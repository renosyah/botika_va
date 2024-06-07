import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> isGpsEnable() async {
  bool serviceEnabled = false;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  return serviceEnabled;
}

Future<bool> requestGpsPermission() async {
  List<LocationPermission> accepts = [
    LocationPermission.always,
    LocationPermission.whileInUse,
  ];

  LocationPermission permission = await Geolocator.checkPermission();
  if (accepts.contains(permission)) {
    return true;
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  List<LocationPermission> denieds = [
    LocationPermission.denied,
    LocationPermission.deniedForever,
  ];
  permission = await Geolocator.requestPermission();
  if (denieds.contains(permission)) {
    return false;
  }

  return accepts.contains(permission);
}

Future<bool> isSttFeatureDenied() async {
  List<PermissionStatus> results = [
    await Permission.microphone.status,
    await Permission.speech.status,
  ];

  List<PermissionStatus> notOkStatus = [
    PermissionStatus.denied,
    PermissionStatus.restricted,
    PermissionStatus.limited,
    PermissionStatus.permanentlyDenied,
  ];

  for (PermissionStatus i in notOkStatus) {
    if (results.contains(i)) {
      return true;
    }
  }

  return false;
}

Future<bool> requestSttFeaturePermission() async {
  try {
    Map<Permission, PermissionStatus> results = await [
      Permission.microphone,
      Permission.speech,
    ].request();

    List<PermissionStatus> notOkStatus = [
      PermissionStatus.denied,
      PermissionStatus.restricted,
      PermissionStatus.limited,
      PermissionStatus.permanentlyDenied,
    ];

    for (PermissionStatus i in notOkStatus) {
      if (results.values.contains(i)) {
        return false;
      }
    }

    return true;
  } catch (_) {}

  return false;
}

Future<bool> isMicPermissionDenied() async {
  List<PermissionStatus> results = [
    await Permission.microphone.status,
  ];

  List<PermissionStatus> notOkStatus = [
    PermissionStatus.denied,
    PermissionStatus.restricted,
    PermissionStatus.limited,
    PermissionStatus.permanentlyDenied,
  ];

  for (PermissionStatus i in notOkStatus) {
    if (results.contains(i)) {
      return true;
    }
  }

  return false;
}

Future<bool> requestMicPermission() async {
  try {
    Map<Permission, PermissionStatus> results = await [
      Permission.microphone,
    ].request();

    List<PermissionStatus> notOkStatus = [
      PermissionStatus.denied,
      PermissionStatus.restricted,
      PermissionStatus.limited,
      PermissionStatus.permanentlyDenied,
    ];

    for (PermissionStatus i in notOkStatus) {
      if (results.values.contains(i)) {
        return false;
      }
    }

    return true;
  } catch (_) {}

  return false;
}

Future<bool> isStoragePermissionDenied() async {
  int? sdk = await getDeviceSdkLevel();
  if (sdk == null) {
    return true;
  }

  List<PermissionStatus> results = [];

  if (sdk >= 33) {
    results.addAll([
      await Permission.photos.status,
      await Permission.audio.status,
      await Permission.videos.status,
    ]);

    //
  } else {
    results.addAll([await Permission.storage.status]);
  }

  List<PermissionStatus> notOkStatus = [
    PermissionStatus.denied,
    PermissionStatus.restricted,
    PermissionStatus.limited,
    PermissionStatus.permanentlyDenied,
  ];

  for (PermissionStatus i in notOkStatus) {
    //print("luna - result $results");

    if (results.contains(i)) {
      return true;
    }
  }

  return false;
}

Future<int?> getDeviceSdkLevel() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.sdkInt;
}

Future<bool> requestStoragePermission() async {
  int? sdk = await getDeviceSdkLevel();
  if (sdk == null) {
    return false;
  }

  try {
    List<PermissionStatus> results;

    if (sdk >= 33) {
      results = [
        await Permission.photos.request(),
        await Permission.audio.request(),
        await Permission.videos.request(),
      ];

      //
    } else {
      results = [await Permission.storage.request()];
    }

    List<PermissionStatus> notOkStatus = [
      PermissionStatus.denied,
      PermissionStatus.restricted,
      PermissionStatus.limited,
      PermissionStatus.permanentlyDenied,
    ];

    for (PermissionStatus i in notOkStatus) {
      //print("luna - req $results");

      if (results.contains(i)) {
        return false;
      }
    }

    return true;
  } catch (_) {}

  return false;
}
