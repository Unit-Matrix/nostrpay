import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/user_profile/user_avatar.dart';
import 'package:nostr_pay_kids/cubit/user_profile/user_profile_cubit.dart';

class NamePromptScreen extends StatefulWidget {
  const NamePromptScreen({super.key});

  @override
  State<NamePromptScreen> createState() => _NamePromptScreenState();
}

class _NamePromptScreenState extends State<NamePromptScreen> {
  final TextEditingController _nameController = TextEditingController();
  UserAvatar selectedAvatar = UserAvatar.satoshi;

  @override
  void initState() {
    super.initState();
    // Initialize with stored values if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfileState = context.read<UserProfileCubit>().state;
      _nameController.text = userProfileState.name;
      setState(() {
        selectedAvatar = userProfileState.selectedAvatar;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  final List<UserAvatar> avatars = UserAvatar.values;

  void _saveName() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter your name first!', isSuccess: false);
      return;
    }

    if (name.length < 2) {
      _showSnackBar('Name should be at least 2 characters!', isSuccess: false);
      return;
    }

    if (name.length > 20) {
      _showSnackBar(
        'Name should be less than 20 characters!',
        isSuccess: false,
      );
      return;
    }

    // Save name and avatar to storage using UserProfileCubit
    context.read<UserProfileCubit>().saveUserProfile(
      name: name,
      selectedAvatar: selectedAvatar,
    );

    _navigateToMainApp();
  }

  void _skipForNow() {
    // Mark onboarding as complete without saving name
    context.read<UserProfileCubit>().skipOnboarding();
    _navigateToMainApp();
  }

  void _navigateToMainApp() {
    // Navigate to main app
    Navigator.pushReplacementNamed(context, '/');
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    if (isSuccess) {
      showSuccessFlushbar(context, message: message);
    } else {
      showErrorFlushbar(context, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48, // 48 for padding
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // Title
                  Text(
                    "What's your name?",
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Friendly mascot
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      selectedAvatar.assetPath,
                      width: 160,
                      height: 160,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Friendly message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: theme.containerTheme.whiteContainer,
                    child: Text(
                      "I want to greet you every time you open the app!",
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Name input
                  Container(
                    decoration: theme.containerTheme.smallWhiteContainer,
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'Enter your name here...',
                        labelStyle: theme.textTheme.bodySmall,
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.all(20),
                        suffixIcon:
                            _nameController.text.isNotEmpty
                                ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _nameController.clear();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                                : null,
                      ),
                      onChanged: (value) {
                        setState(() {}); // Rebuild to show/hide clear button
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Avatar selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick your avatar:',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 80,
                        decoration: theme.containerTheme.smallWhiteContainer,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: avatars.length,
                          itemBuilder: (context, index) {
                            final avatar = avatars[index];
                            final isSelected = selectedAvatar == avatar;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAvatar = avatar;
                                });
                                // Update avatar in cubit
                                context.read<UserProfileCubit>().updateAvatar(
                                  avatar,
                                );
                              },
                              child: Container(
                                width: 60,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    avatar.assetPath,
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Column(
                    children: [
                      // Save button
                      PrimaryButton(
                        text: 'Save My Name!',
                        onPressed:
                            _nameController.text.trim().isNotEmpty
                                ? _saveName
                                : null,
                        enabled: _nameController.text.trim().isNotEmpty,
                      ),

                      const SizedBox(height: 16),

                      // Skip button
                      InkWell(
                        onTap: _skipForNow,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "I'll tell you later",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
