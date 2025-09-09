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
  lat: UserModel._stringToDouble(json['lat']),
  lng: UserModel._stringToDouble(json['lng']),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  bio: json['bio'] as String?,
  farmSize: UserModel._stringToDouble(json['farmSize']),
  experience: UserModel._stringToInt(json['experience']),
  specialization: (json['specialization'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  certifications: (json['certifications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isVerified: json['isVerified'] as bool?,
  rating: UserModel._stringToDouble(json['rating']),
  reviewsCount: UserModel._stringToInt(json['reviewsCount']),
  totalSales: UserModel._stringToDouble(json['totalSales']),
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

TunisianLocation _$TunisianLocationFromJson(Map<String, dynamic> json) =>
    TunisianLocation(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      nameFr: json['name_fr'] as String,
      nameEn: json['name_en'] as String,
      code: json['code'] as String,
      lat: TunisianLocation._stringToDouble(json['lat']),
      lng: TunisianLocation._stringToDouble(json['lng']),
      delegations: (json['delegations'] as List<dynamic>?)
          ?.map((e) => TunisianDelegation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TunisianLocationToJson(TunisianLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'name_fr': instance.nameFr,
      'name_en': instance.nameEn,
      'code': instance.code,
      'lat': instance.lat,
      'lng': instance.lng,
      'delegations': instance.delegations,
    };

TunisianDelegation _$TunisianDelegationFromJson(Map<String, dynamic> json) =>
    TunisianDelegation(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      nameFr: json['name_fr'] as String,
      nameEn: json['name_en'] as String,
      lat: TunisianDelegation._stringToDouble(json['lat']),
      lng: TunisianDelegation._stringToDouble(json['lng']),
    );

Map<String, dynamic> _$TunisianDelegationToJson(TunisianDelegation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'name_fr': instance.nameFr,
      'name_en': instance.nameEn,
      'lat': instance.lat,
      'lng': instance.lng,
    };
