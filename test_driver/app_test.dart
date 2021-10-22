import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:t_stats/t_stats.dart';
import 'parse_timeline.dart';

Future<void> main(List<String> args) async {
  FlutterDriver driver;

  try {
    driver = await FlutterDriver.connect();
    var timeline = await _run(driver);
    await _save(timeline, 'conf');

    var timeline2 = await _runVisualization(driver);
    await _save(timeline2, 'vis');
  } finally {
    if (driver != null) {
      await driver.close();
    }
  }
}

Future<Timeline> _run(FlutterDriver driver) async {
  String fs = '1000';
  String drive = 'UUI';
  List<String> devices = ['98:D3:91:FD:3F:5C', ''];
  bool serverFailed = false;

  var health = await driver.checkHealth();
  if (health.status != HealthStatus.ok) {
    throw StateError('FlutterDriver health: $health');
  }

  // // Give the UI time to settle down before starting the trace.
  await Future<void>.delayed(const Duration(seconds: 1));

  await driver.startTracing();

  final loginTextField = find.byValueKey('loginTextField');
  final loginCheckButton = find.byValueKey('loginCheckButton');
  await driver.tap(loginTextField);
  await driver.enterText('trial-performance');
  await driver.tap(loginCheckButton);

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

    //if (state != 'Dispositivo conectado!') devicesFailed = true;
  }

  if (devices[1] != '') {
    String state =
        await driver.getText(find.byValueKey('connectionStateText2'));

    //if (state != 'Dispositivo conectado!') devicesFailed = true;
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

    await driver.scrollUntilVisible(
        find.byValueKey('configListView'), find.byValueKey('defineNewDefault'),
        dyScroll: -20.0);
  }

  return driver.stopTracingAndDownloadTimeline();
}

Future<Timeline> _runVisualization(FlutterDriver driver) async {
  String fs = '1000';
  String drive = 'UUI';
  List<String> devices = ['98:D3:91:FD:3F:5C', ''];
  int nChannels = 6;
  bool serverFailed = false;
  bool devicesFailed = false;
  bool plotFailed = false;

  var health = await driver.checkHealth();
  if (health.status != HealthStatus.ok) {
    throw StateError('FlutterDriver health: $health');
  }

  // // Give the UI time to settle down before starting the trace.
  await Future<void>.delayed(const Duration(seconds: 1));

  await driver.startTracing();

  // final loginTextField = find.byValueKey('loginTextField');
  // final loginCheckButton = find.byValueKey('loginCheckButton');
  // await driver.tap(loginTextField);
  // await driver.enterText('trial-performance');
  // await driver.tap(loginCheckButton);

  // await Future<void>.delayed(Duration(seconds: 1));
  // final connectServerButton = find.byValueKey('connectServerButton');
  // await driver.tap(connectServerButton);

  // await driver
  //     .waitFor(find.text('Conectado ao servidor!'),
  //         timeout: Duration(seconds: 8))
  //     .catchError((e) {
  //   serverFailed = true;
  //   print(e);
  // });

  // await Future<void>.delayed(Duration(seconds: 3));

  // // Connect to the devices

  // await driver.waitFor(find.byValueKey('bottomNavbar'));
  // await driver.tap(find.text('Dispositivos'));

  // await driver.tap(find.byValueKey('device1TextField'));
  // await driver.enterText(devices[0]);

  // await driver.tap(find.byValueKey('device2TextField'));
  // await driver.enterText(devices[1]);

  // if (devices[0] != '') {
  //   await driver.tap(find.byValueKey('connectDeviceButton1'));
  // }
  // if (devices[1] != '') {
  //   await driver.tap(find.byValueKey('connectDeviceButton2'));
  // }

  // await Future<void>.delayed(Duration(seconds: 6));

  // if (devices[0] != '') {
  //   String state =
  //       await driver.getText(find.byValueKey('connectionStateText1'));

  //   if (state != 'Dispositivo conectado!') devicesFailed = true;
  // }

  // if (devices[1] != '') {
  //   String state =
  //       await driver.getText(find.byValueKey('connectionStateText2'));

  //   if (state != 'Dispositivo conectado!') devicesFailed = true;
  // }
  // // Set configurations

  // await driver.waitFor(find.byValueKey('bottomNavbar'));
  // await driver.tap(find.text('Configurações'));

  // if (!serverFailed) {
  //   await driver.tap(find.byValueKey('driveDropdown'));
  //   await driver.tap(find.byValueKey(drive)).catchError((e) {
  //     print(e);
  //   });

  //   await driver.tap(find.byValueKey('fsDropdown'));
  //   await driver.tap(find.text(fs)).catchError((e) {
  //     print(e);
  //   });

  //   await driver.scrollUntilVisible(
  //       find.byValueKey('configListView'), find.byValueKey('defineNewDefault'),
  //       dyScroll: -20.0);
  // }

  await driver.waitFor(find.byValueKey('bottomNavbar'));
  await driver.tap(find.text('Aquisição'));

  await driver.tap(find.byValueKey('startStopButton'));

  if (!serverFailed && !devicesFailed) {
    await driver
        .waitFor(find.text('Canal: A1 | -'), timeout: Duration(seconds: 6))
        .catchError((e) {
      plotFailed = true;
      print(e);
    });

    await driver.scrollUntilVisible(find.byValueKey('visualizationListView'),
        find.text('Canal: A$nChannels | -'),
        dyScroll: -20.0);
    await driver.scrollUntilVisible(
        find.byValueKey('visualizationListView'), find.text('Canal: A1 | -'),
        dyScroll: 20.0);

    if (devices[1] != '') {
      await driver.tap(find.byValueKey(devices[1]));

      await driver.scrollUntilVisible(find.byValueKey('visualizationListView'),
          find.text('Canal: A$nChannels | -'),
          dyScroll: -20.0);
      await driver.scrollUntilVisible(
          find.byValueKey('visualizationListView'), find.text('Canal: A1 | -'),
          dyScroll: 20.0);
      await driver.tap(find.byValueKey(devices[0]));
    }

    await Future<void>.delayed(Duration(minutes: 1)); ///////////////
    await driver.tap(find.byValueKey('startStopButton'));
    await driver.waitFor(find.text('Aquisição terminada!'));
    await driver.waitFor(find.text('Aquisição iniciada!'));
  }

  return driver.stopTracingAndDownloadTimeline();
}

