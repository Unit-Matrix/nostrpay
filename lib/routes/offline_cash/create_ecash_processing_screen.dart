import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_cubit.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_state.dart';
import 'create_ecash_success_screen.dart';

class CreateEcashProcessingScreen extends StatefulWidget {
  const CreateEcashProcessingScreen({super.key});

  @override
  State<CreateEcashProcessingScreen> createState() =>
      _CreateEcashProcessingScreenState();
}

class _CreateEcashProcessingScreenState
    extends State<CreateEcashProcessingScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Float animation controller - smooth floating motion
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Float animation - smooth up and down movement
    _floatAnimation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // Start creating Ecash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcashCubit>().createEcash(amountSats: 21);
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  String _getMessage(EcashMintingState state) {
    return switch (state) {
      EcashMintingStateIdle() => 'Preparing...',
      EcashMintingStateUnpaid() => 'Paying invoice...',
      EcashMintingStatePaid() => 'Creating your Ecash...',
      EcashMintingStateIssued() => 'Almost done...',
      EcashMintingStateError(:final error) => 'Error: $error',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<EcashCubit, EcashState>(
      listener: (context, state) {
        // Navigate to success when issued
        if (state.mintingState is EcashMintingStateIssued) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEcashSuccessScreen(),
            ),
          );
        }
        // Show error dialog if error occurs
        if (state.mintingState is EcashMintingStateError) {
          final errorState = state.mintingState as EcashMintingStateError;
          showErrorDialog(
            context,
            message: errorState.error,
            onDismiss: () {
              Navigator.pop(context); // Go back to confirmation
            },
          );
        }
      },
      child: BlocBuilder<EcashCubit, EcashState>(
        builder: (context, state) {
          final message = _getMessage(state.mintingState);
          final isError = state.mintingState is EcashMintingStateError;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Floating mascot - centered
                    Center(
                      child: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: SizedBox(
                              width: 240,
                              height: 240,
                              child: SvgPicture.asset(
                                isError
                                    ? 'assets/mascot/Pyro.svg'
                                    : 'assets/mascot/Astronaut.svg',
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Processing message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        message,
                        key: ValueKey(message),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isError ? AppColors.error : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Progress indicator (hide on error)
                    if (!isError)
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.success),
                        strokeWidth: 4,
                      ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
