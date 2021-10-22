import 'package:charts_flutter/flutter.dart' as charts;
import 'package:epibox/classes/configurations.dart';

List<charts.Series<AcquiredSample, DateTime>> data2Series(
    List data, Configurations configurations) {
  List<int> aux = List<int>.generate(data.length, (i) => i + 1);

  DateTime now = DateTime.now();

  List<AcquiredSample> listSamples = aux
      .map(
        (i) => AcquiredSample(
            now.add(Duration(
                    milliseconds:
                        // ((1 / int.parse(configurations.controllerFreq.text)) *
                        //         1000)
                        //     .floor()) *
                        ((1 / 1000) * 1000).floor()) *
                (i - 1)),
            data[i - 1]),
      )
      .toList();

  return [
    new charts.Series<AcquiredSample, DateTime>(
      id: 'Samples',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (AcquiredSample sample, _) => sample.timestamp,
      measureFn: (AcquiredSample sample, _) => sample.sample,
      data: listSamples,
    )
  ];
}

class AcquiredSample {
  final DateTime timestamp;
  final double sample;

  AcquiredSample(this.timestamp, this.sample);
}
