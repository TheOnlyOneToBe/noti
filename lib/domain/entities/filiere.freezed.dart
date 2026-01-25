// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filiere.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Filiere _$FiliereFromJson(Map<String, dynamic> json) {
  return _Filiere.fromJson(json);
}

/// @nodoc
mixin _$Filiere {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<Epreuve> get epreuves => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FiliereCopyWith<Filiere> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FiliereCopyWith<$Res> {
  factory $FiliereCopyWith(Filiere value, $Res Function(Filiere) then) =
      _$FiliereCopyWithImpl<$Res, Filiere>;
  @useResult
  $Res call({String id, String name, List<Epreuve> epreuves});
}

/// @nodoc
class _$FiliereCopyWithImpl<$Res, $Val extends Filiere>
    implements $FiliereCopyWith<$Res> {
  _$FiliereCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? epreuves = null,
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
      epreuves: null == epreuves
          ? _value.epreuves
          : epreuves // ignore: cast_nullable_to_non_nullable
              as List<Epreuve>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FiliereImplCopyWith<$Res> implements $FiliereCopyWith<$Res> {
  factory _$$FiliereImplCopyWith(
          _$FiliereImpl value, $Res Function(_$FiliereImpl) then) =
      __$$FiliereImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, List<Epreuve> epreuves});
}

/// @nodoc
class __$$FiliereImplCopyWithImpl<$Res>
    extends _$FiliereCopyWithImpl<$Res, _$FiliereImpl>
    implements _$$FiliereImplCopyWith<$Res> {
  __$$FiliereImplCopyWithImpl(
      _$FiliereImpl _value, $Res Function(_$FiliereImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? epreuves = null,
  }) {
    return _then(_$FiliereImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      epreuves: null == epreuves
          ? _value._epreuves
          : epreuves // ignore: cast_nullable_to_non_nullable
              as List<Epreuve>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FiliereImpl implements _Filiere {
  const _$FiliereImpl(
      {required this.id,
      required this.name,
      final List<Epreuve> epreuves = const []})
      : _epreuves = epreuves;

  factory _$FiliereImpl.fromJson(Map<String, dynamic> json) =>
      _$$FiliereImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<Epreuve> _epreuves;
  @override
  @JsonKey()
  List<Epreuve> get epreuves {
    if (_epreuves is EqualUnmodifiableListView) return _epreuves;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_epreuves);
  }

  @override
  String toString() {
    return 'Filiere(id: $id, name: $name, epreuves: $epreuves)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FiliereImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._epreuves, _epreuves));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, const DeepCollectionEquality().hash(_epreuves));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FiliereImplCopyWith<_$FiliereImpl> get copyWith =>
      __$$FiliereImplCopyWithImpl<_$FiliereImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FiliereImplToJson(
      this,
    );
  }
}

abstract class _Filiere implements Filiere {
  const factory _Filiere(
      {required final String id,
      required final String name,
      final List<Epreuve> epreuves}) = _$FiliereImpl;

  factory _Filiere.fromJson(Map<String, dynamic> json) = _$FiliereImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<Epreuve> get epreuves;
  @override
  @JsonKey(ignore: true)
  _$$FiliereImplCopyWith<_$FiliereImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
