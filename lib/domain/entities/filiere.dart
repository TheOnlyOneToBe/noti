import 'package:freezed_annotation/freezed_annotation.dart';
import 'epreuve.dart';

part 'filiere.freezed.dart';
part 'filiere.g.dart';

@freezed
class Filiere with _$Filiere {
  const factory Filiere({
    required String id,
    required String name,
    @Default([]) List<Epreuve> epreuves,
  }) = _Filiere;

  factory Filiere.fromJson(Map<String, dynamic> json) => _$FiliereFromJson(json);
}
