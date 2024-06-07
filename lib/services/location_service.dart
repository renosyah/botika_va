import 'dart:async';
import 'package:botika_va/utils/permission_request.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationService {
  final Map<String, LocationserviceHandler> _subscribers =
      <String, LocationserviceHandler>{};
  bool _isInitialize = false;

  Timer? timer;

  bool get isInitialize => _isInitialize;

  void addSttSubscriber(String name, LocationserviceHandler handler) {
    if (hasSubscriber(name)) {
      return;
    }
    _subscribers[name] = handler;
  }

  bool hasSubscriber(String name) {
    return _subscribers.containsKey(name);
  }

  void removeSttSubscriber(String name) {
    if (!hasSubscriber(name)) {
      return;
    }
    _subscribers.remove(name);
  }

  Future<void> startUpdate() async {
    bool gpsEnable = false;

    gpsEnable = await isGpsEnable();
    if (!gpsEnable) {
      Location location = Location();
      bool locationService = await location.serviceEnabled();
      if (!locationService) {
        locationService = await location.requestService();
      }

      await Future.delayed(const Duration(seconds: 1));
      gpsEnable = await isGpsEnable();
    }

    if (gpsEnable) {
      _isInitialize = await requestGpsPermission();
    }

    if (_isInitialize) {
      timer = Timer.periodic(const Duration(minutes: 10), (_) => getUpdate());
    }
  }

  void getUpdate() async {
    bool gpsEnable = await isGpsEnable();
    if (!gpsEnable) return;

    Position position = await Geolocator.getCurrentPosition();

    _subscribers.forEach((_, value) {
      value.onPositionUpdate(position);
    });
  }

  void dispose() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    _subscribers.clear();
  }
}

abstract class LocationserviceHandler {
  void onPositionUpdate(Position position);
}
