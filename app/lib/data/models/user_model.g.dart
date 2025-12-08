// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  userRole: UserRole.fromString(json['userRole'] as String? ?? 'teamMember'),
  role: json['role'] as String,
  teamId: json['teamId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'userRole': instance.userRole.value,
  'role': instance.role,
  'teamId': instance.teamId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
};
