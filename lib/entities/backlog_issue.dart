import 'package:burn_up/entities/backlog_milestone.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'backlog_issue.freezed.dart';

part 'backlog_issue.g.dart';

@freezed
class BacklogIssue with _$BacklogIssue {
  const factory BacklogIssue({
    required int id,
    required String issueKey,
    required String summary,
    required int? estimatedHours,
    required List<BacklogMilestone> milestone,
  }) = _BacklogIssue;

  factory BacklogIssue.fromJson(Map<String, Object?> json) => _$BacklogIssueFromJson(json);
}
