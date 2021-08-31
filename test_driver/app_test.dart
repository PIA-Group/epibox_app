import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('EpiBOX - UI testing', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Successful login', () async {
      final timeline = await driver.traceAction(() async {
        final loginTextField = find.byValueKey('loginTextField');
        final loginCheckButton = find.byValueKey('loginCheckButton');
        await driver.tap(loginTextField);
        await driver.enterText('trial-performance');
        await driver.tap(loginCheckButton);
      });

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile('ui_login', pretty: true);
    });

    test('Server connection', () async {
      final timeline = await driver.traceAction(() async {
        await Future<void>.delayed(Duration(seconds: 1));
        final connectServerButton = find.byValueKey('connectServerButton');
        await driver.tap(connectServerButton);
        await Future<void>.delayed(Duration(seconds: 4));
      });

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile('server_connection', pretty: true);
    });

    test('Connect to default device', () async {
      final timeline = await driver.traceAction(() async {
        await driver.waitFor(find.byValueKey('bottomNavbar'));
        await driver.tap(
          find.ancestor(
            of: find.byValueKey('Dispositivos'),
            matching: find.byType('BottomNavigationBarItem'),
          ),
        );

        await driver.tap(find.byValueKey('connectDeviceButton'));
        await Future<void>.delayed(Duration(seconds: 3));

        expect(
          await driver.getText(find.byValueKey('connectionStateText')),
          equals('Dispositivo conectado!'),
        );
        await Future<void>.delayed(Duration(seconds: 3));
      });

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile('device_connection', pretty: true);
    });

    test('Choose default configurations', () async {
      final timeline = await driver.traceAction(() async {
        await driver.waitFor(find.byValueKey('bottomNavbar'));
        await driver.tap(find.text('Configurações'));

        await driver.scrollUntilVisible(find.byValueKey('configListView'),
            find.byValueKey('defineNewDefault'),
            dyScroll: -20.0);
      });

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile('set_configurations', pretty: true);
    });

    test('Visualization', () async {
      final timeline = await driver.traceAction(() async {
        await driver.waitFor(find.byValueKey('bottomNavbar'));
        await driver.tap(find.text('Aquisição'));

        await driver.tap(find.byValueKey('startStopButton'));
        await Future<void>.delayed(Duration(seconds: 5));

        await driver.scrollUntilVisible(
            find.byValueKey('visualizationListView'),
            find.text('Canal: A6 | -'),
            dyScroll: -20.0);
        await driver.scrollUntilVisible(
            find.byValueKey('visualizationListView'),
            find.text('Canal: A1 | -'),
            dyScroll: 20.0);

        await Future<void>.delayed(Duration(minutes: 1));
        await driver.tap(find.byValueKey('startStopButton'));
        await driver.waitFor(find.text('Aquisição terminada!'));
      });

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile('visualization', pretty: true);
    }, timeout: Timeout.none);
  });
}
