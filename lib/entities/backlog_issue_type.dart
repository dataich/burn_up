import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'backlog_issue_type.freezed.dart';

part 'backlog_issue_type.g.dart';

@freezed
class BacklogIssueType with _$BacklogIssueType {
  const factory BacklogIssueType({
    required int id,
    required String name,
  }) = _BacklogIssueType;

  factory BacklogIssueType.fromJson(Map<String, Object?> json) => _$BacklogIssueTypeFromJson(json);
}
