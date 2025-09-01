// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  unit: json['unit'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  category: json['category'] as String,
  isOrganic: json['isOrganic'] as bool,
  isFavorited: json['isFavorited'] as bool,
  farmerName: json['farmerName'] as String?,
  farmerId: (json['farmerId'] as num?)?.toInt(),
  governorate: json['governorate'] as String,
  delegation: json['delegation'] as String,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'unit': instance.unit,
      'images': instance.images,
      'category': instance.category,
      'isOrganic': instance.isOrganic,
      'isFavorited': instance.isFavorited,
      'farmerName': instance.farmerName,
      'farmerId': instance.farmerId,
      'governorate': instance.governorate,
      'delegation': instance.delegation,
      'lat': instance.lat,
      'lng': instance.lng,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
