import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';

enum PaymentType { send, receive }

class PaymentSuccessModal extends StatefulWidget {
  final int amount;
  final PaymentType type;

  const PaymentSuccessModal({
    super.key,
    required this.amount,
    required this.type,
  });

  @override
  State<PaymentSuccessModal> createState() => _PaymentSuccessModalState();
}

class _PaymentSuccessModalState extends State<PaymentSuccessModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ), // Slightly longer for staggered effect
    );

    // Mascot animation (first 75% of the time)
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
    );

    // Text animation (starts midway through)
    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9),
    );

    // Button animation (starts near the end)
    _buttonFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAwesomePressed() {
    Navigator.of(context).popUntil((route) => route.settings.name == '/');
  }

  String _getMascotAsset() {
    return widget.type == PaymentType.send
        ? 'assets/mascot/rockstar-dev.svg'
        : 'assets/mascot/acrobat.svg';
  }

  String _getSuccessMessage() {
    return widget.type == PaymentType.send
        ? 'Payment successful! You sent ${widget.amount} sats!'
        : 'Yay! You got ${widget.amount} sats!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Mascot
            ScaleTransition(
              scale: _scaleAnimation,
              child: SvgPicture.asset(
                _getMascotAsset(),
                width: 200,
                height: 200,
              ),
            ),

            const SizedBox(height: 24),

            // Fading Text and Button
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Text(
                _getSuccessMessage(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _buttonFadeAnimation,
              child: PrimaryButton(
                onPressed: _onAwesomePressed,
                text: 'Awesome!',
                backgroundColor: AppColors.success,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
