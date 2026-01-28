import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/filiere.dart';
import '../../domain/entities/epreuve.dart';
import '../../domain/services/notification_schedule_service.dart';
import '../providers.dart';

part 'filiere_notifier.g.dart';

@riverpod
class FiliereNotifier extends _$FiliereNotifier {
  @override
  Future<List<Filiere>> build() async {
    final repository = ref.watch(examRepositoryProvider);
    return repository.getFilieres();
  }

  Future<Epreuve?> getEpreuve(String id) async {
    final filieres = await future;
    for (final filiere in filieres) {
      try {
        return filiere.epreuves.firstWhere((e) => e.id == id);
      } catch (_) {}
    }
    return null;
  }

  Future<void> addFiliere(String name) async {
    final repository = ref.read(examRepositoryProvider);
    final filiere = Filiere(id: const Uuid().v4(), name: name);
    
    await repository.saveFiliere(filiere);
    
    // Refresh state
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateFiliere(String id, String name) async {
    final repository = ref.read(examRepositoryProvider);
    final filieres = await repository.getFilieres();
    final existingFiliere = filieres.firstWhere((f) => f.id == id);
    
    final updatedFiliere = existingFiliere.copyWith(name: name);
    await repository.saveFiliere(updatedFiliere);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteFiliere(String id) async {
    final repository = ref.read(examRepositoryProvider);
    final filieres = await repository.getFilieres();
    try {
      final filiere = filieres.firstWhere((f) => f.id == id);
      if (filiere.epreuves.isNotEmpty) {
        throw Exception("Impossible de supprimer une filière contenant des épreuves.");
      }
      await repository.deleteFiliere(id);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addEpreuve(String filiereId, String name, DateTime date, DateTime start, DateTime end) async {
    final repository = ref.read(examRepositoryProvider);
    final scheduleService = ref.read(notificationScheduleServiceProvider);
    
    // 1. Create Epreuve
    var epreuve = Epreuve(
      id: const Uuid().v4(),
      name: name,
      filiereId: filiereId,
      date: date,
      startTime: start,
      endTime: end,
    );
    
    // 2. Schedule Notifications
    // Returns the list of actually scheduled IDs (ignoring past ones)
    final scheduledIds = await scheduleService.scheduleNotificationsForEpreuve(epreuve);
    
    // 3. Update Epreuve with IDs
    epreuve = epreuve.copyWith(notificationIds: scheduledIds);

    // 4. Save to DB
    await repository.addEpreuve(epreuve);
    
    // 5. Refresh
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateEpreuve(Epreuve epreuve) async {
    final repository = ref.read(examRepositoryProvider);
    final scheduleService = ref.read(notificationScheduleServiceProvider);

    // 1. Reschedule Notifications (Cancel old + Schedule new)
    // Note: We use the epreuve passed in which might have old notificationIds, 
    // or we might trust the service to clean up based on deterministic IDs if IDs are missing.
    // The service handles cleanup properly.
    final scheduledIds = await scheduleService.rescheduleNotificationsForEpreuve(epreuve);

    // 2. Update Epreuve with new IDs
    final updatedEpreuve = epreuve.copyWith(notificationIds: scheduledIds);

    // 3. Update DB
    await repository.updateEpreuve(updatedEpreuve);

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteEpreuve(Epreuve epreuve) async {
    final repository = ref.read(examRepositoryProvider);
    final scheduleService = ref.read(notificationScheduleServiceProvider);

    // 1. Cancel notifications
    await scheduleService.cancelNotificationsForEpreuve(epreuve);

    // 2. Delete from DB
    await repository.deleteEpreuve(epreuve.id);

    ref.invalidateSelf();
    await future;
  }
}
