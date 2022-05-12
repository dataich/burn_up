import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'backlog_milestone.freezed.dart';

part 'backlog_milestone.g.dart';

@freezed
class BacklogMilestone with _$BacklogMilestone {
  const factory BacklogMilestone({
    required int id,
    required String name,
    required DateTime? startDate,
    required DateTime? releaseDueDate,
    required bool archived,
  }) = _BacklogMilestone;

  factory BacklogMilestone.fromJson(Map<String, Object?> json) => _$BacklogMilestoneFromJson(json);
}
