import 'dart:io' show Platform; // Import Platform
import 'package:flutter/foundation.dart' show kIsWeb; // To handle web platform
import 'package:flutter/material.dart';
import 'package:nostr_pay_kids/component_library/src/theme/colors.dart';
import 'package:nostr_pay_kids/component_library/src/theme/themes.dart';

class BackButtonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final double elevation;

  const BackButtonAppBar({
    super.key,
    this.onBackPressed,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      automaticallyImplyLeading: false,
      title:
          title != null
              ? Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              )
              : null,
      centerTitle: true,
      leading: showBackButton ? BackButtonIcon(onPressed: onBackPressed) : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BackButtonIcon extends StatelessWidget {
  const BackButtonIcon({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApplePlatform = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: theme.containerTheme.smallWhiteContainer,
        child: Icon(
          isApplePlatform ? Icons.arrow_back_ios_new : Icons.arrow_back,
          color: AppColors.primary,
          size: 18,
        ),
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
