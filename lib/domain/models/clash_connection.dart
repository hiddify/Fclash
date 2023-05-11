import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_connection.freezed.dart';
part 'clash_connection.g.dart';

// TODO: implement connection items

@freezed
class ClashConnection with _$ClashConnection {
  const ClashConnection._();

  const factory ClashConnection({
    @JsonKey(name: 'uploadTotal') @Default(0) double totalUpload,
    @JsonKey(name: 'downloadTotal') @Default(0) double totalDownload,
  }) = _ClashConnection;

  factory ClashConnection.fromJson(Map<String, dynamic> json) =>
      _$ClashConnectionFromJson(json);
}