Future<void> _save(Timeline timeline, String key) async {
  var description = Platform.environment['DESC'];

  if (description == null) {
    stderr.writeln('[WARNING] No description of the run through provided. '
        'You can do so via the \$DESC shell variable. '
        'For example, run the command like this: \n\n'
        '\$> DESC="run with foo" '
        'flutter drive --target=test_driver/performance.dart --profile\n');
    description = '';
  }

  // var gitSha = '';
  // if (await GitDir.isGitDir('.')) {
  //   var gitDir = await GitDir.fromExisting('.');
  //   var branch = await gitDir.getCurrentBranch();
  //   gitSha = branch.sha.substring(0, 8);
  // }

  var now = DateTime.now();
  var id = 'performance_test-${now.toIso8601String()}_$key';
  var filename = id.replaceAll(':', '-');

  var summary = TimelineSummary.summarize(timeline);

  await summary.writeSummaryToFile(filename, pretty: true);
  await summary.writeTimelineToFile(filename);

  var rasterizerTimes =
      summary.summaryJson['frame_rasterizer_times'] as List<int>;
  var buildTimes = summary.summaryJson['frame_build_times'] as List<int>;
  var buildTimesStat = Statistic.from(
    buildTimes,
    name: id,
  );
  var additional = parse(timeline, summary);
  var frameRequestStats = Statistic.from(
      additional.frameRequestDurations.map((d) => d.inMicroseconds));

  // IOSink stats;
  // try {
  //   stats = File('test_driver/perf_stats.tsv').openWrite(mode: FileMode.append);
  //   // Add general build time statistics.
  //   stats.write(buildTimesStat.toTSV());
  //   // Add description.
  //   stats.write('\t');
  //   stats.write(description);
  //   // Add additional useful stats from the TimelineSummary.
  //   stats.write('\t');
  //   stats.write(summary.computePercentileFrameBuildTimeMillis(90));
  //   stats.write('\t');
  //   stats.write(summary.computePercentileFrameBuildTimeMillis(99));
  //   stats.write('\t');
  //   stats.write(summary.computeWorstFrameBuildTimeMillis());
  //   stats.write('\t');
  //   stats.write(summary.computeMissedFrameBuildBudgetCount());
  //   stats.write('\t');
  //   // Add things from parse_timeline.dart.
  //   stats.write(additional.length.inMicroseconds);
  //   stats.write('\t');
  //   stats.write(additional.frames);
  //   stats.write('\t');
  //   stats.write(additional.fps);
  //   stats.write('\t');
  //   stats.write(frameRequestStats.mean);
  //   stats.write('\t');
  //   stats.write(additional.dartPercentage);
  //   stats.write('\t');
  //   stats.write(additional.dartPhaseEvents);
  //   stats.write('\t');
  //   stats.write(additional.dartPhaseDuration.inMicroseconds);
  //   stats.write('\t');
  //   stats.write(additional.expiredTasksEvents);
  //   stats.write('\t');
  //   stats.write(additional.expiredTasksDuration.inMicroseconds);
  //   // Add timestamp.
  //   stats.write('\t');
  //   stats.write(now.toIso8601String());
  //   // End line.
  //   stats.writeln();
  // } finally {
  //   await stats?.close();
  // }

  // IOSink durations;
  // try {
  //   durations =
  //       File('test_driver/durations.tsv').openWrite(mode: FileMode.append);
  //   var length = [
  //     buildTimes.length,
  //     rasterizerTimes.length,
  //     additional.frameRequestDurations.length
  //   ].fold(0, max);
  //   for (int i = 0; i < length; i++) {
  //     var build = i < buildTimes.length ? buildTimes[i].toString() : '';
  //     var rasterizer =
  //         i < rasterizerTimes.length ? rasterizerTimes[i].toString() : '';
  //     var frameRequest = i < additional.frameRequestDurations.length
  //         ? additional.frameRequestDurations[i].inMicroseconds.toString()
  //         : '';
  //     var row = <String>[
  //       id,
  //       build,
  //       rasterizer,
  //       frameRequest,
  //       '', //gitSha,
  //       description,
  //     ].join('\t');
  //     durations.writeln(row);
  //   }
  // } finally {
  //   await durations?.close();
  // }

  print(buildTimesStat);
}
