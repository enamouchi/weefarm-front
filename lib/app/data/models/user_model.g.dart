// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  avatar: json['avatar'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  governorate: json['governorate'] as String?,
  municipality: json['municipality'] as String?,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  bio: json['bio'] as String?,
  farmSize: (json['farmSize'] as num?)?.toDouble(),
  experience: (json['experience'] as num?)?.toInt(),
  specialization: (json['specialization'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  certifications: (json['certifications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isVerified: json['isVerified'] as bool?,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
  totalSales: (json['totalSales'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'avatar': instance.avatar,
  'role': _$UserRoleEnumMap[instance.role]!,
  'governorate': instance.governorate,
  'municipality': instance.municipality,
  'lat': instance.lat,
  'lng': instance.lng,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'bio': instance.bio,
  'farmSize': instance.farmSize,
  'experience': instance.experience,
  'specialization': instance.specialization,
  'certifications': instance.certifications,
  'isVerified': instance.isVerified,
  'rating': instance.rating,
  'reviewsCount': instance.reviewsCount,
  'totalSales': instance.totalSales,
};

const _$UserRoleEnumMap = {
  UserRole.farmer: 'farmer',
  UserRole.citizen: 'citizen',
  UserRole.serviceProvider: 'service_provider',
  UserRole.company: 'company',
};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'tokens': instance.tokens,
    };

AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

TunisianLocation _$TunisianLocationFromJson(Map<String, dynamic> json) =>
    TunisianLocation(
      id: (json['id'] as num).toInt(),
      nameAr: json['nameAr'] as String,
      nameFr: json['nameFr'] as String,
      delegations: (json['delegations'] as List<dynamic>?)
          ?.map((e) => TunisianDelegation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TunisianLocationToJson(TunisianLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameAr': instance.nameAr,
      'nameFr': instance.nameFr,
      'delegations': instance.delegations,
    };

TunisianDelegation _$TunisianDelegationFromJson(Map<String, dynamic> json) =>
    TunisianDelegation(
      id: (json['id'] as num).toInt(),
      nameAr: json['nameAr'] as String,
      nameFr: json['nameFr'] as String,
      governorateId: (json['governorateId'] as num).toInt(),
    );

Map<String, dynamic> _$TunisianDelegationToJson(TunisianDelegation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameAr': instance.nameAr,
      'nameFr': instance.nameFr,
      'governorateId': instance.governorateId,
    };
