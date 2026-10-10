import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class CompassService {
  /// Stream of device heading in degrees (0..360 from magnetic/true north)
  Stream<double?> getHeadingStream() {
    return FlutterCompass.events?.map((event) => event.heading) ??
        const Stream.empty();
  }
}
