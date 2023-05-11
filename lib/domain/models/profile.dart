import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required String name,
    required String url,
    Duration? updateInterval,
    required DateTime lastUpdate,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
