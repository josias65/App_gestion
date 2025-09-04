import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final double? elevation;
  final BorderSide? borderSide;
  final bool isOutlined;
  final bool isDense;
  final TextStyle? textStyle;
  final bool enabled;
  final Color? disabledColor;
  final Color? disabledTextColor;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.icon,
    this.elevation,
    this.borderSide,
    this.isOutlined = false,
    this.isDense = false,
    this.textStyle,
    this.enabled = true,
    this.disabledColor,
    this.disabledTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    final buttonTextColor = textColor ?? theme.colorScheme.onPrimary;
    final disabledButtonColor = disabledColor ?? theme.disabledColor;
    final disabledButtonTextColor = disabledTextColor ?? theme.colorScheme.onSurface.withOpacity(0.38);

    final buttonChild = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon as Widget, const SizedBox(width: 8)],
              Text(
                text,
                style: textStyle?.copyWith(
                      color: enabled ? buttonTextColor : disabledButtonTextColor,
                    ) ??
                    theme.textTheme.labelLarge?.copyWith(
                      color: enabled ? buttonTextColor : disabledButtonTextColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          );

    final buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return disabledButtonColor;
          }
          return isOutlined ? Colors.transparent : buttonColor;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return disabledButtonTextColor;
          }
          return isOutlined ? buttonColor : buttonTextColor;
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return (isOutlined ? buttonColor.withOpacity(0.1) : buttonColor.withOpacity(0.8));
          } else if (states.contains(MaterialState.hovered)) {
            return (isOutlined ? buttonColor.withOpacity(0.08) : buttonColor.withOpacity(0.9));
          }
          return Colors.transparent;
        },
      ),
      side: MaterialStateProperty.resolveWith<BorderSide>(
        (Set<MaterialState> states) {
          if (isOutlined) {
            return borderSide ??
                BorderSide(
                  color: enabled ? buttonColor : disabledButtonColor,
                  width: 1.0,
                );
          }
          return BorderSide.none;
        },
      ),
      elevation: MaterialStateProperty.all<double>(elevation ?? (isOutlined ? 0 : 2)),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        padding ??
            EdgeInsets.symmetric(
              horizontal: isDense ? 16 : 24,
              vertical: isDense ? 8 : 12,
            ),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        Size(
          width ?? (isFullWidth ? double.infinity : 0),
          height ?? (isDense ? 36 : 48),
        ),
      ),
    );

    return ElevatedButton(
      onPressed: enabled && !isLoading ? onPressed : null,
      style: buttonStyle,
      child: buttonChild,
    );
  }
}
