import 'connectable.dart';
import 'schedulable.dart';
import 'smart_device.dart';

/// A room thermostat with a target temperature.
///
/// `extends` [SmartDevice], mixes in [Schedulable] and `implements`
/// [Connectable].
class Thermostat extends SmartDevice with Schedulable implements Connectable {
  static const int minTemperature = 16;
  static const int maxTemperature = 30;
  static const int defaultTemperature = 22;
  static const int ecoTemperature = 19;

  /// Clamps any value into the supported range. Static helper: it belongs to
  /// the class and needs no object.
  static int clampTemperature(int value) =>
      value.clamp(minTemperature, maxTemperature);

  int _targetTemperature;

  /// Temperature measured in the room, in °C.
  final int currentTemperature;

  bool _connected = true;

  /// Default constructor.
  Thermostat(
    super.room, {
    int targetTemperature = defaultTemperature,
    this.currentTemperature = 20,
    super.isOn,
  }) : _targetTemperature = clampTemperature(targetTemperature);

  /// Named constructor that starts in energy-saving mode. It redirects to
  /// the default constructor with `this(...)`.
  Thermostat.eco(String room) : this(room, targetTemperature: ecoTemperature);

  int get targetTemperature => _targetTemperature;

  set targetTemperature(int value) {
    _targetTemperature = clampTemperature(value);
  }

  bool get canIncrease =>
      _connected && isOn && _targetTemperature < maxTemperature;

  bool get canDecrease =>
      _connected && isOn && _targetTemperature > minTemperature;

  void increaseTemperature() {
    if (canIncrease) targetTemperature = _targetTemperature + 1;
  }

  void decreaseTemperature() {
    if (canDecrease) targetTemperature = _targetTemperature - 1;
  }

  /// Sets an exact target; `this` separates the field from the parameter.
  void setTargetTemperature(int targetTemperature) {
    if (!_connected || !isOn) return;
    this.targetTemperature = targetTemperature;
  }

  @override
  String get typeLabel => 'Thermostat';

  @override
  String get primaryProperty => 'Temperature: $_targetTemperature°C';

  @override
  String getStatus() {
    if (!_connected) return 'Offline';
    if (!isOn) return 'Off';
    if (_targetTemperature > currentTemperature) return 'Heating';
    if (_targetTemperature < currentTemperature) return 'Cooling';
    return 'Idle';
  }

  @override
  bool get isActive => _connected && isOn;

  /// Turns the thermostat on or off.
  @override
  void performAction() {
    if (!_connected) return;
    isOn = !isOn;
  }

  @override
  Map<String, String> details() => {
        ...super.details(),
        'Target': '$_targetTemperature°C',
        'Room temperature': '$currentTemperature°C',
        'Range': '$minTemperature-$maxTemperature°C',
        'Connection': connectionInfo(),
        'Schedule': scheduleSummary,
      };

  // ----- Connectable -----

  @override
  String get protocol => 'Wi-Fi';

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
