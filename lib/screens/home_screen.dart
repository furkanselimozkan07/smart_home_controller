import 'dart:async';

import 'package:flutter/material.dart';

import '../data/device_factory.dart';
import '../models/schedulable.dart';
import '../models/smart_device.dart';
import '../widgets/add_device_dialog.dart';
import '../widgets/device_card.dart';
import '../widgets/device_details_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<SmartDevice> _devices;
  Timer? _scheduleTimer;

  @override
  void initState() {
    super.initState();
    _devices = createInitialDevices();
    // Checks the schedules of Schedulable devices twice a minute.
    _scheduleTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _runSchedules(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _runSchedules(DateTime now) {
    final changed = <SmartDevice>[];
    for (final device in _devices) {
      if (device is Schedulable && device.runScheduleIfDue(now)) {
        changed.add(device);
      }
    }
    if (changed.isEmpty || !mounted) return;
    setState(() {});
    final names = changed
        .map((d) => '${d.name} turned ${d.isOn ? 'on' : 'off'}')
        .join(', ');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Schedule: $names')));
  }

  Future<void> _addDevice() async {
    final request = await showAddDeviceDialog(context);
    if (request == null || !mounted) return;
    final device =
        createDevice(request.type, request.room, ecoMode: request.ecoMode);
    setState(() => _devices.add(device));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${device.name} added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _devices.where((d) => d.isActive).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Home Controller')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _devices.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SummaryRow(
              activeCount: activeCount,
              shownCount: _devices.length,
            );
          }
          final device = _devices[index - 1];
          return DeviceCard(
            device: device,
            onChanged: _refresh,
            onOpenDetails: () =>
                showDeviceDetails(context, device, onChanged: _refresh),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-device'),
        onPressed: _addDevice,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add device'),
      ),
      bottomNavigationBar: _TotalDevicesBar(
        // Comes straight from the static counter of SmartDevice.
        total: SmartDevice.totalDevices,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.activeCount, required this.shownCount});

  final int activeCount;
  final int shownCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Text(
            'My Devices',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            '$activeCount of $shownCount active',
            key: const ValueKey('active-summary'),
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _TotalDevicesBar extends StatelessWidget {
  const _TotalDevicesBar({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE3E7EF))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'Total Devices: $total',
            key: const ValueKey('total-devices'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
