import 'package:flutter/material.dart';

import '../models/connectable.dart';
import '../models/smart_device.dart';
import '../models/smart_light.dart';
import '../models/smart_speaker.dart';
import '../models/thermostat.dart';

/// Shared colors and icons so the card and the details sheet look the same.
class DeviceVisuals {
  DeviceVisuals._();

  static const Color activeGreen = Color(0xFF2E9D57);
  static const Color inactiveGrey = Color(0xFF9AA1AC);
  static const Color offlineRed = Color(0xFFD64545);
  static const Color mutedText = Color(0xFF6B7280);

  static bool isOffline(SmartDevice device) =>
      device is Connectable && !(device as Connectable).isConnected;

  static IconData icon(SmartDevice device) => switch (device) {
        SmartLight() =>
          device.isOn ? Icons.lightbulb : Icons.lightbulb_outline_rounded,
        Thermostat() => Icons.thermostat_rounded,
        SmartSpeaker() => Icons.speaker_rounded,
        _ => Icons.devices_other_rounded,
      };

  /// Accent color of each device type.
  static Color accent(SmartDevice device) => switch (device) {
        SmartLight() => const Color(0xFFF2A900),
        Thermostat() => const Color(0xFFE5533D),
        SmartSpeaker() => const Color(0xFF2F62D4),
        _ => inactiveGrey,
      };

  /// Background of the round icon: tinted when active, grey otherwise.
  static Color iconBackground(SmartDevice device) => device.isActive
      ? accent(device).withValues(alpha: 0.14)
      : const Color(0xFFEDEFF3);

  static Color iconColor(SmartDevice device) =>
      device.isActive ? accent(device) : inactiveGrey;

  static Color statusColor(SmartDevice device) {
    if (isOffline(device)) return offlineRed;
    return device.isActive ? activeGreen : inactiveGrey;
  }
}

/// Round icon used at the start of a device card.
class DeviceAvatar extends StatelessWidget {
  const DeviceAvatar({super.key, required this.device, this.size = 46});

  final SmartDevice device;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: DeviceVisuals.iconBackground(device),
              shape: BoxShape.circle,
            ),
            child: Icon(
              DeviceVisuals.icon(device),
              color: DeviceVisuals.iconColor(device),
              size: size * 0.52,
            ),
          ),
          if (DeviceVisuals.isOffline(device))
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 14,
                  color: DeviceVisuals.offlineRed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Colored dot followed by `Status: ...`.
class StatusLine extends StatelessWidget {
  const StatusLine({super.key, required this.device});

  final SmartDevice device;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: DeviceVisuals.statusColor(device),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Status: ${device.getStatus()}',
          style: const TextStyle(fontSize: 12.5, color: DeviceVisuals.mutedText),
        ),
      ],
    );
  }
}
