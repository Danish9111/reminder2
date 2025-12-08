import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';

/// A customizable button widget that can be used throughout the app.
///
/// Supports multiple variants: primary, secondary, outline, and text.
/// Can show loading state, icons, and be fully customized.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  // Primary filled button
  const CustomButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.primary,
       borderColor = null;

  // Secondary filled button (lighter)
  const CustomButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.secondary,
       borderColor = null;

  // Outline button
  const CustomButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderRadius,
    this.borderColor,
    this.textColor,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.outline,
       backgroundColor = null;

  // Text only button
  const CustomButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.textColor,
    this.size = ButtonSize.medium,
  }) : variant = ButtonVariant.text,
       borderRadius = null,
       backgroundColor = null,
       borderColor = null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 50;
      case ButtonSize.large:
        return 58;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 18;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  Widget _buildButton() {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton();
      case ButtonVariant.secondary:
        return _buildSecondaryButton();
      case ButtonVariant.outline:
        return _buildOutlineButton();
      case ButtonVariant.text:
        return _buildTextButton();
    }
  }

  Widget _buildPrimaryButton() {
    final bgColor = backgroundColor ?? AppColors.primaryColor;
    final txtColor = textColor ?? Colors.white;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: txtColor,
        disabledBackgroundColor: bgColor.withOpacity(0.6),
        disabledForegroundColor: txtColor.withOpacity(0.6),
        elevation: 2,
        shadowColor: bgColor.withOpacity(0.4),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      child: _buildButtonContent(txtColor),
    );
  }

  Widget _buildSecondaryButton() {
    final bgColor = backgroundColor ?? AppColors.primaryColor.withOpacity(0.12);
    final txtColor = textColor ?? AppColors.primaryColor;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: txtColor,
        disabledBackgroundColor: bgColor.withOpacity(0.6),
        disabledForegroundColor: txtColor.withOpacity(0.6),
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      child: _buildButtonContent(txtColor),
    );
  }

  Widget _buildOutlineButton() {
    final bdrColor = borderColor ?? AppColors.primaryColor;
    final txtColor = textColor ?? AppColors.primaryColor;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: txtColor,
        side: BorderSide(color: bdrColor, width: 1.5),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      child: _buildButtonContent(txtColor),
    );
  }

  Widget _buildTextButton() {
    final txtColor = textColor ?? AppColors.primaryColor;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: txtColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
      ),
      child: _buildButtonContent(txtColor),
    );
  }

  Widget _buildButtonContent(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    final List<Widget> children = [];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
      children.add(const SizedBox(width: 8));
    }

    children.add(
      Text(
        text,
        style: TextStyle(fontSize: _getFontSize(), fontWeight: FontWeight.w600),
      ),
    );

    if (suffixIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(Icon(suffixIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

/// Button style variants
enum ButtonVariant {
  primary, // Filled with primary color
  secondary, // Light fill with primary text
  outline, // Border only
  text, // Text only, no background
}

/// Button size options
enum ButtonSize { small, medium, large }
