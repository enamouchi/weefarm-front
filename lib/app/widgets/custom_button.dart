import 'package:flutter/material.dart';
import '../core/values/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final double elevation;
  final Color? shadowColor;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final ButtonType type;
  
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.elevation = 0,
    this.shadowColor,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.textStyle,
    this.type = ButtonType.elevated,
  }) : super(key: key);
  
  // Factory constructors for common button types
  factory CustomButton.primary({
    required String text,
    VoidCallback? onPressed,
    double? width,
    double? height,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.primaryGreen,
      textColor: AppColors.white,
      width: width,
      height: height,
      elevation: 2,
      shadowColor: AppColors.primaryGreen.withOpacity(0.3),
      isLoading: isLoading,
      icon: icon,
      type: ButtonType.elevated,
    );
  }
  
  factory CustomButton.secondary({
    required String text,
    VoidCallback? onPressed,
    double? width,
    double? height,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.accentTeal,
      textColor: AppColors.white,
      width: width,
      height: height,
      elevation: 2,
      shadowColor: AppColors.accentTeal.withOpacity(0.3),
      isLoading: isLoading,
      icon: icon,
      type: ButtonType.elevated,
    );
  }
  
  factory CustomButton.outline({
    required String text,
    VoidCallback? onPressed,
    Color? borderColor,
    Color? textColor,
    double? width,
    double? height,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? AppColors.primaryGreen,
      borderColor: borderColor ?? AppColors.primaryGreen,
      width: width,
      height: height,
      isLoading: isLoading,
      icon: icon,
      type: ButtonType.outlined,
    );
  }
  
  factory CustomButton.text({
    required String text,
    VoidCallback? onPressed,
    Color? textColor,
    bool isLoading = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? AppColors.primaryGreen,
      elevation: 0,
      isLoading: isLoading,
      icon: icon,
      type: ButtonType.text,
    );
  }
  
  factory CustomButton.danger({
    required String text,
    VoidCallback? onPressed,
    double? width,
    double? height,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.error,
      textColor: AppColors.white,
      width: width,
      height: height,
      elevation: 2,
      shadowColor: AppColors.error.withOpacity(0.3),
      isLoading: isLoading,
      type: ButtonType.elevated,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonChild = _buildButtonContent(theme);
    
    switch (type) {
      case ButtonType.elevated:
        return _buildElevatedButton(buttonChild);
      case ButtonType.outlined:
        return _buildOutlinedButton(buttonChild);
      case ButtonType.text:
        return _buildTextButton(buttonChild);
    }
  }
  
  Widget _buildButtonContent(ThemeData theme) {
    final textWidget = Text(
      text,
      style: textStyle ?? theme.textTheme.labelLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
    
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          textWidget,
        ],
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 12),
          textWidget,
        ],
      );
    }
    
    return textWidget;
  }
  
  Widget _buildElevatedButton(Widget child) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryGreen,
          foregroundColor: textColor ?? AppColors.white,
          elevation: elevation,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null 
                ? BorderSide(color: borderColor!, width: 1.5)
                : BorderSide.none,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: child,
      ),
    );
  }
  
  Widget _buildOutlinedButton(Widget child) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryGreen,
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: borderColor ?? AppColors.primaryGreen,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: child,
      ),
    );
  }
  
  Widget _buildTextButton(Widget child) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryGreen,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: child,
      ),
    );
  }
  
}

enum ButtonType {
  elevated,
  outlined,
  text,
}

// Specialized button widgets for common use cases
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double size;
  
  const ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.size = 60,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? AppColors.primaryGreen).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.white,
                  size: size * 0.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor ?? AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class FloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  final double size;
  final bool mini;
  
  const FloatingActionButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
    this.size = 56,
    this.mini = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final actualSize = mini ? size * 0.75 : size;
    
    return Container(
      width: actualSize,
      height: actualSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(actualSize / 2),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primaryGreen).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(actualSize / 2),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? AppColors.white,
              size: mini ? 20 : 24,
            ),
          ),
        ),
      ),
    );
  }
}

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final bool isVertical;
  final double spacing;
  
  const IconTextButton({
    Key? key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.isVertical = false,
    this.spacing = 8,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      color: iconColor ?? AppColors.primaryGreen,
      size: 20,
    );
    
    final textWidget = Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: textColor ?? AppColors.primaryGreen,
        fontWeight: FontWeight.w500,
      ),
    );
    
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: isVertical
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconWidget,
                    SizedBox(height: spacing),
                    textWidget,
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconWidget,
                    SizedBox(width: spacing),
                    textWidget,
                  ],
                ),
        ),
      ),
    );
  }
}

class SegmentedButton extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  
  const SegmentedButton({
    Key? key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unselectedColor ?? AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = index == selectedIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (selectedColor ?? AppColors.primaryGreen)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? (selectedTextColor ?? AppColors.white)
                        : (unselectedTextColor ?? AppColors.darkGray),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}