import 'dart:convert';

import 'package:burn_up/entities/backlog_issue.dart';
import 'package:burn_up/entities/backlog_issue_type.dart';
import 'package:burn_up/entities/backlog_project.dart';
import 'package:burn_up/entities/backlog_milestone.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class IBacklogIssuesRepository {
  Future<BacklogProject> fetchProject();

  Future<List<BacklogMilestone>> fetchMilestones();

  Future<List<BacklogIssueType>> fetchIssueTypes();

  Future<List<BacklogIssue>> fetchIssues(int projectId, int issueTypeId, int milestoneId);
}

class BacklogRepository extends IBacklogIssuesRepository {
  String backlogApiHost = dotenv.get('BACKLOG_API_HOST');
  String apiKey = dotenv.get('BACKLOG_API_KEY');
  String projectKey = dotenv.get('BACKLOG_PROJECT_KEY');

  Future<http.Response> _fetch(String path, Map<String, dynamic>? params) async {
    final paramsWithApiKey = params ?? {};
    paramsWithApiKey['apiKey'] = apiKey;

    final url = Uri.https(backlogApiHost, '/api/v2$path', paramsWithApiKey);

    return http.get(url);
  }

  @override
  Future<BacklogProject> fetchProject() async {
    final response = await _fetch('/projects/$projectKey', null);
    final json = jsonDecode(response.body);
    final project = BacklogProject.fromJson(json);

    return project;
  }

  @override
  Future<List<BacklogIssueType>> fetchIssueTypes() async {
    final response = await _fetch('/projects/$projectKey/issueTypes', null);
    final List jsonList = jsonDecode(response.body);
    final issueTypes = jsonList.map((json) => BacklogIssueType.fromJson(json)).toList();

    return issueTypes;
  }

  @override
  Future<List<BacklogMilestone>> fetchMilestones() async {
    final response = await _fetch('/projects/$projectKey/versions', null);
    final List jsonList = jsonDecode(response.body);
    final milestones = jsonList.map((json) => BacklogMilestone.fromJson(json)).toList();

    return milestones;
  }

  @override
  Future<List<BacklogIssue>> fetchIssues(int projectId, int issueTypeId, int milestoneId) async {
    const count = 100;
    int lastFetchedCount = 0;

    List<BacklogIssue> allIssues = [];
    do {
      final response = await _fetch('/issues', {'apiKey': apiKey, 'projectId[]': '$projectId', 'issueTypeId[]': '$issueTypeId', 'milestoneId[]': '$milestoneId', 'count': '$count', 'offset': '${allIssues.length}'});

      final List jsonList = jsonDecode(response.body);
      final issues = jsonList.map((json) => BacklogIssue.fromJson(json)).toList();
      allIssues.addAll(issues);
      lastFetchedCount = issues.length;

      if (allIssues.length >= 1000) {
        // Take care about API Limit
        break;
      }
    } while (count == lastFetchedCount);

    return allIssues;
  }
}
