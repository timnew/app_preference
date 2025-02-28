// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestModel {
  String get key;
  int get value;

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TestModelCopyWith<TestModel> get copyWith =>
      _$TestModelCopyWithImpl<TestModel>(this as TestModel, _$identity);

  /// Serializes this TestModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestModel &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, value);

  @override
  String toString() {
    return 'TestModel(key: $key, value: $value)';
  }
}

/// @nodoc
abstract mixin class $TestModelCopyWith<$Res> {
  factory $TestModelCopyWith(TestModel value, $Res Function(TestModel) _then) =
      _$TestModelCopyWithImpl;
  @useResult
  $Res call({String key, int value});
}

/// @nodoc
class _$TestModelCopyWithImpl<$Res> implements $TestModelCopyWith<$Res> {
  _$TestModelCopyWithImpl(this._self, this._then);

  final TestModel _self;
  final $Res Function(TestModel) _then;

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TestModel extends TestModel {
  const _TestModel({required this.key, required this.value}) : super._();
  factory _TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);

  @override
  final String key;
  @override
  final int value;

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TestModelCopyWith<_TestModel> get copyWith =>
      __$TestModelCopyWithImpl<_TestModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TestModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TestModel &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, value);

  @override
  String toString() {
    return 'TestModel(key: $key, value: $value)';
  }
}

/// @nodoc
abstract mixin class _$TestModelCopyWith<$Res>
    implements $TestModelCopyWith<$Res> {
  factory _$TestModelCopyWith(
          _TestModel value, $Res Function(_TestModel) _then) =
      __$TestModelCopyWithImpl;
  @override
  @useResult
  $Res call({String key, int value});
}

/// @nodoc
class __$TestModelCopyWithImpl<$Res> implements _$TestModelCopyWith<$Res> {
  __$TestModelCopyWithImpl(this._self, this._then);

  final _TestModel _self;
  final $Res Function(_TestModel) _then;

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_TestModel(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
