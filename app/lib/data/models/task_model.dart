import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  final String taskName;
  final int taskSeverity; // 1–5
  final String taskDescription;
  final bool taskCompleted;
  final String assignedTo;
  final String teamName;
  final String teamId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const TaskModel({
    required this.id,
    required this.taskName,
    required this.taskSeverity,
    required this.taskDescription,
    required this.taskCompleted,
    required this.assignedTo,
    required this.teamName,
    required this.teamId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel.fromJson({...data, 'id': doc.id});
  }

  TaskModel copyWith({
    String? id,
    String? taskName,
    int? taskSeverity,
    String? taskDescription,
    bool? taskCompleted,
    String? assignedTo,
    String? teamName,
    String? teamId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return TaskModel(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      taskSeverity: taskSeverity ?? this.taskSeverity,
      taskDescription: taskDescription ?? this.taskDescription,
      taskCompleted: taskCompleted ?? this.taskCompleted,
      assignedTo: assignedTo ?? this.assignedTo,
      teamName: teamName ?? this.teamName,
      teamId: teamId ?? this.teamId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.taskName == taskName &&
        other.taskSeverity == taskSeverity &&
        other.taskCompleted == taskCompleted &&
        other.assignedTo == assignedTo &&
        other.teamId == teamId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskName.hashCode ^
        taskSeverity.hashCode ^
        taskCompleted.hashCode ^
        assignedTo.hashCode ^
        teamId.hashCode;
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, taskName: $taskName, taskSeverity: $taskSeverity, taskCompleted: $taskCompleted, assignedTo: $assignedTo, teamName: $teamName)';
  }
}

