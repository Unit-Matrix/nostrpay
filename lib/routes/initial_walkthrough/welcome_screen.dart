import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';

import 'explanation_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Welcome haptic feedback when screen loads
    HapticFeedback.lightImpact();
  }

  void _onMascotTap() {
    // Playful haptic feedback when mascot is tapped
    HapticFeedback.mediumImpact();
  }

  void _onStartButtonPressed() {
    // Strong haptic feedback for the main action
    HapticFeedback.heavyImpact();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FlyingTransitionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive sizes based on screen height
    final availableHeight = screenHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        48; // 48 for padding

    final mascotSize = (availableHeight * 0.35).clamp(180.0, 300.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              AppColors.background,
            ], // Example gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 2), // Add space at the top
                // Mascot container - responsive size with haptic feedback
                GestureDetector(
                  onTap: _onMascotTap,
                  child: SizedBox(
                    width: mascotSize,
                    height: mascotSize,
                    child: SvgPicture.asset('assets/mascot/Robe.svg'),
                  ),
                ),

                const SizedBox(height: 24),

                // Welcome message
                Text(
                  'Welcome to Nostrpay\nkids wallet!',
                  style: theme.textTheme.headlineLarge?.copyWith(height: 1.2),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Subtitle container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: theme.containerTheme.whiteContainer,
                  child: Text(
                    "Let's get your wallet ready to explore, save, and spend sats! 🚀💰",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(
                  flex: 3,
                ), // More flexible space to push the button down
                // Continue button - using theme with haptic feedback
                PrimaryButton(
                  text: "Let's Start!",
                  onPressed: _onStartButtonPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlyingTransitionScreen extends StatefulWidget {
  const FlyingTransitionScreen({super.key});

  @override
  State<FlyingTransitionScreen> createState() => _FlyingTransitionScreenState();
}

class _FlyingTransitionScreenState extends State<FlyingTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _mascotController;
  late AnimationController _shakeController;
  late Animation<Offset> _mascotAnimation;
  late Animation<double> _mascotScaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Mascot animation controller
    _mascotController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Shake animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Mascot flying animation - from bottom to top
    _mascotAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5), // Start from below screen
      end: const Offset(0, -1.3), // Fly to above screen
    ).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    // Mascot scale animation - grow as it flies
    _mascotScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    // Background color animation - transition to UFO glow color
    _backgroundAnimation = ColorTween(
      begin: AppColors.background,
      end: AppColors.ufoBeamColor, // UFO glow color
    ).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    // Replace your shake animation with a deterministic one
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: -15.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Initial haptic feedback when animation starts
    HapticFeedback.lightImpact();

    _mascotController.forward();

    // Start shake animation when UFO reaches the top
    _mascotController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        // Chain the navigation to the completion of the shake
        _shakeController.forward().whenComplete(() {
          if (mounted) {
            HapticFeedback.mediumImpact();
            // Use pushReplacement to prevent going back to this screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ExplanationScreen(),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundAnimation.value,
          body: Center(
            child: SlideTransition(
              position: _mascotAnimation,
              child: ScaleTransition(
                scale: _mascotScaleAnimation,
                child: AnimatedBuilder(
                  animation:
                      _shakeAnimation, // Listen to the new shake animation
                  builder: (context, child) {
                    return Transform.translate(
                      // Use the deterministic animation value
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    // The child is now static, which is more efficient
                    width: 200,
                    height: 200,
                    child: SvgPicture.asset('assets/mascot/UFO.svg'),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
