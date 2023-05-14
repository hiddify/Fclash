import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_connection.freezed.dart';
part 'clash_connection.g.dart';

// TODO: implement connection items

@freezed
class ClashConnection with _$ClashConnection {
  const ClashConnection._();

  const factory ClashConnection({
    @JsonKey(name: 'uploadTotal') @Default(0) int totalUpload,
    @JsonKey(name: 'downloadTotal') @Default(0) int totalDownload,
    @Default([]) List<ClashConnectionItem> connections,
  }) = _ClashConnection;

  factory ClashConnection.fromJson(Map<String, dynamic> json) =>
      _$ClashConnectionFromJson(json);
}

@freezed
class ClashConnectionItem with _$ClashConnectionItem {
  const ClashConnectionItem._();

  const factory ClashConnectionItem({
    required String id,
    required int upload,
    required int download,
    required String start,
    required List<String> chains,
    required String rule,
    required String rulePayload,
  }) = _ClashConnectionItem;

  factory ClashConnectionItem.fromJson(Map<String, dynamic> json) =>
      _$ClashConnectionItemFromJson(json);
}
