import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_native/json_native.dart';

part 'test_model.freezed.dart';
part 'test_model.g.dart';

@freezed
abstract class TestModel with _$TestModel {
  const TestModel._();

  const factory TestModel({
    required String key,
    required int value,
  }) = _TestModel;

  static const empty = TestModel(key: '', value: 0);

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);

  String toJsonString() => jsonEncode(toJson());

  static String? serialize(TestModel value) => jsonEncode(value.toJson());
  factory TestModel.deserialize(String? json) =>
      json == null ? TestModel.empty : TestModel.fromJson(jsonDecodeCast(json));
}
