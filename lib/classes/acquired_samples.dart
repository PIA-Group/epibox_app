import 'package:charts_flutter/flutter.dart' as charts;
import 'package:epibox/classes/configurations.dart';

List<charts.Series<AcquiredSample, int>> data2Series(
    List data, Configurations configurations) {
  List<int> aux = List<int>.generate(data.length, (i) => i + 1);

  //DateTime now = DateTime.now();

  List<AcquiredSample> listSamples = aux.map(
    (i) {
      return AcquiredSample(i + 1, data[i - 1]);
    },
  ).toList();

  return [
    new charts.Series<AcquiredSample, int>(
      id: 'Samples',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (AcquiredSample sample, _) => sample.timestamp,
      measureFn: (AcquiredSample sample, _) => sample.sample,
      data: listSamples,
    )
  ];
}

class AcquiredSample {
  final int timestamp;
  final double sample;

  AcquiredSample(this.timestamp, this.sample);
}
