import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/enums/user_role.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole userRole; // Changed from accountType to enum
  final String role; // Medical, Engineering, etc. (specialty)
  final String?
  teamId; // Nullable for leaders without teams, required for members
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt; // New field

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userRole,
    required this.role,
    this.teamId,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Convert userRole string to enum
    final jsonCopy = Map<String, dynamic>.from(json);
    if (jsonCopy['userRole'] is String) {
      jsonCopy['userRole'] = UserRole.fromString(jsonCopy['userRole']).value;
    }
    return _$UserModelFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() {
    final json = _$UserModelToJson(this);
    // Convert enum to string for JSON
    json['userRole'] = userRole.value;
    return json;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('User document data is null');
      }

      // Handle migration from accountType to userRole
      String? userRoleValue;
      if (data.containsKey('userRole')) {
        userRoleValue = data['userRole'] as String?;
      } else if (data.containsKey('accountType')) {
        // Migrate old accountType to userRole
        final accountType = data['accountType'] as String?;
        // Map old values to new enum values (case-insensitive)
        userRoleValue = UserRole.fromString(accountType).value;
      }

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

      // Handle lastActiveAt - can be Timestamp, ISO string, or null
      DateTime? lastActiveAt;
      if (data.containsKey('lastActiveAt') && data['lastActiveAt'] != null) {
        if (data['lastActiveAt'] is Timestamp) {
          lastActiveAt = (data['lastActiveAt'] as Timestamp).toDate();
        } else if (data['lastActiveAt'] is String) {
          try {
            lastActiveAt = DateTime.parse(data['lastActiveAt'] as String);
          } catch (e) {
            lastActiveAt = null;
          }
        }
      }

      // Use id from document data if present (old format), otherwise use doc.id
      final userId = data['id'] as String? ?? doc.id;

      return UserModel(
        id: userId,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        userRole: UserRole.fromString(userRoleValue ?? 'teamMember'),
        role: data['role'] as String? ?? '',
        teamId: data['teamId'] as String?,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastActiveAt: lastActiveAt,
      );
    } catch (e) {
      throw Exception('Failed to parse user document: ${e.toString()}');
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id, // Include id field for backward compatibility
      'name': name,
      'email': email,
      'userRole': userRole.value,
      'role': role,
      if (teamId != null) 'teamId': teamId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (lastActiveAt != null)
        'lastActiveAt': Timestamp.fromDate(lastActiveAt!),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? userRole,
    String? role,
    String? teamId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.userRole == userRole &&
        other.role == role &&
        other.teamId == teamId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        userRole.hashCode ^
        role.hashCode ^
        teamId.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, userRole: ${userRole.value}, role: $role, teamId: $teamId)';
  }
}
