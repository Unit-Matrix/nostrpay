import 'dart:convert';
import 'user_avatar.dart';

class UserProfileState {
  final String name;
  final UserAvatar selectedAvatar;

  UserProfileState({required this.name, required this.selectedAvatar});

  factory UserProfileState.initial() {
    return UserProfileState(
      name: 'Satoshi',
      selectedAvatar: UserAvatar.satoshi,
    );
  }

  UserProfileState copyWith({String? name, UserAvatar? selectedAvatar}) {
    return UserProfileState(
      name: name ?? this.name,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'selectedAvatarIndex': selectedAvatar.avatarIndex,
    };
  }

  factory UserProfileState.fromJson(Map<String, dynamic> json) {
    final avatarIndex = json['selectedAvatarIndex'] as int? ?? 0;
    return UserProfileState(
      name: json['name'] as String? ?? 'Satoshi',
      selectedAvatar: UserAvatar.fromIndex(avatarIndex),
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
