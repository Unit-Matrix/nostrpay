import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';

import 'send_code_entry_screen.dart';

class SendIntroScreen extends StatelessWidget {
  const SendIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppPageScaffold(
      title: 'Send Sats',
      centerTitle: true,
      body: Column(
        children: [
          const SizedBox(height: 32),

          // Mascot
          SizedBox(
            width: 200,
            height: 200,
            child: SvgPicture.asset('assets/mascot/Nostrich.svg'),
          ),

          const SizedBox(height: 40),

          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: theme.containerTheme.whiteContainer,
            child: Column(
              children: [
                Text(
                  'Want to send sats to someone?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  "Let's use their special code to send them sats safely!",
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
          text: "Let's Get Their Code!",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendCodeEntryScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
