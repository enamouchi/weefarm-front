import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';
import '../core/services/api_service.dart';

class LocationSelector extends StatefulWidget {
  final Function(TunisianLocation?, TunisianDelegation?)? onLocationSelected;
  final TunisianLocation? initialGovernorate;
  final TunisianDelegation? initialDelegation;
  
  const LocationSelector({
    Key? key,
    this.onLocationSelected,
    this.initialGovernorate,
    this.initialDelegation,
  }) : super(key: key);

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  TunisianLocation? selectedGovernorate;
  TunisianDelegation? selectedDelegation;
  List<TunisianLocation> governorates = [];
  List<TunisianDelegation> availableDelegations = [];
  bool isLoadingGovernorates = true;
  bool isLoadingDelegations = false;

  @override
  void initState() {
    super.initState();
    selectedGovernorate = widget.initialGovernorate;
    selectedDelegation = widget.initialDelegation;
    _loadGovernorates();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGovernorateDropdown(),
        const SizedBox(height: 16),
        _buildDelegationDropdown(),
      ],
    );
  }
  
  Widget _buildGovernorateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'governorate'.tr,
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoadingGovernorates
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      ),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<TunisianLocation>(
                    value: selectedGovernorate,
                    hint: Text(
                      'select_governorate'.tr,
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mediumGray),
                    onChanged: (TunisianLocation? value) {
                      setState(() {
                        selectedGovernorate = value;
                        selectedDelegation = null;
                        _updateDelegations();
                      });
                      _notifyLocationChange();
                    },
                    items: governorates.map((TunisianLocation governorate) {
                      return DropdownMenuItem<TunisianLocation>(
                        value: governorate,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_city,
                              size: 20,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              governorate.getDisplayName(Get.locale?.languageCode ?? 'en'),
                              style: Get.textTheme.bodyLarge?.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildDelegationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'delegation'.tr,
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: selectedGovernorate == null ? AppColors.lightGray : AppColors.white,
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoadingDelegations
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      ),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<TunisianDelegation>(
                    value: selectedDelegation,
                    hint: Text(
                      selectedGovernorate == null
                          ? 'select_governorate_first'.tr
                          : 'select_delegation'.tr,
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: selectedGovernorate == null ? AppColors.lightGray : AppColors.mediumGray,
                    ),
                    onChanged: selectedGovernorate == null 
                        ? null 
                        : (TunisianDelegation? value) {
                            setState(() {
                              selectedDelegation = value;
                            });
                            _notifyLocationChange();
                          },
                    items: availableDelegations.map((TunisianDelegation delegation) {
                      return DropdownMenuItem<TunisianDelegation>(
                        value: delegation,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: AppColors.accentTeal,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              delegation.getDisplayName(Get.locale?.languageCode ?? 'en'),
                              style: Get.textTheme.bodyLarge?.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
  
  // Load governorates from backend API
  Future<void> _loadGovernorates() async {
    try {
      setState(() {
        isLoadingGovernorates = true;
      });
      
      final apiService = Get.find<ApiService>();
      final response = await apiService.get('/auth/locations');
      
      if (response.statusCode == 200 && response.data['governorates'] != null) {
        final locationsList = (response.data['governorates'] as List)
            .map((location) => TunisianLocation.fromJson(location))
            .toList();
        
        setState(() {
          governorates = locationsList;
          isLoadingGovernorates = false;
        });
        
        // If initial governorate is set, find and select it
        if (widget.initialGovernorate != null) {
          final initialGov = _findGovernorateById(widget.initialGovernorate!.id);
          if (initialGov != null) {
            setState(() {
              selectedGovernorate = initialGov;
            });
            _updateDelegations();
          }
        }
      }
    } catch (e) {
      print('Error loading governorates: $e');
      setState(() {
        isLoadingGovernorates = false;
      });
      
      // Show error message
      Get.snackbar(
        'error'.tr,
        'failed_to_load_locations'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }
  
  void _updateDelegations() {
    if (selectedGovernorate?.delegations != null) {
      setState(() {
        availableDelegations = selectedGovernorate!.delegations!;
        
        // If initial delegation is set, find and select it
        if (widget.initialDelegation != null) {
          final initialDel = _findDelegationById(widget.initialDelegation!.id);
          if (initialDel != null) {
            selectedDelegation = initialDel;
          }
        }
      });
    } else {
      setState(() {
        availableDelegations = [];
      });
    }
  }
  
  void _notifyLocationChange() {
    widget.onLocationSelected?.call(selectedGovernorate, selectedDelegation);
  }
  
  // Helper methods to find items by ID
  TunisianLocation? _findGovernorateById(int id) {
    for (final gov in governorates) {
      if (gov.id == id) return gov;
    }
    return null;
  }
  
  TunisianDelegation? _findDelegationById(int id) {
    for (final del in availableDelegations) {
      if (del.id == id) return del;
    }
    return null;
  }
}

// Location models to match your backend API structure
class TunisianLocation {
  final int id;
  final String nameAr;
  final String nameFr;
  final String nameEn;
  final String code;
  final double lat;
  final double lng;
  final List<TunisianDelegation>? delegations;

  TunisianLocation({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.nameEn,
    required this.code,
    required this.lat,
    required this.lng,
    this.delegations,
  });

  factory TunisianLocation.fromJson(Map<String, dynamic> json) {
    return TunisianLocation(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameFr: json['name_fr'] ?? '',
      nameEn: json['name_en'] ?? '',
      code: json['code'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      delegations: json['delegations'] != null
          ? (json['delegations'] as List)
              .map((del) => TunisianDelegation.fromJson(del))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_fr': nameFr,
      'name_en': nameEn,
      'code': code,
      'lat': lat,
      'lng': lng,
      if (delegations != null)
        'delegations': delegations!.map((del) => del.toJson()).toList(),
    };
  }

  String getDisplayName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ar':
        return nameAr.isNotEmpty ? nameAr : nameEn;
      case 'fr':
        return nameFr.isNotEmpty ? nameFr : nameEn;
      default:
        return nameEn.isNotEmpty ? nameEn : nameFr;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TunisianLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TunisianDelegation {
  final int id;
  final String nameAr;
  final String nameFr;
  final String nameEn;
  final double lat;
  final double lng;

  TunisianDelegation({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.nameEn,
    required this.lat,
    required this.lng,
  });

  factory TunisianDelegation.fromJson(Map<String, dynamic> json) {
    return TunisianDelegation(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameFr: json['name_fr'] ?? '',
      nameEn: json['name_en'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_fr': nameFr,
      'name_en': nameEn,
      'lat': lat,
      'lng': lng,
    };
  }

  String getDisplayName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ar':
        return nameAr.isNotEmpty ? nameAr : nameEn;
      case 'fr':
        return nameFr.isNotEmpty ? nameFr : nameEn;
      default:
        return nameEn.isNotEmpty ? nameEn : nameFr;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TunisianDelegation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}