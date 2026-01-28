// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epreuve.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EpreuveImpl _$$EpreuveImplFromJson(Map<String, dynamic> json) =>
    _$EpreuveImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      filiereId: json['filiereId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      notificationIds: (json['notificationIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EpreuveImplToJson(_$EpreuveImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'filiereId': instance.filiereId,
      'date': instance.date.toIso8601String(),
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'notificationIds': instance.notificationIds,
    };
