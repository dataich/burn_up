import 'dart:async';
import 'package:burn_up/entities/backlog_issue.dart';
import 'package:burn_up/entities/backlog_issue_type.dart';
import 'package:burn_up/entities/backlog_milestone.dart';
import 'package:burn_up/repositories/backlog_repository.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:collection/collection.dart';

class BurnUpBloc {
  static const releaseMilestoneKeyword = "Release";
  static const sprintMilestoneKeyword = "Sprint";

  final _burnUpDataController = StreamController<BurnUpData>();
  final _burnUpSelectionOutputController = StreamController<TimeSeriesStoryPoints>();
  final _burnUpSelectionInputController = StreamController<charts.SelectionModel>();
  final IBacklogIssuesRepository _backlogRepository = BacklogRepository();

  Stream<BurnUpData> get onFetched => _burnUpDataController.stream;

  Stream<TimeSeriesStoryPoints> get onSelected => _burnUpSelectionOutputController.stream;

  StreamSink<charts.SelectionModel> get selected => _burnUpSelectionInputController.sink;

  BurnUpBloc() {
    _burnUpSelectionInputController.stream.listen((model) => _burnUpSelectionOutputController.sink.add(model.selectedDatum.first.datum));

    _fetchBurnUpData();
  }

  BacklogIssueType? _getIssueTypeByName(List<BacklogIssueType> issueTypes, String issueTypeName) {
    return issueTypes.firstWhereOrNull((issueType) => issueType.name == issueTypeName);
  }

  BacklogMilestone? _getReleaseMilestone(List<BacklogMilestone> milestones, String milestonePrefix) {
    return milestones.firstWhereOrNull((milestone) => milestone.name.startsWith(milestonePrefix) && milestone.name.contains(releaseMilestoneKeyword));
  }

  void _fetchBurnUpData() async {
    final project = await _backlogRepository.fetchProject();
    final milestones = await _backlogRepository.fetchMilestones();
    final issueTypes = await _backlogRepository.fetchIssueTypes();

    String issueTypeName = dotenv.get('BACKLOG_ISSUE_TYPE_NAME');
    BacklogIssueType? issueType = _getIssueTypeByName(issueTypes, issueTypeName);

    String milestonePrefix = dotenv.get('BACKLOG_MILESTONE_PREFIX');
    BacklogMilestone? releaseMilestone = _getReleaseMilestone(milestones, milestonePrefix);

    final issues = await _backlogRepository.fetchIssues(project.id, issueType?.id ?? 0, releaseMilestone?.id ?? 0);

    final sprintMilestones = _getSortedSprintMilestones(milestones, milestonePrefix);
    final backlogIssuesWithMilestones = _createBacklogIssuesWithMilestones(issues, sprintMilestones, releaseMilestone!);
    final seriesList = _createSeriesList(backlogIssuesWithMilestones, issues, sprintMilestones);

    _burnUpDataController.sink.add(BurnUpData(seriesList, backlogIssuesWithMilestones));
  }

  List<BacklogIssuesWithMilestone> _createBacklogIssuesWithMilestones(List<BacklogIssue> issues, List<BacklogMilestone> milestones, BacklogMilestone releaseMilestone) {
    final List<BacklogIssuesWithMilestone> backlogIssuesWithMilestones = milestones.map((milestone) {
      return BacklogIssuesWithMilestone(milestone, [], 0, 0);
    }).toList();

    for (var issue in issues) {
      for (var milestone in issue.milestone) {
        if (milestone == releaseMilestone) continue;

        BacklogIssuesWithMilestone? backlogIssuesWithMilestone = backlogIssuesWithMilestones.firstWhereOrNull((element) => element.milestone == milestone);
        backlogIssuesWithMilestone?.issues.add(issue);
      }
    }

    backlogIssuesWithMilestones.sort((a, b) => a.milestone.releaseDueDate?.compareTo(b.milestone.releaseDueDate ?? DateTime.now()) ?? 0);

    int totalStoryPoint = 0;
    final velocityByLast3Sprints = (backlogIssuesWithMilestones.reversed.take(3).fold<int>(0, (previousValue, milestone) => previousValue + (milestone.issues.fold<int>(0, (previousValue, issue) => previousValue + (issue.estimatedHours ?? 0)))) / 3).floor();
    return backlogIssuesWithMilestones.map((backlogIssuesWithMilestone) {
      final sprintStoryPoints = backlogIssuesWithMilestone.issues.fold<int>(0, (previousValue, issue) => previousValue + (issue.estimatedHours ?? 0));
      totalStoryPoint += (sprintStoryPoints > 0 ? sprintStoryPoints : velocityByLast3Sprints);

      return BacklogIssuesWithMilestone(backlogIssuesWithMilestone.milestone, backlogIssuesWithMilestone.issues, sprintStoryPoints, totalStoryPoint);
    }).toList();
  }

