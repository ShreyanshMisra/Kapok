import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String accountType; // Admin, TeamLeader, TeamMember
  final String role; // Medical, Engineering, etc.
  final String? teamId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    required this.role,
    this.teamId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'id': doc.id});
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? accountType,
    String? role,
    String? teamId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.accountType == accountType &&
        other.role == role &&
        other.teamId == teamId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        accountType.hashCode ^
        role.hashCode ^
        teamId.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, accountType: $accountType, role: $role, teamId: $teamId)';
  }
}

