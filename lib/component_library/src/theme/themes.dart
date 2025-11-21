import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'sizes.dart';

final ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'ComicNeue',
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
  ),
  textTheme: TextTheme(
    // Main titles - used for screen titles
    headlineLarge: GoogleFonts.fredoka(
      fontSize: 32,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    // Section titles and important text
    headlineMedium: GoogleFonts.fredoka(
      fontSize: 28,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    // Subsection titles
    headlineSmall: GoogleFonts.fredoka(
      fontSize: 24,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    // Card titles and prominent text
    titleLarge: GoogleFonts.fredoka(
      fontSize: 20,
      // color: AppColors.violet,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    // Button text and action labels
    titleMedium: GoogleFonts.quicksand(
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    // Body text for main content
    bodyLarge: GoogleFonts.nunito(
      fontSize: 18,
      color: AppColors.textBody,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
    // Regular body text
    bodyMedium: GoogleFonts.nunito(
      fontSize: 16,
      color: AppColors.textBody,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    // Secondary body text
    bodySmall: GoogleFonts.nunito(
      fontSize: 14,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    ),
    // Caption and small text
    labelMedium: GoogleFonts.nunito(
      fontSize: 12,
      color: AppColors.textSecondary.withValues(alpha: 0.7),
      fontWeight: FontWeight.w500,
    ),
    // Very small text
    labelSmall: GoogleFonts.nunito(
      fontSize: 11,
      color: AppColors.textSecondary.withOpacity(0.7),
      fontWeight: FontWeight.w500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      shadowColor: AppColors.secondary.withOpacity(0.3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingMedium,
        horizontal: AppSizes.paddingLarge,
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.fredoka(
      fontSize: 20,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    // Add this line to fix the status bar icons globally
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // For Android
      statusBarBrightness: Brightness.light, // For iOS
    ),
  ),
  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    ),
    shadowColor: Colors.black.withOpacity(0.04),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.transparent,
    labelStyle: GoogleFonts.nunito(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: GoogleFonts.nunito(
      color: AppColors.textSecondary.withOpacity(0.6),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
  ),
  // Custom container decoration theme
  extensions: [
    _AppContainerTheme(
      whiteContainer: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      smallWhiteContainer: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      actionButtonContainer:
          (Color color) => BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
      primaryButtonContainer:
          (Color color) => BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
    ),
  ],
);

// Custom theme extension for container decorations
class _AppContainerTheme extends ThemeExtension<_AppContainerTheme> {
  final BoxDecoration whiteContainer;
  final BoxDecoration smallWhiteContainer;
  final BoxDecoration Function(Color) actionButtonContainer;
  final BoxDecoration Function(Color) primaryButtonContainer;

  const _AppContainerTheme({
    required this.whiteContainer,
    required this.smallWhiteContainer,
    required this.actionButtonContainer,
    required this.primaryButtonContainer,
  });

  @override
  _AppContainerTheme copyWith({
    BoxDecoration? whiteContainer,
    BoxDecoration? smallWhiteContainer,
    BoxDecoration Function(Color)? actionButtonContainer,
    BoxDecoration Function(Color)? primaryButtonContainer,
  }) {
    return _AppContainerTheme(
      whiteContainer: whiteContainer ?? this.whiteContainer,
      smallWhiteContainer: smallWhiteContainer ?? this.smallWhiteContainer,
      actionButtonContainer:
          actionButtonContainer ?? this.actionButtonContainer,
      primaryButtonContainer:
          primaryButtonContainer ?? this.primaryButtonContainer,
    );
  }

  @override
  _AppContainerTheme lerp(ThemeExtension<_AppContainerTheme>? other, double t) {
    if (other is! _AppContainerTheme) {
      return this;
    }
    return this;
  }
}

// Helper extension to access the custom container theme
extension AppContainerThemeExtension on ThemeData {
  _AppContainerTheme get containerTheme =>
      extension<_AppContainerTheme>() ??
      const _AppContainerTheme(
        whiteContainer: BoxDecoration(),
        smallWhiteContainer: BoxDecoration(),
        actionButtonContainer: _defaultActionButtonContainer,
        primaryButtonContainer: _defaultPrimaryButtonContainer,
      );
}

BoxDecoration _defaultActionButtonContainer(Color color) => BoxDecoration();
BoxDecoration _defaultPrimaryButtonContainer(Color color) => BoxDecoration();
