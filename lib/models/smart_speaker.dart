import 'connectable.dart';
import 'smart_device.dart';

/// A network speaker that plays music.
///
/// `extends` [SmartDevice] and `implements` [Connectable]. It does not use
/// the `Schedulable` mixin, because a fixed on/off time is not a natural fit
/// for a speaker.
class SmartSpeaker extends SmartDevice implements Connectable {
  static const int maxVolume = 100;
  static const int defaultVolume = 40;
  static const int quietVolume = 25;

  int _volume;
  bool isPlaying;
  final String currentTrack;
  bool _connected = true;

  /// Default constructor.
  SmartSpeaker(
    super.room, {
    int volume = defaultVolume,
    this.isPlaying = false,
    this.currentTrack = 'Morning Playlist',
  }) : _volume = volume.clamp(0, maxVolume);

  /// Named constructor for background music at a low volume. It redirects
  /// to the default constructor with `this(...)`.
  SmartSpeaker.quiet(String room)
      : this(room, volume: quietVolume, currentTrack: 'Lo-fi Focus');

  int get volume => _volume;

  set volume(int value) {
    _volume = value.clamp(0, maxVolume);
  }

  /// Changes the volume; `this` separates the field from the parameter.
  void setVolume(int volume) {
    if (!_connected) return;
    this.volume = volume;
  }

  @override
  String get typeLabel => 'Smart Speaker';

  @override
  String get primaryProperty => 'Volume: $_volume%';

  @override
  String getStatus() {
    if (!_connected) return 'Offline';
    return isPlaying ? 'Playing' : 'Paused';
  }

  @override
  bool get isActive => _connected && isPlaying;

  /// Plays or pauses the current track.
  @override
  void performAction() {
    if (!_connected) return;
    isPlaying = !isPlaying;
  }

  @override
  Map<String, String> details() => {
        ...super.details(),
        'Volume': '$_volume%',
        'Track': currentTrack,
        'Connection': connectionInfo(),
      };

  // ----- Connectable -----

  @override
  String get protocol => 'Bluetooth';

  @override
  bool get isConnected => _connected;

  @override
  void connect() => _connected = true;

  /// Losing the connection also stops playback.
  @override
  void disconnect() {
    _connected = false;
    isPlaying = false;
  }

  @override
  String connectionInfo() =>
      _connected ? 'Connected via $protocol' : 'Disconnected ($protocol)';
}
