import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/task_priority.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  final String title; // Required, max 100 chars
  final String? description; // Optional, max 500 chars
  final String createdBy; // userId of creator
  final String? assignedTo; // userId or null for unassigned
  final String teamId; // Required, foreign key to team
  final GeoPoint geoLocation; // Required, latitude and longitude
  final String? address; // Human-readable address, auto-reverse-geocoded
  final TaskStatus status; // Enum: Pending, InProgress, Completed
  final TaskPriority priority; // Enum: Low, Medium, High
  final DateTime? dueDate; // Optional
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt; // Nullable, set when status becomes Completed

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdBy,
    this.assignedTo,
    required this.teamId,
    required this.geoLocation,
    this.address,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final jsonCopy = Map<String, dynamic>.from(json);

    // Convert geoLocation map to GeoPoint
    if (jsonCopy['geoLocation'] is Map) {
      final geo = jsonCopy['geoLocation'] as Map<String, dynamic>;
      jsonCopy['geoLocation'] = GeoPoint(
        (geo['latitude'] as num).toDouble(),
        (geo['longitude'] as num).toDouble(),
      );
    }

    // Convert status string to enum
    if (jsonCopy['status'] is String) {
      jsonCopy['status'] = TaskStatus.fromString(jsonCopy['status']).value;
    }

    // Convert priority string to enum
    if (jsonCopy['priority'] is String) {
      jsonCopy['priority'] = TaskPriority.fromString(
        jsonCopy['priority'],
      ).value;
    }

    return _$TaskModelFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() {
    final json = _$TaskModelToJson(this);
    // Convert enum to string for JSON
    json['status'] = status.value;
    json['priority'] = priority.value;
    // Convert GeoPoint to map for JSON
    json['geoLocation'] = {
      'latitude': geoLocation.latitude,
      'longitude': geoLocation.longitude,
    };
    return json;
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    GeoPoint geoPoint;
    if (data['geoLocation'] is GeoPoint) {
      geoPoint = data['geoLocation'] as GeoPoint;
    } else if (data['geoLocation'] is Map) {
      final geo = data['geoLocation'] as Map<String, dynamic>;
      geoPoint = GeoPoint(
        (geo['latitude'] as num).toDouble(),
        (geo['longitude'] as num).toDouble(),
      );
    } else {
      // Fallback to latitude/longitude fields for backward compatibility
      geoPoint = GeoPoint(
        (data['latitude'] as num?)?.toDouble() ?? 0.0,
        (data['longitude'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return TaskModel(
      id: doc.id,
      title: data['title'] as String? ?? (data['taskName'] as String?) ?? '',
      description:
          data['description'] as String? ??
          (data['taskDescription'] as String?),
      createdBy: data['createdBy'] as String? ?? '',
      assignedTo: data['assignedTo'] as String?,
      teamId: data['teamId'] as String? ?? '',
      geoLocation: geoPoint,
      address: data['address'] as String?,
      status: TaskStatus.fromString(data['status'] as String? ?? 'pending'),
      priority: TaskPriority.fromString(
        data['priority'] as String? ?? 'medium',
      ),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'createdBy': createdBy,
      if (assignedTo != null) 'assignedTo': assignedTo,
      'teamId': teamId,
      'geoLocation': geoLocation,
      if (address != null) 'address': address,
      'status': status.value,
      'priority': priority.value,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    String? assignedTo,
    String? teamId,
    GeoPoint? geoLocation,
    String? address,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      teamId: teamId ?? this.teamId,
      geoLocation: geoLocation ?? this.geoLocation,
      address: address ?? this.address,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Get latitude from geoLocation
  double get latitude => geoLocation.latitude;

  /// Get longitude from geoLocation
  double get longitude => geoLocation.longitude;

  // Backward compatibility getters for old field names
  /// @deprecated Use title instead
  String get taskName => title;

  /// @deprecated Use description instead
  String get taskDescription => description ?? '';

  /// @deprecated Use priority instead (returns 1-5 based on priority enum)
  int get taskSeverity {
    switch (priority) {
      case TaskPriority.low:
        return 2;
      case TaskPriority.medium:
        return 3;
      case TaskPriority.high:
        return 4;
    }
  }

  /// @deprecated Use status instead
  bool get taskCompleted => status == TaskStatus.completed;

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Get priority color for UI
  int get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return 0xFF4CAF50; // Green
      case TaskPriority.medium:
        return 0xFFFFC107; // Amber
      case TaskPriority.high:
        return 0xFFF44336; // Red
    }
  }

  /// Get status color for UI
  int get statusColor {
    switch (status) {
      case TaskStatus.pending:
        return 0xFF9E9E9E; // Gray
      case TaskStatus.inProgress:
        return 0xFF2196F3; // Blue
      case TaskStatus.completed:
        return 0xFF4CAF50; // Green
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.status == status &&
        other.teamId == teamId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ status.hashCode ^ teamId.hashCode;
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, status: ${status.value}, priority: ${priority.value}, teamId: $teamId)';
  }
}
