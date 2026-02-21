// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: (json['title'] as String?) ?? (json['taskName'] as String?) ?? '',
  description:
      (json['description'] as String?) ?? (json['taskDescription'] as String?),
  createdBy: json['createdBy'] as String,
  assignedTo: json['assignedTo'] as String?,
  teamId: json['teamId'] as String,
  geoLocation: json['geoLocation'] is GeoPoint
      ? json['geoLocation'] as GeoPoint
      : (json['geoLocation'] is Map
            ? GeoPoint(
                (json['geoLocation']['latitude'] as num).toDouble(),
                (json['geoLocation']['longitude'] as num).toDouble(),
              )
            : GeoPoint(
                (json['latitude'] as num?)?.toDouble() ?? 0.0,
                (json['longitude'] as num?)?.toDouble() ?? 0.0,
              )),
  address: json['address'] as String?,
  status: TaskStatus.fromString(json['status'] as String? ?? 'pending'),
  priority: TaskPriority.fromString(json['priority'] as String? ?? 'medium'),
  category: TaskCategory.fromString(json['category'] as String? ?? 'other'),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  createdAt: json['createdAt'] == null
      ? DateTime.now()
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? DateTime.now()
      : DateTime.parse(json['updatedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'createdBy': instance.createdBy,
  'assignedTo': instance.assignedTo,
  'teamId': instance.teamId,
  'geoLocation': {
    'latitude': instance.geoLocation.latitude,
    'longitude': instance.geoLocation.longitude,
  },
  'address': instance.address,
  'status': instance.status.value,
  'priority': instance.priority.value,
  'category': instance.category.value,
  'dueDate': instance.dueDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'statusHistory': instance.statusHistory,
};
