import 'package:flutter/material.dart' hide BackButtonIcon;
import 'package:nostr_pay_kids/component_library/src/theme/colors.dart';

import 'back_button_app_bar.dart';

class AppPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final Widget? footer; // NEW: Add the footer parameter
  final bool centerTitle; // Simplified the name

  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onRefresh,
    this.footer,
    this.centerTitle = false, // Default to the collapsing style
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scrollView = CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 120.0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: true,
          leading: BackButtonIcon(),
          actions: actions,
          centerTitle: centerTitle,
          flexibleSpace: FlexibleSpaceBar(
            // Use a ternary operator to switch between padding styles
            titlePadding:
                centerTitle
                    ? const EdgeInsets.only(
                      bottom: 16,
                    ) // Padding for centered title
                    : const EdgeInsetsDirectional.only(
                      start: 72.0,
                      bottom: 16.0,
                    ), // Padding for left-aligned title
            // Use the boolean to set the alignment
            centerTitle: centerTitle,
            title: Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 18),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: body, // The unique content for each screen goes here.
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body:
          onRefresh != null
              ? RefreshIndicator(
                onRefresh: onRefresh!,
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: scrollView,
              )
              : scrollView,
      bottomNavigationBar: footer != null ? SafeArea(child: footer!) : null,
    );
  }
}
