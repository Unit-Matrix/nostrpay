import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';

Flushbar<dynamic> showFlushbar(
  BuildContext context, {
  String? title,
  Widget? icon,
  bool showMainButton = false,
  String? message,
  FlushbarPosition position = FlushbarPosition.BOTTOM,
  Duration? duration,
  Color? backgroundColor,
}) {
  final theme = Theme.of(context);
  final bgColor = backgroundColor ?? AppColors.primary;

  Flushbar<dynamic>? flush;
  flush = Flushbar<dynamic>(
    flushbarPosition: position,
    animationDuration: const Duration(milliseconds: 400),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.all(16),
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],

    // THE FIX IS HERE
    messageText: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 16)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                ],
                Text(
                  message ?? 'Action completed successfully!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (showMainButton) ...[
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => flush!.dismiss(true),
              child: Text(
                'OK',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ensure OK button text is white
                ),
              ),
            ),
          ],
        ],
      ),
    ),
    duration: duration,
  )..show(context);

  return flush;
}

void popFlushbars(BuildContext context) {
  Navigator.popUntil(context, (Route<dynamic> route) {
    return route.settings.name != 'FLUSHBAR_ROUTE_NAME';
  });
}

// Convenience methods for common use cases
void showSuccessFlushbar(
  BuildContext context, {
  String? title,
  String? message,
  Duration? duration,
}) {
  HapticFeedback.lightImpact();
  showFlushbar(
    context,
    title: title,
    message: message,
    backgroundColor: AppColors.success,
    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
    duration: duration ?? const Duration(seconds: 3),
  );
}

void showErrorFlushbar(
  BuildContext context, {
  String? title,
  String? message,
  Duration? duration,
}) {
  HapticFeedback.heavyImpact();
  showFlushbar(
    context,
    title: title,
    message: message,
    backgroundColor: AppColors.error,
    icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
    duration: duration ?? const Duration(seconds: 4),
  );
}

void showInfoFlushbar(
  BuildContext context, {
  String? title,
  String? message,
  Duration? duration,
}) {
  HapticFeedback.lightImpact();
  showFlushbar(
    context,
    title: title,
    message: message,
    backgroundColor: AppColors.accent,
    icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
    duration: duration ?? const Duration(seconds: 3),
  );
}

void showWarningFlushbar(
  BuildContext context, {
  String? title,
  String? message,
  Duration? duration,
}) {
  HapticFeedback.mediumImpact();
  showFlushbar(
    context,
    title: title,
    message: message,
    backgroundColor: AppColors.warning,
    icon: const Icon(
      Icons.warning_amber_outlined,
      color: Colors.white,
      size: 28,
    ),
    duration: duration ?? const Duration(seconds: 4),
  );
}
