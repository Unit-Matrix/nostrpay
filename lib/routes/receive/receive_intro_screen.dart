import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/routes/receive/receive_amount_screen.dart';

class ReceiveIntroScreen extends StatelessWidget {
  const ReceiveIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final containerTheme = theme.containerTheme;

    return AppPageScaffold(
      title: 'Receive Sats',
      centerTitle: true,
      body: Column(
        children: [
          const SizedBox(height: 32),

          // Mascot
          SizedBox(
            width: 200,
            height: 200,
            child: SvgPicture.asset('assets/mascot/UFO.svg'),
          ),

          const SizedBox(height: 40),

          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: containerTheme.whiteContainer,
            child: Column(
              children: [
                Text(
                  'Want to get sats from someone?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  "Let's make a magic code they can scan to send you sats!",
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),

      footer: Padding(
        padding: const EdgeInsets.all(24),
        child: PrimaryButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReceiveAmountScreen(),
              ),
            );
          },
          text: "Let's Create a Code!",
          backgroundColor: AppColors.accent,
        ),
      ),
    );
  }
}
