// lib/app/widgets/phone_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final bool isRequired;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const PhoneInputField({
    Key? key,
    required this.controller,
    this.label,
    this.hintText,
    this.isRequired = true,
    this.onChanged,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Get.textTheme.labelLarge?.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _TunisianPhoneFormatter(),
          ],
          decoration: InputDecoration(
            hintText: widget.hintText ?? '+216 XX XXX XXX',
            hintStyle: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.mediumGray,
            ),
            prefixIcon: const Icon(
              Icons.phone,
              color: AppColors.primaryGreen,
            ),
            filled: true,
            fillColor: widget.enabled ? AppColors.white : AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGray),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: widget.validator ?? _defaultValidator,
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
        ),
      ],
    );
  }

  String? _defaultValidator(String? value) {
    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return 'phone_required'.tr;
    }
    
    if (value != null && value.isNotEmpty) {
      final cleaned = value.replaceAll(RegExp(r'\D'), '');
      String phoneNumber = cleaned;
      
      // Remove country code if present
      if (phoneNumber.startsWith('216')) {
        phoneNumber = phoneNumber.substring(3);
      }
      
      // Validate Tunisian phone format
      if (!RegExp(r'^[23459][0-9]{7}$').hasMatch(phoneNumber)) {
        return 'invalid_phone_format'.tr;
      }
    }
    
    return null;
  }
}

class _TunisianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    
    // Remove all non-digits
    String digitsOnly = newText.replaceAll(RegExp(r'\D'), '');
    
    // Remove 216 prefix if user tries to type it
    if (digitsOnly.startsWith('216')) {
      digitsOnly = digitsOnly.substring(3);
    }
    
    // Limit to 8 digits for Tunisian numbers
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }
    
    // Format as +216 XX XXX XXX
    String formatted = '+216';
    
    if (digitsOnly.isNotEmpty) {
      formatted += ' ';
      
      if (digitsOnly.length >= 2) {
        formatted += '${digitsOnly.substring(0, 2)}';
        
        if (digitsOnly.length >= 3) {
          formatted += ' ${digitsOnly.substring(2, digitsOnly.length >= 5 ? 5 : digitsOnly.length)}';
          
          if (digitsOnly.length >= 6) {
            formatted += ' ${digitsOnly.substring(5)}';
          }
        }
      } else {
        formatted += digitsOnly;
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Extension to get clean phone number for API
extension PhoneExtension on TextEditingController {
  /// Returns the phone number cleaned for API (8 digits only, no country code)
  String get cleanPhoneNumber {
    String cleaned = text.replaceAll(RegExp(r'\D'), '');
    
    // Remove Tunisia country code if present
    if (cleaned.startsWith('216')) {
      cleaned = cleaned.substring(3);
    }
    
    return cleaned;
  }
  
  /// Check if the current phone number is valid for Tunisia
  bool get isValidTunisianPhone {
    final cleaned = cleanPhoneNumber;
    return RegExp(r'^[23459][0-9]{7}$').hasMatch(cleaned);
  }
  
  /// Get formatted display version of phone number
  String get formattedPhoneNumber {
    final cleaned = cleanPhoneNumber;
    if (cleaned.length == 8) {
      return '+216 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
    }
    return text;
  }
}