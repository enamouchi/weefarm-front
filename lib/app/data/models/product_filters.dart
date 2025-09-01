class ProductFilters {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? governorate;
  final bool organicOnly;
  final String sortBy;
  
  const ProductFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.governorate,
    this.organicOnly = false,
    this.sortBy = 'newest',
  });
  
  ProductFilters copyWith({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? governorate,
    bool? organicOnly,
    String? sortBy,
  }) {
    return ProductFilters(
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      governorate: governorate ?? this.governorate,
      organicOnly: organicOnly ?? this.organicOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
  
  bool get isEmpty {
    return category == null &&
        minPrice == null &&
        maxPrice == null &&
        governorate == null &&
        !organicOnly &&
        sortBy == 'newest';
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (category != null) 'category': category,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (governorate != null) 'governorate': governorate,
      if (organicOnly) 'organic_only': organicOnly,
      'sort_by': sortBy,
    };
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilters &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          governorate == other.governorate &&
          organicOnly == other.organicOnly &&
          sortBy == other.sortBy;
  
  @override
  int get hashCode =>
      category.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      governorate.hashCode ^
      organicOnly.hashCode ^
      sortBy.hashCode;
}