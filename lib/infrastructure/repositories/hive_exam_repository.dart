import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/filiere.dart';
import '../../domain/entities/epreuve.dart';
import '../../domain/repositories/i_exam_repository.dart';

class HiveExamRepository implements IExamRepository {
  static const String _boxName = 'filieres';
  
  Future<Box<String>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<String>(_boxName);
    }
    return Hive.box<String>(_boxName);
  }

  @override
  Future<List<Filiere>> getFilieres() async {
    final box = await _getBox();
    return box.values
        .map((e) => Filiere.fromJson(jsonDecode(e)))
        .toList();
  }

  @override
  Future<void> saveFiliere(Filiere filiere) async {
    final box = await _getBox();
    await box.put(filiere.id, jsonEncode(filiere.toJson()));
  }

  @override
  Future<void> deleteFiliere(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> addEpreuve(Epreuve epreuve) async {
    final box = await _getBox();
    final filiereJsonString = box.get(epreuve.filiereId);
    
    if (filiereJsonString != null) {
      final filiere = Filiere.fromJson(jsonDecode(filiereJsonString));
      final updatedFiliere = filiere.copyWith(
        epreuves: [...filiere.epreuves, epreuve],
      );
      await saveFiliere(updatedFiliere);
    } else {
      throw Exception('Filiere not found for id ${epreuve.filiereId}');
    }
  }

  @override
  Future<void> deleteEpreuve(String id) async {
    // This is inefficient (O(N*M)) but fine for local app
    final box = await _getBox();
    final allFilieres = box.values.map((e) => Filiere.fromJson(jsonDecode(e)));
    
    for (final filiere in allFilieres) {
      if (filiere.epreuves.any((e) => e.id == id)) {
        final updatedFiliere = filiere.copyWith(
          epreuves: filiere.epreuves.where((e) => e.id != id).toList(),
        );
        await saveFiliere(updatedFiliere);
        return;
      }
    }
  }

  @override
  Future<void> updateEpreuve(Epreuve epreuve) async {
    final box = await _getBox();
    final filiereJsonString = box.get(epreuve.filiereId);
    
    if (filiereJsonString != null) {
      final filiere = Filiere.fromJson(jsonDecode(filiereJsonString));
      final updatedEpreuves = filiere.epreuves.map((e) {
        return e.id == epreuve.id ? epreuve : e;
      }).toList();
      
      final updatedFiliere = filiere.copyWith(epreuves: updatedEpreuves);
      await saveFiliere(updatedFiliere);
    }
  }
}
