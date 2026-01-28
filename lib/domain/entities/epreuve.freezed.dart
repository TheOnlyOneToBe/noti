// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'epreuve.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Epreuve _$EpreuveFromJson(Map<String, dynamic> json) {
  return _Epreuve.fromJson(json);
}

/// @nodoc
mixin _$Epreuve {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get filiereId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  List<int> get notificationIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EpreuveCopyWith<Epreuve> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpreuveCopyWith<$Res> {
  factory $EpreuveCopyWith(Epreuve value, $Res Function(Epreuve) then) =
      _$EpreuveCopyWithImpl<$Res, Epreuve>;
  @useResult
  $Res call(
      {String id,
      String name,
      String filiereId,
      DateTime date,
      DateTime startTime,
      DateTime endTime,
      List<int> notificationIds});
}

/// @nodoc
class _$EpreuveCopyWithImpl<$Res, $Val extends Epreuve>
    implements $EpreuveCopyWith<$Res> {
  _$EpreuveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? filiereId = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? notificationIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      filiereId: null == filiereId
          ? _value.filiereId
          : filiereId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notificationIds: null == notificationIds
          ? _value.notificationIds
          : notificationIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpreuveImplCopyWith<$Res> implements $EpreuveCopyWith<$Res> {
  factory _$$EpreuveImplCopyWith(
          _$EpreuveImpl value, $Res Function(_$EpreuveImpl) then) =
      __$$EpreuveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String filiereId,
      DateTime date,
      DateTime startTime,
      DateTime endTime,
      List<int> notificationIds});
}

/// @nodoc
class __$$EpreuveImplCopyWithImpl<$Res>
    extends _$EpreuveCopyWithImpl<$Res, _$EpreuveImpl>
    implements _$$EpreuveImplCopyWith<$Res> {
  __$$EpreuveImplCopyWithImpl(
      _$EpreuveImpl _value, $Res Function(_$EpreuveImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? filiereId = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? notificationIds = null,
  }) {
    return _then(_$EpreuveImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      filiereId: null == filiereId
          ? _value.filiereId
          : filiereId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notificationIds: null == notificationIds
          ? _value._notificationIds
          : notificationIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EpreuveImpl extends _Epreuve {
  const _$EpreuveImpl(
      {required this.id,
      required this.name,
      required this.filiereId,
      required this.date,
      required this.startTime,
      required this.endTime,
      final List<int> notificationIds = const []})
      : _notificationIds = notificationIds,
        super._();

  factory _$EpreuveImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpreuveImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String filiereId;
  @override
  final DateTime date;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  final List<int> _notificationIds;
  @override
  @JsonKey()
  List<int> get notificationIds {
    if (_notificationIds is EqualUnmodifiableListView) return _notificationIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notificationIds);
  }

  @override
  String toString() {
    return 'Epreuve(id: $id, name: $name, filiereId: $filiereId, date: $date, startTime: $startTime, endTime: $endTime, notificationIds: $notificationIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpreuveImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.filiereId, filiereId) ||
                other.filiereId == filiereId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            const DeepCollectionEquality()
                .equals(other._notificationIds, _notificationIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      filiereId,
      date,
      startTime,
      endTime,
      const DeepCollectionEquality().hash(_notificationIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpreuveImplCopyWith<_$EpreuveImpl> get copyWith =>
      __$$EpreuveImplCopyWithImpl<_$EpreuveImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpreuveImplToJson(
      this,
    );
  }
}

abstract class _Epreuve extends Epreuve {
  const factory _Epreuve(
      {required final String id,
      required final String name,
      required final String filiereId,
      required final DateTime date,
      required final DateTime startTime,
      required final DateTime endTime,
      final List<int> notificationIds}) = _$EpreuveImpl;
  const _Epreuve._() : super._();

  factory _Epreuve.fromJson(Map<String, dynamic> json) = _$EpreuveImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get filiereId;
  @override
  DateTime get date;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  List<int> get notificationIds;
  @override
  @JsonKey(ignore: true)
  _$$EpreuveImplCopyWith<_$EpreuveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
