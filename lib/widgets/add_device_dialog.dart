import 'package:flutter/material.dart';

import '../data/device_factory.dart';

/// What the user picked in the "Add device" dialog.
typedef NewDeviceRequest = ({DeviceType type, String room, bool ecoMode});

/// Shows the dialog and returns the user's choice, or `null` if cancelled.
/// The device object itself is created by the caller.
Future<NewDeviceRequest?> showAddDeviceDialog(BuildContext context) {
  return showDialog<NewDeviceRequest>(
    context: context,
    builder: (_) => const _AddDeviceDialog(),
  );
}

class _AddDeviceDialog extends StatefulWidget {
  const _AddDeviceDialog();

  @override
  State<_AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<_AddDeviceDialog> {
  DeviceType _type = DeviceType.light;
  String _room = availableRooms.first;
  bool _ecoMode = false;

  String get _modeTitle => switch (_type) {
        DeviceType.light => 'Start switched off',
        DeviceType.thermostat => 'Eco mode',
        DeviceType.speaker => 'Quiet mode',
      };

  String get _modeSubtitle => switch (_type) {
        DeviceType.light => 'The light is added in the OFF state',
        DeviceType.thermostat => 'Starts with an energy-saving 19°C target',
        DeviceType.speaker => 'Starts with background volume (25%)',
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add device'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Device type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in DeviceType.values)
                  ChoiceChip(
                    key: ValueKey('type-${type.name}'),
                    label: Text(type.label),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              key: const ValueKey('room-dropdown'),
              initialValue: _room,
              decoration: const InputDecoration(
                labelText: 'Room',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final room in availableRooms)
                  DropdownMenuItem(value: room, child: Text(room)),
              ],
              onChanged: (room) {
                if (room != null) setState(() => _room = room);
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_modeTitle),
              subtitle: Text(_modeSubtitle),
              value: _ecoMode,
              onChanged: (value) => setState(() => _ecoMode = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('confirm-add'),
          onPressed: () => Navigator.of(context).pop(
            (type: _type, room: _room, ecoMode: _ecoMode),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
