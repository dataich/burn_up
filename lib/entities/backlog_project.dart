import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'backlog_project.freezed.dart';

part 'backlog_project.g.dart';

@freezed
class BacklogProject with _$BacklogProject {
  const factory BacklogProject({
    required int id,
    required String name,
  }) = _BacklogProject;

  factory BacklogProject.fromJson(Map<String, Object?> json) => _$BacklogProjectFromJson(json);
}
