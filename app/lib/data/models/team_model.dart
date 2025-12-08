import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TeamModel {
  final String id;
  final String teamName; // Changed from 'name' to 'teamName'
  final String leaderId;
  final String teamCode; // 6-character uppercase unique code
  final List<String> memberIds; // Max 50 members, includes leader
  final List<String> taskIds; // NEW: List of task IDs for this team
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive; // For soft deletion

  const TeamModel({
    required this.id,
    required this.teamName,
    required this.leaderId,
    required this.teamCode,
    required this.memberIds,
    this.taskIds = const [], // Default to empty list
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'name' and 'teamName' for backward compatibility
    final jsonCopy = Map<String, dynamic>.from(json);
    if (jsonCopy.containsKey('name') && !jsonCopy.containsKey('teamName')) {
      jsonCopy['teamName'] = jsonCopy['name'];
    }
    return _$TeamModelFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() => _$TeamModelToJson(this);

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle createdAt - can be Timestamp or ISO string
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      try {
        createdAt = DateTime.parse(data['createdAt'] as String);
      } catch (e) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    // Handle updatedAt - can be Timestamp or ISO string
    DateTime updatedAt;
    if (data['updatedAt'] is Timestamp) {
      updatedAt = (data['updatedAt'] as Timestamp).toDate();
    } else if (data['updatedAt'] is String) {
      try {
        updatedAt = DateTime.parse(data['updatedAt'] as String);
      } catch (e) {
        updatedAt = DateTime.now();
      }
    } else {
      updatedAt = DateTime.now();
    }

    return TeamModel(
      id: doc.id,
      teamName:
          (data['teamName'] as String?) ?? (data['name'] as String?) ?? '',
      leaderId: data['leaderId'] as String? ?? '',
      teamCode: data['teamCode'] as String? ?? '',
      memberIds:
          (data['memberIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      taskIds:
          (data['taskIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [], // Handle missing field for backward compatibility
      description: data['description'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamName': teamName,
      'leaderId': leaderId,
      'teamCode': teamCode,
      'memberIds': memberIds,
      'taskIds': taskIds, // Include taskIds in Firestore
      if (description != null) 'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  TeamModel copyWith({
    String? id,
    String? teamName,
    String? leaderId,
    String? teamCode,
    List<String>? memberIds,
    List<String>? taskIds,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TeamModel(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      leaderId: leaderId ?? this.leaderId,
      teamCode: teamCode ?? this.teamCode,
      memberIds: memberIds ?? this.memberIds,
      taskIds: taskIds ?? this.taskIds,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get member count
  int get memberCount => memberIds.length;

  /// Check if team is full (max 50 members)
  bool get isFull => memberIds.length >= 50;

  /// Check if user is member
  bool isMember(String userId) => memberIds.contains(userId);

  /// Check if user is leader
  bool isLeader(String userId) => leaderId == userId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamModel &&
        other.id == id &&
        other.teamName == teamName &&
        other.leaderId == leaderId &&
        other.teamCode == teamCode &&
        other.taskIds.length == taskIds.length &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        teamName.hashCode ^
        leaderId.hashCode ^
        teamCode.hashCode ^
        taskIds.length.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'TeamModel(id: $id, teamName: $teamName, leaderId: $leaderId, teamCode: $teamCode, memberCount: $memberCount, taskCount: ${taskIds.length}, isActive: $isActive)';
  }
}
