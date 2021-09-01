import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

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

    String fs = '1000';
    String drive = 'TOSHIBA';
    List<String> devices = [' ', '98:D3:91:FD:3F:5C'];

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
      await summary.writeTimelineToFile('login', pretty: true);
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

    test('Connect to chosen devices', () async {
      final timeline = await driver.traceAction(() async {
        await driver.waitFor(find.byValueKey('bottomNavbar'));
        await driver.tap(find.text('Dispositivos'));

        await driver.tap(find.byValueKey('device${1}TextField'));
        await driver.enterText(devices[0]);

        await driver.tap(find.byValueKey('device${2}TextField'));
        await driver.enterText(devices[1]);

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

    test('Choose configurations', () async {
      final timeline = await driver.traceAction(() async {
        await driver.waitFor(find.byValueKey('bottomNavbar'));
        await driver.tap(find.text('Configurações'));

        await driver.tap(find.byValueKey('driveDropdown'));
        await driver.tap(find.byValueKey(drive));

        await driver.tap(find.byValueKey('fsDropdown'));
        await driver.tap(find.text(fs));

        await driver.tap(finder)

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
