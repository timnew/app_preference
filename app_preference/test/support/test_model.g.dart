// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestModel _$TestModelFromJson(Map<String, dynamic> json) => _TestModel(
      key: json['key'] as String,
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$TestModelToJson(_TestModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };
