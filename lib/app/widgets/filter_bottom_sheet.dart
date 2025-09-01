// lib/app/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';
import '../data/models/product_filters.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(ProductFilters) onFiltersApplied;
  final ProductFilters currentFilters;

  const FilterBottomSheet({
    Key? key,
    required this.onFiltersApplied,
    required this.currentFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ProductFilters _filters;
  RangeValues _priceRange = const RangeValues(0, 1000);
  
  final List<String> _categories = [
    'vegetables',
    'fruits', 
    'cereals',
    'dairy',
    'meat',
    'organic'
  ];
  
  final List<String> _governorates = [
    'Tunis',
    'Ariana', 
    'Ben Arous',
    'Manouba',
    'Nabeul',
    'Bizerte'
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _priceRange = RangeValues(
      _filters.minPrice ?? 0,
      _filters.maxPrice ?? 1000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: 24),
                  _buildPriceFilter(),
                  const SizedBox(height: 24),
                  _buildLocationFilter(),
                  const SizedBox(height: 24),
                  _buildOrganicFilter(),
                  const SizedBox(height: 24),
                  _buildSortFilter(),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lightGray)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'filters'.tr,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'category'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _filters.category == category;
            return FilterChip(
              label: Text(category.tr),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters = _filters.copyWith(
                    category: selected ? category : null,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'price_range'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 1000,
          divisions: 50,
          labels: RangeLabels(
            '${_priceRange.start.round()} TND',
            '${_priceRange.end.round()} TND',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
              _filters = _filters.copyWith(
                minPrice: values.start,
                maxPrice: values.end,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'location'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _filters.governorate,
          decoration: InputDecoration(
            hintText: 'select_governorate'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: _governorates.map((gov) {
            return DropdownMenuItem(
              value: gov,
              child: Text(gov),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(governorate: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildOrganicFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'organic_only'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: _filters.organicOnly,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(organicOnly: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    final sortOptions = ['newest', 'oldest', 'price_low', 'price_high'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sort_by'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...sortOptions.map((option) {
          return RadioListTile<String>(
            title: Text(option.tr),
            value: option,
            groupValue: _filters.sortBy,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(sortBy: value);
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.lightGray)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _filters = ProductFilters();
                  _priceRange = const RangeValues(0, 1000);
                });
              },
              child: Text('clear_all'.tr),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => widget.onFiltersApplied(_filters),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
              ),
              child: Text('apply_filters'.tr),
            ),
          ),
        ],
      ),
    );
  }
}