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
    String drive = 'UUI';
    List<String> devices = ['98:D3:91:FD:3F:5C', ''];
    int nChannels = 6;

    bool serverFailed = false;
    bool devicesFailed = false;
    bool plotFailed = false;

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

      await driver
          .waitFor(find.text('Conectado ao servidor!'),
              timeout: Duration(seconds: 8))
          .catchError((e) {
        serverFailed = true;
        print(e);
      });

      await Future<void>.delayed(Duration(seconds: 3));

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

      await Future<void>.delayed(Duration(seconds: 6));

      if (devices[0] != '') {
        String state =
            await driver.getText(find.byValueKey('connectionStateText1'));
        print('device 1 state: $state');

        if (state != 'Dispositivo conectado!') devicesFailed = true;
      }

      if (devices[1] != '') {
        String state =
            await driver.getText(find.byValueKey('connectionStateText2'));
        print('device 2 state: $state');

        if (state != 'Dispositivo conectado!') devicesFailed = true;
      }
      // Set configurations

      await driver.waitFor(find.byValueKey('bottomNavbar'));
      await driver.tap(find.text('Configurações'));

      if (!serverFailed) {
        await driver.tap(find.byValueKey('driveDropdown'));
        await driver.tap(find.byValueKey(drive)).catchError((e) {
          print(e);
        });

        await driver.tap(find.byValueKey('fsDropdown'));
        await driver.tap(find.text(fs)).catchError((e) {
          print(e);
        });

        await driver.scrollUntilVisible(find.byValueKey('configListView'),
            find.byValueKey('defineNewDefault'),
            dyScroll: -20.0);
      }

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      if (serverFailed)
        await summary.writeTimelineToFile(
            'configure_${fs}_${nChannels}_serverFailed',
            pretty: true);
      else if (devicesFailed)
        await summary.writeTimelineToFile(
            'configure_${fs}_${nChannels}_devicesFailed',
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

        if (!serverFailed && !devicesFailed) {
          await driver
              .waitFor(find.text('Canal: A1 | -'),
                  timeout: Duration(seconds: 6))
              .catchError((e) {
            plotFailed = true;
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

          await Future<void>.delayed(Duration(minutes: 5));
          await driver.tap(find.byValueKey('startStopButton'));
          await driver.waitFor(find.text('Aquisição terminada!'));
        }
      });

      // write summary to a file
      final summary = new TimelineSummary.summarize(timeline);
      if (serverFailed)
        await summary.writeTimelineToFile(
            'visualization_${fs}_${nChannels}_serverFailed',
            pretty: true);
      else if (devicesFailed)
        await summary.writeTimelineToFile(
            'visualization_${fs}_${nChannels}_devicesFailed',
            pretty: true);
      else if (plotFailed)
        await summary.writeTimelineToFile(
            'visualization_${fs}_${nChannels}_plotFailed',
            pretty: true);
      else
        await summary.writeTimelineToFile('visualization_${fs}_$nChannels',
            pretty: true);
    }, timeout: Timeout(Duration(minutes: 8)));
  });
}
