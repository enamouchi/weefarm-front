// lib/app/widgets/custom_search_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.controller,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: AppColors.mediumGray),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.mediumGray,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  onPressed: _clearText,
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.mediumGray,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}