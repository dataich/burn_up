import 'package:burn_up/burn_up_settings.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:burn_up/blocs/burn_up_bloc.dart';

class BurnUpChart extends StatelessWidget {
  const BurnUpChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BurnUpBlocProvider.of(context).bloc;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Burn Up'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BurnUpSettings())
                );
              },
            ),
        ]
      ),
      body: StreamBuilder<BurnUpData>(
          stream: bloc.onFetched,
          builder: (context, snapshot) {
            BurnUpData? data = snapshot.data;
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final backlogIssuesWithMilestones = data.backlogIssuesWithMilestones.reversed.toList();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    child: StreamBuilder<TimeSeriesStoryPoints>(
                      stream: bloc.onSelected,
                      builder: (context, snapshot) {
                        return DataTable(
                          headingRowHeight: 30,
                          dataRowHeight: 30,
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text(
                                '',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Point',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Sum',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(backlogIssuesWithMilestones.length, (index) {
                            final iSelected = snapshot.data?.sprintName == backlogIssuesWithMilestones[index].milestone.name;
                            final selectedStyle = iSelected ? const TextStyle(fontWeight: FontWeight.bold) : const TextStyle(fontWeight: FontWeight.normal);
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(Text(backlogIssuesWithMilestones[index].isForecast ? "🏃‍♂️️" : "")),
                                DataCell(Text(backlogIssuesWithMilestones[index].milestone.name, style: selectedStyle)),
                                DataCell(Text(backlogIssuesWithMilestones[index].sprintStoryPoints.toString(), style: selectedStyle)),
                                DataCell(Text(backlogIssuesWithMilestones[index].totalStoryPoints.toString(), style: selectedStyle)),
                              ],
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: charts.TimeSeriesChart(
                      data.seriesList,
                      animate: false,
                      defaultRenderer: charts.LineRendererConfig(includePoints: true),
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                      primaryMeasureAxis: const charts.NumericAxisSpec(tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false)),
                      domainAxis: const charts.DateTimeAxisSpec(
                        tickProviderSpec: charts.DayTickProviderSpec(increments: [7]),
                        showAxisLine: true,
                      ),
                      selectionModels: [
                        charts.SelectionModelConfig(
                          type: charts.SelectionModelType.info,
                          changedListener: bloc.selected.add,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
