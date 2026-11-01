import 'package:flutter/material.dart';

import '../models/connectable.dart';
import '../models/schedulable.dart';
import '../models/smart_device.dart';
import '../models/smart_light.dart';
import '../models/smart_speaker.dart';
import '../models/thermostat.dart';
import 'device_visuals.dart';

/// Opens the details sheet of [device]. [onChanged] is called after every
/// change so the list behind the sheet stays in sync.
Future<void> showDeviceDetails(
  BuildContext context,
  SmartDevice device, {
  required VoidCallback onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => DeviceDetailsSheet(device: device, onChanged: onChanged),
  );
}

class DeviceDetailsSheet extends StatefulWidget {
  const DeviceDetailsSheet({
    super.key,
    required this.device,
    required this.onChanged,
  });

  final SmartDevice device;
  final VoidCallback onChanged;

  @override
  State<DeviceDetailsSheet> createState() => _DeviceDetailsSheetState();
}

class _DeviceDetailsSheetState extends State<DeviceDetailsSheet> {
  bool _scheduleTurnOn = true;

  void _update(VoidCallback change) {
    setState(change);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          _Header(device: device),
          const SizedBox(height: 20),
          const _SectionTitle('Controls'),
          ..._buildControls(device),
          if (device is Connectable) ...[
            const SizedBox(height: 12),
            const _SectionTitle('Connection'),
            _buildConnection(device as Connectable),
          ],
          if (device is Schedulable) ...[
            const SizedBox(height: 12),
            const _SectionTitle('Schedule'),
            _buildSchedule(device),
          ],
          const SizedBox(height: 12),
          const _SectionTitle('Details'),
          _DetailsTable(entries: device.details()),
        ],
      ),
    );
  }

  List<Widget> _buildControls(SmartDevice device) {
    final offline = DeviceVisuals.isOffline(device);

    switch (device) {
      case SmartLight():
        return [
          SwitchListTile(
            key: const ValueKey('sheet-power'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Power'),
            value: device.isOn,
            onChanged: offline ? null : (_) => _update(device.performAction),
          ),
          _SliderRow(
            label: 'Brightness',
            valueLabel: '${device.brightness}%',
            child: Slider(
              key: const ValueKey('sheet-brightness'),
              value: device.brightness.toDouble(),
              min: SmartLight.minBrightness.toDouble(),
              max: SmartLight.maxBrightness.toDouble(),
              divisions: SmartLight.maxBrightness - SmartLight.minBrightness,
              label: '${device.brightness}%',
              onChanged: offline
                  ? null
                  : (value) =>
                      _update(() => device.setBrightness(value.round())),
            ),
          ),
        ];
      case Thermostat():
        return [
          SwitchListTile(
            key: const ValueKey('sheet-power'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Power'),
            value: device.isOn,
            onChanged: offline ? null : (_) => _update(device.performAction),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  tooltip: 'Decrease temperature',
                  onPressed: device.canDecrease
                      ? () => _update(device.decreaseTemperature)
                      : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text(
                        '${device.targetTemperature}°C',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Room: ${device.currentTemperature}°C',
                        style: const TextStyle(color: DeviceVisuals.mutedText),
                      ),
                    ],
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Increase temperature',
                  onPressed: device.canIncrease
                      ? () => _update(device.increaseTemperature)
                      : null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ];
      case SmartSpeaker():
        return [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.music_note_rounded),
            title: Text(device.currentTrack),
            subtitle: Text(device.isPlaying ? 'Now playing' : 'Paused'),
            trailing: IconButton.filled(
              key: const ValueKey('sheet-play'),
              tooltip: device.isPlaying ? 'Pause' : 'Play',
              onPressed: offline ? null : () => _update(device.performAction),
              icon: Icon(
                device.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
            ),
          ),
          _SliderRow(
            label: 'Volume',
            valueLabel: '${device.volume}%',
            child: Slider(
              key: const ValueKey('sheet-volume'),
              value: device.volume.toDouble(),
              max: SmartSpeaker.maxVolume.toDouble(),
              divisions: SmartSpeaker.maxVolume,
              label: '${device.volume}%',
              onChanged: offline
                  ? null
                  : (value) => _update(() => device.setVolume(value.round())),
            ),
          ),
        ];
      default:
        return [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Main action'),
            trailing: FilledButton(
              onPressed: offline ? null : () => _update(device.performAction),
              child: const Text('Run'),
            ),
          ),
        ];
    }
  }

  Widget _buildConnection(Connectable device) {
    return SwitchListTile(
      key: const ValueKey('sheet-connection'),
      contentPadding: EdgeInsets.zero,
      secondary: Icon(
        device.isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
        color: device.isConnected
            ? DeviceVisuals.activeGreen
            : DeviceVisuals.offlineRed,
      ),
      title: Text(device.isConnected ? 'Connected' : 'Disconnected'),
      subtitle: Text(device.connectionInfo()),
      value: device.isConnected,
      onChanged: (connected) =>
          _update(connected ? device.connect : device.disconnect),
    );
  }

  Widget _buildSchedule(Schedulable device) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule_rounded, color: DeviceVisuals.mutedText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                device.scheduleSummary,
                key: const ValueKey('sheet-schedule-summary'),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            if (device.hasSchedule)
              TextButton(
                onPressed: () => _update(device.clearSchedule),
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Turn on')),
                  ButtonSegment(value: false, label: Text('Turn off')),
                ],
                selected: {_scheduleTurnOn},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setState(() => _scheduleTurnOn = selection.first),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              key: const ValueKey('sheet-pick-time'),
              onPressed: () => _pickTime(device),
              icon: const Icon(Icons.alarm_add_rounded, size: 18),
              label: const Text('Pick time'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickTime(Schedulable device) async {
    final current = device.schedule;
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: current.hour, minute: current.minute),
      helpText: _scheduleTurnOn ? 'Turn on at' : 'Turn off at',
    );
    if (picked == null || !mounted) return;
    _update(
      () => device.setSchedule(
        picked.hour,
        picked.minute,
        turnOn: _scheduleTurnOn,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.device});

  final SmartDevice device;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DeviceAvatar(device: device, size: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                device.primaryProperty,
                style: const TextStyle(color: DeviceVisuals.mutedText),
              ),
              const SizedBox(height: 4),
              StatusLine(device: device),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.child,
  });

  final String label;
  final String valueLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Text(
              valueLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

class _DetailsTable extends StatelessWidget {
  const _DetailsTable({required this.entries});

  final Map<String, String> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final entry in entries.entries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: DeviceVisuals.mutedText),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
