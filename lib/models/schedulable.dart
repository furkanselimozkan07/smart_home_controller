import 'smart_device.dart';

/// A single timed power command, e.g. "turn on at 07:30".
class DeviceSchedule {
  final int hour;
  final int minute;
  final bool turnOn;

  const DeviceSchedule({
    required this.hour,
    required this.minute,
    required this.turnOn,
  });

  /// Time formatted as `HH:mm`.
  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String get summary => '${turnOn ? 'Turns on' : 'Turns off'} at $timeLabel';
}

/// Adds daily on/off scheduling to a device.
///
/// The mixin is restricted with `on SmartDevice`, so it can only be mixed
/// into device classes and can safely read and change [SmartDevice.isOn].
/// It is used by `SmartLight` and `Thermostat`, where switching power at a
/// fixed time of day makes sense.
mixin Schedulable on SmartDevice {
  DeviceSchedule? _schedule;
  DateTime? _lastRun;

  /// The current schedule, or `null` when none is set.
  DeviceSchedule? get schedule => _schedule;

  bool get hasSchedule => _schedule != null;

  /// Text shown in the UI, e.g. `Turns on at 07:30`.
  String get scheduleSummary => _schedule?.summary ?? 'No schedule';

  /// Sets a daily schedule. Throws [ArgumentError] for an invalid time.
  void setSchedule(int hour, int minute, {required bool turnOn}) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'must be between 0 and 59');
    }
    _schedule = DeviceSchedule(hour: hour, minute: minute, turnOn: turnOn);
    _lastRun = null;
  }

  void clearSchedule() {
    _schedule = null;
    _lastRun = null;
  }

  /// Applies the schedule when [now] matches its hour and minute.
  ///
  /// Returns `true` when the power state was changed. A schedule runs at
  /// most once per day, even if this method is called several times within
  /// the same minute.
  bool runScheduleIfDue(DateTime now) {
    final schedule = _schedule;
    if (schedule == null) return false;
    if (now.hour != schedule.hour || now.minute != schedule.minute) {
      return false;
    }
    final lastRun = _lastRun;
    if (lastRun != null &&
        lastRun.year == now.year &&
        lastRun.month == now.month &&
        lastRun.day == now.day) {
      return false;
    }
    _lastRun = now;
    if (isOn == schedule.turnOn) return false;
    isOn = schedule.turnOn;
    return true;
  }
}
