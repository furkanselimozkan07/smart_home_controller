import '../models/smart_device.dart';
import '../models/smart_light.dart';
import '../models/smart_speaker.dart';
import '../models/thermostat.dart';

/// The three device types the user can add from the UI.
enum DeviceType {
  light('Smart Light'),
  thermostat('Thermostat'),
  speaker('Smart Speaker');

  const DeviceType(this.label);

  final String label;
}

/// Rooms offered in the "Add device" dialog.
const List<String> availableRooms = [
  'Living Room',
  'Kitchen',
  'Bedroom',
  'Office',
  'Bathroom',
  'Garage',
];

/// Creates the devices shown when the app starts.
///
/// Every subclass is created at least once with its default constructor and
/// once with its named constructor.
List<SmartDevice> createInitialDevices() => [
      SmartLight('Living Room'), // default constructor
      SmartLight.off('Kitchen'), // named constructor
      Thermostat('Bedroom'), // default constructor
      Thermostat.eco('Living Room'), // named constructor
      SmartSpeaker('Kitchen', isPlaying: true), // default constructor
      SmartSpeaker.quiet('Office'), // named constructor
    ];

/// Creates a new device from the "Add device" dialog.
///
/// [ecoMode] selects the named constructor of the chosen type (light: off,
/// thermostat: eco, speaker: quiet); otherwise the default one is used.
SmartDevice createDevice(DeviceType type, String room, {bool ecoMode = false}) {
  switch (type) {
    case DeviceType.light:
      return ecoMode ? SmartLight.off(room) : SmartLight(room);
    case DeviceType.thermostat:
      return ecoMode ? Thermostat.eco(room) : Thermostat(room);
    case DeviceType.speaker:
      return ecoMode ? SmartSpeaker.quiet(room) : SmartSpeaker(room);
  }
}
