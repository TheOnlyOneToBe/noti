import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/filiere.dart';
import '../../domain/entities/epreuve.dart';
import '../../domain/repositories/i_exam_repository.dart';
import '../../domain/services/notification_schedule_service.dart';
import '../../infrastructure/services/seed_date_service.dart';


class DataSeeder {
  final IExamRepository repository;
  final NotificationScheduleService notificationScheduleService;
  final SeedDateService seedDateService;

  DataSeeder(this.repository, this.notificationScheduleService, {SeedDateService? seedDateService}) 
      : seedDateService = seedDateService ?? SeedDateService();

  Future<void> seed() async {
    final filieres = await repository.getFilieres();
    
    // Vérifier si on doit forcer le re-seeding (ex: si toutes les épreuves sont passées)
    bool shouldSeed = filieres.isEmpty;
    if (!shouldSeed) {
      final allEpreuves = filieres.expand((f) => f.epreuves).toList();
      // Si on a des épreuves mais qu'elles sont toutes finies, on considère que ce sont de vieilles données de test
      final areAllPast = allEpreuves.isNotEmpty && 
          allEpreuves.every((e) => e.endTime.isBefore(DateTime.now()));
      
      if (areAllPast) {
        debugPrint('DataSeeder: Données obsolètes détectées. Forçage du re-seeding...');
        shouldSeed = true;
      }
    }

    if (!shouldSeed) {
      debugPrint('DataSeeder: Base de données déjà initialisée et valide.');
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
          var epreuve = Epreuve(
            id: epreuveJson['id'],
            name: epreuveJson['name'],
            filiereId: filiere.id, // Assurer que l'ID correspond
            date: seedDateService.parseDate(epreuveJson['date']),
            startTime: seedDateService.parseDateTime(epreuveJson['startTime']),
            endTime: seedDateService.parseDateTime(epreuveJson['endTime']),
            notificationIds: [],
          );

          // Planification des notifications
          // On ne planifie que si l'épreuve n'est pas terminée
          if (seedDateService.isFuture(epreuve.endTime)) {
            try {
              final scheduledIds = await notificationScheduleService.scheduleNotificationsForEpreuve(epreuve);
              epreuve = epreuve.copyWith(notificationIds: scheduledIds);
              debugPrint('DataSeeder: Notifications planifiées pour ${epreuve.name} (IDs: $scheduledIds)');
            } catch (e) {
              debugPrint('DataSeeder: Erreur lors de la planification des notifications pour ${epreuve.name}: $e');
              // On continue même si la notif échoue
            }
          } else {
             debugPrint('DataSeeder: Épreuve passée ou terminée, pas de notification pour ${epreuve.name}');
          }
          
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
