/// Base type of every device in the app.
///
/// [SmartDevice] is abstract: it holds the data that all devices share
/// (id, room, power state) and declares the behaviour every concrete device
/// must provide ([typeLabel], [primaryProperty], [getStatus] and
/// [performAction]).
///
/// The class also keeps a `static` counter that is shared by all instances.
/// Every constructor path ends in the default generative constructor, which
/// increments the counter exactly once, so [totalDevices] always equals the
/// number of device objects created while the app is running.
abstract class SmartDevice {
  /// Shared by the class, not by a single object.
  static int _createdCount = 0;

  /// Total number of [SmartDevice] objects created so far.
  static int get totalDevices => _createdCount;

  /// Resets the shared counter. Only used by the unit and widget tests so
  /// every test starts from zero.
  static void resetCount() => _createdCount = 0;

  static String _nextId() {
    _createdCount++;
    return 'device-${_createdCount.toString().padLeft(2, '0')}';
  }

  /// Unique id given at creation time, for example `device-03`.
  final String id;

  /// Room in which the device is installed, for example `Living Room`.
  final String room;

  /// Whether the device is powered on.
  bool isOn;

  /// Default constructor. `this.room` and `this.isOn` are initializing
  /// formal parameters; the id comes from the static counter.
  SmartDevice(this.room, {this.isOn = true}) : id = _nextId();

  /// Named constructor that creates a device which starts switched off.
  /// It redirects to the default constructor with `this(...)`.
  SmartDevice.off(String room) : this(room, isOn: false);

  /// Human readable device type, e.g. `Smart Light`.
  String get typeLabel;

  /// Name shown on the card, e.g. `Smart Light: Living Room`.
  String get name => '$typeLabel: $room';

  /// The most relevant property of the device, e.g. `Brightness: 75%`.
  String get primaryProperty;

  /// Short status text, e.g. `ON`, `Heating` or `Playing`.
  String getStatus();

  /// Whether the current status should be highlighted as active in the UI.
  bool get isActive;

  /// The main action of the device (toggle, play/pause, power).
  void performAction();

  /// Key/value information shown in the device details sheet. Subclasses
  /// extend this map by calling `super.details()`.
  Map<String, String> details() => {
        'Device ID': id,
        'Type': typeLabel,
        'Room': room,
        'Power': isOn ? 'On' : 'Off',
      };

  @override
  String toString() => '$name [$id] -> ${getStatus()}';
}
