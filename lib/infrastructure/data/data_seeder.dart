import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/filiere.dart';
import '../../domain/entities/epreuve.dart';
import '../../domain/repositories/i_exam_repository.dart';

class DataSeeder {
  final IExamRepository repository;

  DataSeeder(this.repository);

  Future<void> seed() async {
    final filieres = await repository.getFilieres();
    if (filieres.isNotEmpty) {
      debugPrint('DataSeeder: Base de données déjà initialisée.');
      return; 
    }

    try {
      debugPrint('DataSeeder: Chargement des données depuis assets/seeds.json...');
      final String jsonString = await rootBundle.loadString('assets/seeds.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      for (final filiereJson in jsonList) {
        // 1. Création de la filière sans épreuves pour commencer
        final filiere = Filiere(
          id: filiereJson['id'],
          name: filiereJson['name'],
          epreuves: [],
        );
        
        await repository.saveFiliere(filiere);

        // 2. Ajout des épreuves
        final epreuvesJson = filiereJson['epreuves'] as List<dynamic>;
        for (final epreuveJson in epreuvesJson) {
          final epreuve = Epreuve(
            id: epreuveJson['id'],
            name: epreuveJson['name'],
            filiereId: filiere.id, // Assurer que l'ID correspond
            date: DateTime.parse(epreuveJson['date']),
            startTime: DateTime.parse(epreuveJson['startTime']),
            endTime: DateTime.parse(epreuveJson['endTime']),
            notificationIds: [], // Sera géré par le scheduler si besoin, ou vide
          );
          
          await repository.addEpreuve(epreuve);
        }
      }
      debugPrint('DataSeeder: Initialisation terminée avec succès.');
    } catch (e) {
      debugPrint('DataSeeder Error: $e');
      rethrow;
    }
  }
}
