import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_controller/data/device_factory.dart';
import 'package:smart_home_controller/models/connectable.dart';
import 'package:smart_home_controller/models/schedulable.dart';
import 'package:smart_home_controller/models/smart_device.dart';
import 'package:smart_home_controller/models/smart_light.dart';
import 'package:smart_home_controller/models/smart_speaker.dart';
import 'package:smart_home_controller/models/thermostat.dart';

void main() {
  setUp(SmartDevice.resetCount);

  group('static counter', () {
    test('every constructor increments totalDevices exactly once', () {
      expect(SmartDevice.totalDevices, 0);
      SmartLight('Living Room');
      SmartLight.off('Kitchen');
      Thermostat('Bedroom');
      Thermostat.eco('Office');
      SmartSpeaker('Kitchen');
      SmartSpeaker.quiet('Office');
      expect(SmartDevice.totalDevices, 6);
    });

    test('ids are unique and come from the counter', () {
      final a = SmartLight('A');
      final b = Thermostat('B');
      expect(a.id, 'device-01');
      expect(b.id, 'device-02');
    });

    test('initial device list has at least one of each subclass', () {
      final devices = createInitialDevices();
      expect(devices.whereType<SmartLight>(), isNotEmpty);
      expect(devices.whereType<Thermostat>(), isNotEmpty);
      expect(devices.whereType<SmartSpeaker>(), isNotEmpty);
      expect(SmartDevice.totalDevices, devices.length);
    });
  });

  group('class hierarchy', () {
    test('subclasses extend SmartDevice and implement Connectable', () {
      final devices = <SmartDevice>[
        SmartLight('A'),
        Thermostat('B'),
        SmartSpeaker('C'),
      ];
      for (final device in devices) {
        expect(device, isA<SmartDevice>());
        expect(device, isA<Connectable>());
      }
    });

    test('Schedulable is mixed into lights and thermostats only', () {
      expect(SmartLight('A'), isA<Schedulable>());
      expect(Thermostat('B'), isA<Schedulable>());
      expect(SmartSpeaker('C'), isNot(isA<Schedulable>()));
    });

    test('name is built from type label and room', () {
      expect(SmartLight('Living Room').name, 'Smart Light: Living Room');
      expect(Thermostat('Bedroom').name, 'Thermostat: Bedroom');
      expect(SmartSpeaker('Office').name, 'Smart Speaker: Office');
    });

    test('details() extends the base map through super.details()', () {
      final details = SmartLight('Hall').details();
      expect(details['Room'], 'Hall');
      expect(details['Type'], 'Smart Light');
      expect(details['Brightness'], '75%');
      expect(details['Connection'], 'Connected via Zigbee');
    });
  });

  group('SmartLight', () {
    test('default and named constructors', () {
      final on = SmartLight('A');
      expect(on.isOn, isTrue);
      expect(on.primaryProperty, 'Brightness: 75%');
      expect(on.getStatus(), 'ON');

      final off = SmartLight.off('B');
      expect(off.isOn, isFalse);
      expect(off.primaryProperty, 'Brightness: 0%');
      expect(off.getStatus(), 'OFF');
    });

    test('performAction toggles power and keeps brightness', () {
      final light = SmartLight('A', brightness: 50)..performAction();
      expect(light.isOn, isFalse);
      light.performAction();
      expect(light.isOn, isTrue);
      expect(light.brightness, 50);
    });

    test('brightness is clamped', () {
      final light = SmartLight('A', brightness: 500);
      expect(light.brightness, SmartLight.maxBrightness);
      light.setBrightness(-4);
      expect(light.brightness, SmartLight.minBrightness);
    });
  });

  group('Thermostat', () {
    test('status follows target vs room temperature', () {
      final heating = Thermostat('A');
      expect(heating.getStatus(), 'Heating');
      expect(Thermostat.eco('B').getStatus(), 'Cooling');
      expect(Thermostat('C', targetTemperature: 20).getStatus(), 'Idle');
    });

    test('increase and decrease stay in range', () {
      final t = Thermostat('A', targetTemperature: Thermostat.maxTemperature);
      expect(t.canIncrease, isFalse);
      t.increaseTemperature();
      expect(t.targetTemperature, Thermostat.maxTemperature);
      t.decreaseTemperature();
      expect(t.targetTemperature, Thermostat.maxTemperature - 1);
      expect(Thermostat.clampTemperature(5), Thermostat.minTemperature);
    });

    test('performAction powers off and blocks adjustments', () {
      final t = Thermostat('A')..performAction();
      expect(t.getStatus(), 'Off');
      t.increaseTemperature();
      expect(t.targetTemperature, Thermostat.defaultTemperature);
    });
  });

  group('SmartSpeaker', () {
    test('default and named constructors', () {
      expect(SmartSpeaker('A').volume, SmartSpeaker.defaultVolume);
      expect(SmartSpeaker.quiet('B').volume, SmartSpeaker.quietVolume);
    });

    test('performAction plays and pauses', () {
      final speaker = SmartSpeaker('A');
      expect(speaker.getStatus(), 'Paused');
      speaker.performAction();
      expect(speaker.getStatus(), 'Playing');
      expect(speaker.isActive, isTrue);
    });
  });

  group('Connectable', () {
    test('offline devices ignore their main action', () {
      final light = SmartLight('A')..disconnect();
      expect(light.getStatus(), 'Offline');
      light.performAction();
      expect(light.isOn, isTrue);
      light.connect();
      expect(light.connectionInfo(), 'Connected via Zigbee');
    });

    test('disconnecting a speaker stops playback', () {
      final speaker = SmartSpeaker('A', isPlaying: true)..disconnect();
      expect(speaker.isPlaying, isFalse);
      expect(speaker.connectionInfo(), 'Disconnected (Bluetooth)');
    });
  });

  group('Schedulable', () {
    test('schedule runs once at the chosen time', () {
      final light = SmartLight.off('A')..setSchedule(7, 30, turnOn: true);
      expect(light.scheduleSummary, 'Turns on at 07:30');

      expect(light.runScheduleIfDue(DateTime(2026, 11, 1, 7, 29)), isFalse);
      expect(light.isOn, isFalse);

      expect(light.runScheduleIfDue(DateTime(2026, 11, 1, 7, 30)), isTrue);
      expect(light.isOn, isTrue);

      light.isOn = false;
      expect(light.runScheduleIfDue(DateTime(2026, 11, 1, 7, 30, 40)), isFalse);
      expect(light.runScheduleIfDue(DateTime(2026, 11, 2, 7, 30)), isTrue);
    });

    test('invalid times are rejected and schedules can be cleared', () {
      final t = Thermostat('A');
      expect(() => t.setSchedule(24, 0, turnOn: false), throwsArgumentError);
      t.setSchedule(22, 0, turnOn: false);
      expect(t.hasSchedule, isTrue);
      t.clearSchedule();
      expect(t.scheduleSummary, 'No schedule');
    });
  });
}
