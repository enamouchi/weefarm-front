import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final UserRole role;
  final String? governorate;
  final String? municipality;
  final double? lat;
  final double? lng;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional profile fields
  final String? bio;
  final double? farmSize;
  final int? experience;
  final List<String>? specialization;
  final List<String>? certifications;
  final bool? isVerified;
  final double? rating;
  final int? reviewsCount;
  final double? totalSales;
  
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    required this.role,
    this.governorate,
    this.municipality,
    this.lat,
    this.lng,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.bio,
    this.farmSize,
    this.experience,
    this.specialization,
    this.certifications,
    this.isVerified,
    this.rating,
    this.reviewsCount,
    this.totalSales,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    UserRole? role,
    String? governorate,
    String? municipality,
    double? lat,
    double? lng,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bio,
    double? farmSize,
    int? experience,
    List<String>? specialization,
    List<String>? certifications,
    bool? isVerified,
    double? rating,
    int? reviewsCount,
    double? totalSales,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      governorate: governorate ?? this.governorate,
      municipality: municipality ?? this.municipality,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bio: bio ?? this.bio,
      farmSize: farmSize ?? this.farmSize,
      experience: experience ?? this.experience,
      specialization: specialization ?? this.specialization,
      certifications: certifications ?? this.certifications,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      totalSales: totalSales ?? this.totalSales,
    );
  }
  
  String get displayName => name;
  
  String get roleDisplayName {
    switch (role) {
      case UserRole.farmer:
        return 'مزارع';
      case UserRole.citizen:
        return 'مواطن';
      case UserRole.serviceProvider:
        return 'مقدم خدمة';
      case UserRole.company:
        return 'شركة';
    }
  }
  
  String get locationDisplay {
    if (governorate != null && municipality != null) {
      return '$municipality، $governorate';
    } else if (governorate != null) {
      return governorate!;
    }
    return 'غير محدد';
  }
  
  bool get hasLocation => lat != null && lng != null;
  
  bool get isVerifiedUser => isVerified == true;
  
  bool get isFarmer => role == UserRole.farmer;
  
  bool get isServiceProvider => role == UserRole.serviceProvider;
  
  String get experienceDisplay {
    if (experience == null) return '';
    if (experience == 1) return 'سنة واحدة من الخبرة';
    if (experience! <= 10) return '$experience سنوات من الخبرة';
    return '$experience سنة من الخبرة';
  }
  
  String get farmSizeDisplay {
    if (farmSize == null) return '';
    return '${farmSize!.toStringAsFixed(1)} هكتار';
  }
  
  double get ratingValue => rating ?? 0.0;
  
  int get reviewsCountValue => reviewsCount ?? 0;
  
  String get ratingDisplay {
    if (reviewsCountValue == 0) return 'لا توجد تقييمات';
    return '${ratingValue.toStringAsFixed(1)} (${reviewsCountValue} تقييم)';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'UserModel{id: $id, name: $name, role: $role}';
}

@JsonEnum()
enum UserRole {
  @JsonValue('farmer')
  farmer,
  
  @JsonValue('citizen')
  citizen,
  
  @JsonValue('service_provider')
  serviceProvider,
  
  @JsonValue('company')
  company,
}

@JsonSerializable()
class LoginResponse {
  final String message;
  final UserModel user;
  final AuthTokens tokens;
  
  const LoginResponse({
    required this.message,
    required this.user,
    required this.tokens,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
  
  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}

@JsonSerializable()
class TunisianLocation {
  final int id;
  final String nameAr;
  final String nameFr;
  final List<TunisianDelegation>? delegations;
  
  const TunisianLocation({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    this.delegations,
  });
  
  factory TunisianLocation.fromJson(Map<String, dynamic> json) => _$TunisianLocationFromJson(json);
  
  Map<String, dynamic> toJson() => _$TunisianLocationToJson(this);
  
  String getDisplayName(String language) {
    return language == 'ar' ? nameAr : nameFr;
  }
}

@JsonSerializable()
class TunisianDelegation {
  final int id;
  final String nameAr;
  final String nameFr;
  final int governorateId;
  
  const TunisianDelegation({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.governorateId,
  });
  
  factory TunisianDelegation.fromJson(Map<String, dynamic> json) => _$TunisianDelegationFromJson(json);
  
  Map<String, dynamic> toJson() => _$TunisianDelegationToJson(this);
  
  String getDisplayName(String language) {
    return language == 'ar' ? nameAr : nameFr;
  }
}