import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  final String taskName;
  final int taskSeverity; // 1–5 (1=Lowest, 2=Low, 3=Medium, 4=High, 5=Critical)
  final String taskDescription;
  final bool taskCompleted;
  final String assignedTo;
  final String teamName;
  final String teamId;
  final double latitude;
  final double longitude;
  final String? address; // Optional address field
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
    this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      taskName: data['taskName'] as String? ?? '',
      taskSeverity: data['taskSeverity'] as int? ?? 3,
      taskDescription: data['taskDescription'] as String? ?? '',
      taskCompleted: data['taskCompleted'] as bool? ?? false,
      assignedTo: data['assignedTo'] as String? ?? '',
      teamName: data['teamName'] as String? ?? '',
      teamId: data['teamId'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskName': taskName,
      'taskSeverity': taskSeverity,
      'taskDescription': taskDescription,
      'taskCompleted': taskCompleted,
      'assignedTo': assignedTo,
      'teamName': teamName,
      'teamId': teamId,
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
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
    String? address,
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
      address: address ?? this.address,
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

  /// Get priority label from severity level
  String get priorityLabel {
    switch (taskSeverity) {
      case 1:
        return 'Lowest';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Medium';
    }
  }

  /// Get priority color from severity level
  static const priorityColors = {
    1: 0xFF4CAF50, // Green - Lowest
    2: 0xFF8BC34A, // Light Green - Low
    3: 0xFFFFC107, // Amber - Medium
    4: 0xFFFF9800, // Orange - High
    5: 0xFFF44336, // Red - Critical
  };

  int get priorityColor => priorityColors[taskSeverity] ?? priorityColors[3]!;
}

