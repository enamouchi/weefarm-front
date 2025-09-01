
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final List<String> images;
  final String category;
  final bool isOrganic;
  final bool isFavorited; // Ajoutez cette ligne
  final String? farmerName;
  final int? farmerId;
  final String governorate;
  final String delegation;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.images,
    required this.category,
    required this.isOrganic,
    required this.isFavorited, // Ajoutez cette ligne
    this.farmerName,
    this.farmerId,
    required this.governorate,
    required this.delegation,
    this.lat,
    this.lng,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  // Méthode copyWith pour les mises à jour
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? unit,
    List<String>? images,
    String? category,
    bool? isOrganic,
    bool? isFavorited,
    String? farmerName,
    int? farmerId,
    String? governorate,
    String? delegation,
    double? lat,
    double? lng,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      images: images ?? this.images,
      category: category ?? this.category,
      isOrganic: isOrganic ?? this.isOrganic,
      isFavorited: isFavorited ?? this.isFavorited,
      farmerName: farmerName ?? this.farmerName,
      farmerId: farmerId ?? this.farmerId,
      governorate: governorate ?? this.governorate,
      delegation: delegation ?? this.delegation,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}