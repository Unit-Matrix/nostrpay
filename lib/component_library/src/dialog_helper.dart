import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';

/// Shows a dialog with customizable title, message, icon, and actions.
/// This is useful for errors or messages that need more space and should remain
/// visible until the user explicitly dismisses them.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  Widget? icon,
  Color? backgroundColor,
  List<Widget>? actions,
  bool barrierDismissible = true,
  EdgeInsetsGeometry? contentPadding,
}) {
  final theme = Theme.of(context);
  final bgColor = backgroundColor ?? AppColors.surface;

  HapticFeedback.mediumImpact();

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: bgColor,
      title: title != null
          ? Row(
              children: [
                if (icon != null) ...[
                  icon,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            )
          : null,
      content: message != null
          ? Padding(
              padding: contentPadding ?? EdgeInsets.zero,
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            )
          : null,
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
    ),
  );
}

// Convenience methods for common use cases

/// Shows an error dialog with a red error icon.
/// Use this for errors that need more space and should remain visible.
Future<T?> showErrorDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  List<Widget>? actions,
  bool barrierDismissible = true,
  VoidCallback? onDismiss,
}) {
  HapticFeedback.heavyImpact();

  final defaultActions = actions ??
      [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
      ];

  return showAppDialog<T>(
    context,
    title: title ?? 'Error',
    message: message,
    icon: const Icon(
      Icons.error_outline,
      color: AppColors.error,
      size: 28,
    ),
    actions: defaultActions,
    barrierDismissible: barrierDismissible,
  );
}

/// Shows a success dialog with a green success icon.
/// Use this for success messages that need more space and should remain visible.
Future<T?> showSuccessDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  List<Widget>? actions,
  bool barrierDismissible = true,
  VoidCallback? onDismiss,
}) {
  HapticFeedback.lightImpact();

  final defaultActions = actions ??
      [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
      ];

  return showAppDialog<T>(
    context,
    title: title ?? 'Success',
    message: message,
    icon: const Icon(
      Icons.check_circle_outline,
      color: AppColors.success,
      size: 28,
    ),
    actions: defaultActions,
    barrierDismissible: barrierDismissible,
  );
}

/// Shows an info dialog with a blue info icon.
/// Use this for informational messages that need more space and should remain visible.
Future<T?> showInfoDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  List<Widget>? actions,
  bool barrierDismissible = true,
  VoidCallback? onDismiss,
}) {
  HapticFeedback.lightImpact();

  final defaultActions = actions ??
      [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
      ];

  return showAppDialog<T>(
    context,
    title: title ?? 'Info',
    message: message,
    icon: const Icon(
      Icons.info_outline,
      color: AppColors.accent,
      size: 28,
    ),
    actions: defaultActions,
    barrierDismissible: barrierDismissible,
  );
}

/// Shows a warning dialog with an orange warning icon.
/// Use this for warning messages that need more space and should remain visible.
Future<T?> showWarningDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  List<Widget>? actions,
  bool barrierDismissible = true,
  VoidCallback? onDismiss,
}) {
  HapticFeedback.mediumImpact();

  final defaultActions = actions ??
      [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
      ];

  return showAppDialog<T>(
    context,
    title: title ?? 'Warning',
    message: message,
    icon: const Icon(
      Icons.warning_amber_outlined,
      color: AppColors.warning,
      size: 28,
    ),
    actions: defaultActions,
    barrierDismissible: barrierDismissible,
  );
}

/// Shows a confirmation dialog with customizable actions.
/// Use this when you need user confirmation before proceeding.
Future<T?> showConfirmationDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color? confirmColor,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
}) {
  HapticFeedback.mediumImpact();

  final theme = Theme.of(context);
  final confirmBtnColor = confirmColor ?? AppColors.primary;

  return showAppDialog<T>(
    context,
    title: title ?? 'Confirm',
    message: message,
    icon: const Icon(
      Icons.help_outline,
      color: AppColors.accent,
      size: 28,
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          onCancel?.call();
        },
        child: Text(
          cancelText,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          onConfirm?.call();
        },
        child: Text(
          confirmText,
          style: theme.textTheme.titleMedium?.copyWith(
            color: confirmBtnColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
    barrierDismissible: barrierDismissible,
  );
}
