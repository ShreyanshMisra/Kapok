import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_model.g.dart';

@JsonSerializable()
class TeamModel {
  final String id;
  final String name;
  final String leaderId;
  final String teamCode;
  final List<String> memberIds;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const TeamModel({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.teamCode,
    required this.memberIds,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) => _$TeamModelFromJson(json);
  Map<String, dynamic> toJson() => _$TeamModelToJson(this);

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TeamModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      leaderId: data['leaderId'] as String? ?? '',
      teamCode: data['teamCode'] as String? ?? '',
      memberIds: (data['memberIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'leaderId': leaderId,
      'teamCode': teamCode,
      'memberIds': memberIds,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? leaderId,
    String? teamCode,
    List<String>? memberIds,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      leaderId: leaderId ?? this.leaderId,
      teamCode: teamCode ?? this.teamCode,
      memberIds: memberIds ?? this.memberIds,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamModel &&
        other.id == id &&
        other.name == name &&
        other.leaderId == leaderId &&
        other.teamCode == teamCode &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        leaderId.hashCode ^
        teamCode.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'TeamModel(id: $id, name: $name, leaderId: $leaderId, teamCode: $teamCode, memberIds: $memberIds, isActive: $isActive)';
  }
}

