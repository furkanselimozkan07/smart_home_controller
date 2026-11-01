import 'package:flutter/material.dart';

import '../models/schedulable.dart';
import '../models/smart_device.dart';
import '../models/smart_light.dart';
import '../models/smart_speaker.dart';
import '../models/thermostat.dart';
import 'device_visuals.dart';

/// One device in the list: icon, name, main property, status and the
/// device-specific control. Tapping the card opens the details sheet.
class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.onChanged,
    required this.onOpenDetails,
  });

  final SmartDevice device;

  /// Called after the device object has been changed so the screen rebuilds.
  final VoidCallback onChanged;
  final VoidCallback onOpenDetails;

  void _update(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final device = this.device;
    final schedule = device is Schedulable ? device.schedule : null;

    return Card(
      key: ValueKey('card-${device.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              DeviceAvatar(device: device),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      device.primaryProperty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: DeviceVisuals.mutedText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    StatusLine(device: device),
                    if (schedule != null) ...[
                      const SizedBox(height: 6),
                      _ScheduleChip(summary: schedule.summary),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildControl(context, device),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControl(BuildContext context, SmartDevice device) {
    final offline = DeviceVisuals.isOffline(device);

    return switch (device) {
      SmartLight() => Switch(
          key: ValueKey('switch-${device.id}'),
          value: device.isOn,
          onChanged: offline ? null : (_) => _update(device.performAction),
        ),
      Thermostat() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundOutlinedButton(
              key: ValueKey('decrease-${device.id}'),
              icon: Icons.remove_rounded,
              tooltip: 'Decrease temperature',
              onPressed: device.canDecrease
                  ? () => _update(device.decreaseTemperature)
                  : null,
            ),
            const SizedBox(width: 6),
            _RoundOutlinedButton(
              key: ValueKey('increase-${device.id}'),
              icon: Icons.add_rounded,
              tooltip: 'Increase temperature',
              onPressed: device.canIncrease
                  ? () => _update(device.increaseTemperature)
                  : null,
            ),
          ],
        ),
      SmartSpeaker() => IconButton.filled(
          key: ValueKey('play-${device.id}'),
          tooltip: device.isPlaying ? 'Pause' : 'Play',
          onPressed: offline ? null : () => _update(device.performAction),
          icon: Icon(
            device.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
      _ => IconButton(
          onPressed: offline ? null : () => _update(device.performAction),
          icon: const Icon(Icons.power_settings_new_rounded),
        ),
    };
  }
}

class _RoundOutlinedButton extends StatelessWidget {
  const _RoundOutlinedButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton.outlined(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 18,
        style: IconButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: onPressed == null ? const Color(0xFFD5D9E0) : color,
            width: 1.4,
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(summary, style: TextStyle(fontSize: 11.5, color: color)),
        ],
      ),
    );
  }
}
