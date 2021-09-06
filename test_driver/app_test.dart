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

    String fs = '1000';
    String drive = 'TOSHIBA';
    List<String> devices = ['98:D3:91:FD:3F:5C', ''];
    int nChannels = 6;

    bool connectionFailed = false;

    test('App start and configuration', () async {
      final timeline = await driver.traceAction(() async {
        final loginTextField = find.byValueKey('loginTextField');
        final loginCheckButton = find.byValueKey('loginCheckButton');
        await driver.tap(loginTextField);
        await driver.enterText('trial-performance');
        await driver.tap(loginCheckButton);
      });

      await Future<void>.delayed(Duration(seconds: 1));
      final connectServerButton = find.byValueKey('connectServerButton');
      await driver.tap(connectServerButton);
      await Future<void>.delayed(Duration(seconds: 1));

      // Connect to the devices

      await driver.waitFor(find.byValueKey('bottomNavbar'));
      await driver.tap(find.text('Dispositivos'));

      await driver.tap(find.byValueKey('device1TextField'));
      await driver.enterText(devices[0]);

      await driver.tap(find.byValueKey('device2TextField'));
      await driver.enterText(devices[1]);

      if (devices[0] != '') {
        await driver.tap(find.byValueKey('connectDeviceButton1'));
      }
      if (devices[1] != '') {
        await driver.tap(find.byValueKey('connectDeviceButton2'));
      }

      await Future<void>.delayed(Duration(seconds: 5));

      if (devices[0] != '') {
        String state =
            await driver.getText(find.byValueKey('connectionStateText1'));

        if (state != 'Dispositivo conectado') connectionFailed = true;
      }

      if (devices[1] != '') {
        /* await driver
            .waitFor(find.text('Dispositivo conectado'),
                timeout: Duration(seconds: 6))
            .catchError((e) {
          print(e);
        }); */
        await expectLater(find.byValueKey('connectionStateText2'),
                'Dispositivo conectado')
            .catchError((e) => print(e));

        String state =
            await driver.getText(find.byValueKey('connectionStateText2'));
        if (state != 'Dispositivo conectado') connectionFailed = true;
      }
      // Set configurations

      await driver.waitFor(find.byValueKey('bottomNavbar'));
      await driver.tap(find.text('Configurações'));

      await driver.tap(find.byValueKey('driveDropdown'));
      await driver.tap(find.byValueKey(drive));

      await driver.tap(find.byValueKey('fsDropdown'));
      await driver.tap(find.text(fs));

      await driver.scrollUntilVisible(find.byValueKey('configListView'),
          find.byValueKey('defineNewDefault'),
          dyScroll: -20.0);

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      if (connectionFailed)
        await summary.writeTimelineToFile('configure_${fs}_${nChannels}_failed',
            pretty: true);
      else
        await summary.writeTimelineToFile('configure_${fs}_$nChannels',
            pretty: true);
    });

    test('Visualization', () async {
      final timeline = await driver.traceAction(() async {
        await driver.waitFor(find.byValueKey('bottomNavbar'));
        await driver.tap(find.text('Aquisição'));

        await driver.tap(find.byValueKey('startStopButton'));

        /* await expectLater(
          () => driver.waitForAbsent(find.text('Canal: A1 | -'),
              timeout: const Duration(seconds: 5)),
          throwsA(isA<DriverError>().having(
            (DriverError error) => error.message,
            'message',
            contains('Timeout while executing waitForAbsent'),
          )),
        ); */

        await driver
            .waitFor(find.text('Canal: A1 | -'), timeout: Duration(seconds: 6))
            .catchError((e) {
          print(e);
        });

        await driver.scrollUntilVisible(
            find.byValueKey('visualizationListView'),
            find.text('Canal: A$nChannels | -'),
            dyScroll: -20.0);
        await driver.scrollUntilVisible(
            find.byValueKey('visualizationListView'),
            find.text('Canal: A1 | -'),
            dyScroll: 20.0);

        if (devices[1] != '') {
          await driver.tap(find.byValueKey(devices[1]));

          await driver.scrollUntilVisible(
              find.byValueKey('visualizationListView'),
              find.text('Canal: A$nChannels | -'),
              dyScroll: -20.0);
          await driver.scrollUntilVisible(
              find.byValueKey('visualizationListView'),
              find.text('Canal: A1 | -'),
              dyScroll: 20.0);
          await driver.tap(find.byValueKey(devices[0]));
        }

        await Future<void>.delayed(Duration(minutes: 3));
        await driver.tap(find.byValueKey('startStopButton'));
        await driver.waitFor(find.text('Aquisição terminada!'));
      });

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      if (connectionFailed)
        await summary.writeTimelineToFile(
            'visualization_${fs}_${nChannels}_failed',
            pretty: true);
      else
        await summary.writeTimelineToFile('visualization_${fs}_$nChannels',
            pretty: true);
    }, timeout: Timeout(Duration(minutes: 6)));
  });
}