  List<TimeSeriesStoryPoints> _createTimeSeriesStoryPointsCompletedPointsData(List<BacklogIssuesWithMilestone> backlogIssuesWithMilestones) {
    List<TimeSeriesStoryPoints> timeSeriesStoryPointsList = backlogIssuesWithMilestones.map((backlogIssuesWithMilestone) {
      BacklogMilestone milestone = backlogIssuesWithMilestone.milestone;
      return TimeSeriesStoryPoints(milestone.releaseDueDate ?? DateTime.now(), backlogIssuesWithMilestone.totalStoryPoints, milestone.name);
    }).toList();

    timeSeriesStoryPointsList.insert(0, TimeSeriesStoryPoints(backlogIssuesWithMilestones.first.milestone.startDate ?? DateTime.now(), 0, ""));

    return timeSeriesStoryPointsList;
  }

  List<TimeSeriesStoryPoints> _createTimeSeriesStoryPointsTotalPointsData(List<BacklogIssue> issues, List<BacklogMilestone> milestones) {
    final totalsPoint = issues.fold<int>(0, (previousValue, issue) => previousValue + (issue.estimatedHours ?? 0));

    return [
      TimeSeriesStoryPoints(milestones.first.startDate ?? DateTime.now(), totalsPoint, null),
      TimeSeriesStoryPoints(milestones.last.releaseDueDate ?? DateTime.now(), totalsPoint, null),
    ];
  }

  List<BacklogMilestone> _getSortedSprintMilestones(List<BacklogMilestone> milestones, String milestonePrefix) {
    final sprintMilestones = milestones.where((milestone) {
      print(milestone.startDate);
      print(milestone.releaseDueDate);
      return milestone.name.startsWith(milestonePrefix) &&
          milestone.name.contains(sprintMilestoneKeyword) &&
          milestone.startDate != null &&
          milestone.releaseDueDate != null;
      }).toList();

    sprintMilestones.sort((a, b) => a.releaseDueDate?.compareTo(b.releaseDueDate ?? DateTime.now()) ?? 0);

    return sprintMilestones;
  }

  List<charts.Series<TimeSeriesStoryPoints, DateTime>> _createSeriesList(List<BacklogIssuesWithMilestone> backlogIssuesWithMilestones, List<BacklogIssue> issues, List<BacklogMilestone> sprintMilestones) {
    final completedPointsTimeSeriesData = _createTimeSeriesStoryPointsCompletedPointsData(backlogIssuesWithMilestones);
    final totalPointsSeriesData = _createTimeSeriesStoryPointsTotalPointsData(issues, sprintMilestones);

    return [
      charts.Series<TimeSeriesStoryPoints, DateTime>(
        id: 'Completed Story Points',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesStoryPoints points, _) => points.time,
        measureFn: (TimeSeriesStoryPoints points, _) => points.storyPoints,
        data: completedPointsTimeSeriesData,
      ),
      charts.Series<TimeSeriesStoryPoints, DateTime>(
        id: 'Estimated Story Points',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesStoryPoints points, _) => points.time,
        measureFn: (TimeSeriesStoryPoints points, _) => points.storyPoints,
        data: totalPointsSeriesData,
      )
    ];
  }
}

class BurnUpBlocProvider extends InheritedWidget {
  const BurnUpBlocProvider({Key? key, required Widget child}) : super(key: key, child: child);

  BurnUpBloc get bloc => BurnUpBloc();

  @override
  bool updateShouldNotify(oldWidget) => oldWidget != this;

  static BurnUpBlocProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BurnUpBlocProvider>()!;
  }
}

class TimeSeriesStoryPoints {
  final DateTime time;
  final int storyPoints;
  final String? sprintName;

  TimeSeriesStoryPoints(this.time, this.storyPoints, this.sprintName);
}

class BurnUpData {
  final List<charts.Series<TimeSeriesStoryPoints, DateTime>> seriesList;
  final List<BacklogIssuesWithMilestone> backlogIssuesWithMilestones;

  const BurnUpData(this.seriesList, this.backlogIssuesWithMilestones);
}

class BacklogIssuesWithMilestone {
  final BacklogMilestone milestone;
  final List<BacklogIssue> issues;
  final int sprintStoryPoints;
  final int totalStoryPoints;

  const BacklogIssuesWithMilestone(this.milestone, this.issues, this.sprintStoryPoints, this.totalStoryPoints);
}
