/// Interface for devices that talk to the home hub over a network.
///
/// Declared as an `interface class`, so device classes must `implement` it
/// and provide every member themselves; nothing is inherited from it.
abstract interface class Connectable {
  /// Network technology used by the device, e.g. `Wi-Fi` or `Zigbee`.
  String get protocol;

  /// Whether the device is currently reachable.
  bool get isConnected;

  /// Connects the device to the home hub.
  void connect();

  /// Disconnects the device from the home hub.
  void disconnect();

  /// One-line description of the connection, e.g. `Connected via Wi-Fi`.
  String connectionInfo();
}
