import 'package:flutter/material.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool enabled;
  final double? fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.isLoading = false,
    this.width,
    this.height = 60,
    this.padding,
    this.borderRadius,
    this.icon,
    this.enabled = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = backgroundColor ?? AppColors.secondary;
    final isButtonEnabled = enabled && onPressed != null && !isLoading;
    final effectiveColor = isButtonEnabled ? buttonColor : Colors.grey.shade300;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      width: width,
      height: height,
      decoration:
          isButtonEnabled
              // On iOS, use a flatter decoration
              ? (isIOS
                  ? BoxDecoration(
                    color: effectiveColor,
                    borderRadius: borderRadius ?? BorderRadius.circular(20),
                  )
                  // On other platforms, use your cool container theme with shadow
                  : theme.containerTheme.primaryButtonContainer(effectiveColor))
              : BoxDecoration(
                // Disabled style remains the same
                color: effectiveColor,
                borderRadius: borderRadius ?? BorderRadius.circular(20),
              ),
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(20),
          ),
          padding: padding,
        ),
        child: _buildButtonContent(theme),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    final textStyle =
        fontSize != null
            ? theme.textTheme.titleMedium?.copyWith(
              height: 1.0,
              fontSize: fontSize,
            )
            : theme.textTheme.titleMedium?.copyWith(height: 1.0);

    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text('Loading...', style: textStyle),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }

    return Center(
      child: Text(text, style: textStyle, textAlign: TextAlign.center),
    );
  }
}
