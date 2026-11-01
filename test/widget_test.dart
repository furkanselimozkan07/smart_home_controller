import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_controller/main.dart';
import 'package:smart_home_controller/models/smart_device.dart';

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const SmartHomeApp());
}

void main() {
  setUp(SmartDevice.resetCount);

  testWidgets('shows a card for every device type and the static total',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Smart Home Controller'), findsOneWidget);
    expect(find.text('Smart Light: Living Room'), findsOneWidget);
    expect(find.text('Thermostat: Bedroom'), findsOneWidget);
    expect(find.text('Smart Speaker: Kitchen'), findsOneWidget);
    expect(find.text('Total Devices: 6'), findsOneWidget);
  });

  testWidgets('light switch turns the light off', (tester) async {
    await pumpApp(tester);

    expect(find.text('Brightness: 75%'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('switch-device-01')));
    await tester.pumpAndSettle();

    expect(find.text('Brightness: 75%'), findsNothing);
    expect(find.text('Status: OFF'), findsNWidgets(2));
  });

  testWidgets('thermostat + and - change the target', (tester) async {
    await pumpApp(tester);

    expect(find.text('Temperature: 22°C'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('increase-device-03')));
    await tester.pump();
    expect(find.text('Temperature: 23°C'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('decrease-device-03')));
    await tester.tap(find.byKey(const ValueKey('decrease-device-03')));
    await tester.pump();
    expect(find.text('Temperature: 21°C'), findsOneWidget);
  });

  testWidgets('speaker play/pause button changes the status', (tester) async {
    await pumpApp(tester);

    // The office speaker (device-06) starts paused.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('play-device-06')),
      200,
    );
    expect(find.byTooltip('Play'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('play-device-06')));
    await tester.pump();
    expect(find.byTooltip('Play'), findsNothing);
    expect(find.text('Status: Playing'), findsNWidgets(2));
  });

  testWidgets('adding a device increases the static total', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('add-device')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('type-speaker')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('confirm-add')));
    await tester.pumpAndSettle();

    expect(find.text('Total Devices: 7'), findsOneWidget);
    expect(find.text('Smart Speaker: Living Room added'), findsOneWidget);
  });

  testWidgets('details sheet shows connection and can take a device offline',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Smart Light: Living Room'));
    await tester.pumpAndSettle();
    expect(find.text('Connected via Zigbee'), findsWidgets);
    expect(find.text('No schedule'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('sheet-connection')));
    await tester.pumpAndSettle();
    expect(find.text('Disconnected (Zigbee)'), findsWidgets);
    expect(find.text('Status: Offline'), findsWidgets);
  });
}
