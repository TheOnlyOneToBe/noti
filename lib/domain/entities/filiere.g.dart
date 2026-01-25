// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filiere.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FiliereImpl _$$FiliereImplFromJson(Map<String, dynamic> json) =>
    _$FiliereImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      epreuves: (json['epreuves'] as List<dynamic>?)
              ?.map((e) => Epreuve.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$FiliereImplToJson(_$FiliereImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'epreuves': instance.epreuves,
    };
