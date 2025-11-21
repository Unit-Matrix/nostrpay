import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';

import 'user_avatar.dart';
import 'user_profile_state.dart';

final Logger _logger = Logger('UserProfileCubit');

class UserProfileCubit extends Cubit<UserProfileState>
    with HydratedMixin<UserProfileState> {
  UserProfileCubit() : super(UserProfileState.initial()) {
    hydrate();
  }

  void saveUserProfile({
    required String name,
    required UserAvatar selectedAvatar,
  }) {
    _logger.info(
      'Saving user profile: name=$name, avatar=${selectedAvatar.name}',
    );

    if (name.trim().isEmpty) {
      _logger.warning('Attempted to save empty name');
      return;
    }

    if (name.length < 2) {
      _logger.warning('Name too short: ${name.length} characters');
      return;
    }

    if (name.length > 20) {
      _logger.warning('Name too long: ${name.length} characters');
      return;
    }

    emit(state.copyWith(name: name.trim(), selectedAvatar: selectedAvatar));
  }

  void skipOnboarding() {
    _logger.info('User skipped onboarding - using default values');
    // No need to emit anything since we already have default values
  }

  void updateAvatar(UserAvatar selectedAvatar) {
    _logger.info('Updating avatar to: ${selectedAvatar.name}');
    emit(state.copyWith(selectedAvatar: selectedAvatar));
  }

  void clearProfile() {
    _logger.info('Clearing user profile');
    emit(UserProfileState.initial());
  }

  @override
  UserProfileState? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      _logger.severe('No stored user profile data found.');
      return null;
    }

    try {
      final UserProfileState result = UserProfileState.fromJson(json);
      _logger.fine('Successfully hydrated user profile with $result');
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Error hydrating user profile: $e');
      _logger.fine('Stack trace: $stackTrace');
      return UserProfileState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(UserProfileState state) {
    try {
      final Map<String, dynamic> result = state.toJson();
      _logger.fine('Serialized user profile: $result');
      return result;
    } catch (e) {
      _logger.severe('Error serializing user profile: $e');
      return null;
    }
  }
}
