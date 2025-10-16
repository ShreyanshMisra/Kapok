// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String,
      taskName: json['taskName'] as String,
      taskSeverity: json['taskSeverity'] as int,
      taskDescription: json['taskDescription'] as String,
      taskCompleted: json['taskCompleted'] as bool,
      assignedTo: json['assignedTo'] as String,
      teamName: json['teamName'] as String,
      teamId: json['teamId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'taskName': instance.taskName,
      'taskSeverity': instance.taskSeverity,
      'taskDescription': instance.taskDescription,
      'taskCompleted': instance.taskCompleted,
      'assignedTo': instance.assignedTo,
      'teamName': instance.teamName,
      'teamId': instance.teamId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };