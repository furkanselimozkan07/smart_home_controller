import 'connectable.dart';
import 'schedulable.dart';
import 'smart_device.dart';

/// A dimmable light bulb.
///
/// `extends` [SmartDevice] (inheritance), mixes in [Schedulable] (mixin)
/// and `implements` [Connectable] (interface).
class SmartLight extends SmartDevice with Schedulable implements Connectable {
  static const int minBrightness = 1;
  static const int maxBrightness = 100;
  static const int defaultBrightness = 75;

  int _brightness;
  bool _connected = true;

  /// Default constructor. `super.room` and `super.isOn` forward the values
  /// to the [SmartDevice] constructor.
  SmartLight(super.room, {int brightness = defaultBrightness, super.isOn})
      : _brightness = brightness.clamp(minBrightness, maxBrightness);

  /// Named constructor for a light that starts switched off. It calls the
  /// named super constructor [SmartDevice.off].
  SmartLight.off(super.room)
      : _brightness = defaultBrightness,
        super.off();

  /// Remembered brightness level (1-100). It is kept while the light is off
  /// so the light comes back at the same level.
  int get brightness => _brightness;

  set brightness(int value) {
    _brightness = value.clamp(minBrightness, maxBrightness);
  }

  /// Brightness the user actually sees: 0 when the light is off.
  int get effectiveBrightness => isOn ? _brightness : 0;

  /// Changes the brightness; `this` separates the field from the parameter.
  void setBrightness(int brightness) {
    if (!_connected) return;
    this.brightness = brightness;
    if (!isOn) isOn = true;
  }

  @override
  String get typeLabel => 'Smart Light';

  @override
  String get primaryProperty => 'Brightness: $effectiveBrightness%';

  @override
  String getStatus() {
    if (!_connected) return 'Offline';
    return isOn ? 'ON' : 'OFF';
  }

  @override
  bool get isActive => _connected && isOn;

  /// Toggles the light on and off.
  @override
  void performAction() {
    if (!_connected) return;
    isOn = !isOn;
  }

  @override
  Map<String, String> details() => {
        ...super.details(),
        'Brightness': '$brightness%',
        'Connection': connectionInfo(),
        'Schedule': scheduleSummary,
      };

  // ----- Connectable -----

  @override
  String get protocol => 'Zigbee';

  @override
  bool get isConnected => _connected;

  @override
  void connect() => _connected = true;

  @override
  void disconnect() => _connected = false;

  @override
  String connectionInfo() =>
      _connected ? 'Connected via $protocol' : 'Disconnected ($protocol)';
}
