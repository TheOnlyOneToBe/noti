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
    final notificationService = ref.read(notificationServiceProvider);
    
    final epreuve = Epreuve(
      id: const Uuid().v4(),
      name: name,
      filiereId: filiereId,
      date: date,
      startTime: start,
      endTime: end,
    );
    
    // 1. Save to DB
    await repository.addEpreuve(epreuve);
    
    // 2. Schedule Notifications
    _scheduleNotifications(epreuve, notificationService);

    // 3. Refresh
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateEpreuve(Epreuve epreuve) async {
    final repository = ref.read(examRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);

    // 1. Cancel old notifications
    await _cancelNotifications(epreuve, notificationService);

    // 2. Update DB
    await repository.updateEpreuve(epreuve);

    // 3. Schedule new notifications
    await _scheduleNotifications(epreuve, notificationService);

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteEpreuve(Epreuve epreuve) async {
    final repository = ref.read(examRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);

    // 1. Cancel notifications
    await _cancelNotifications(epreuve, notificationService);

    // 2. Delete from DB
    await repository.deleteEpreuve(epreuve.id);

    ref.invalidateSelf();
    await future;
  }

  Future<void> _scheduleNotifications(Epreuve epreuve, dynamic notificationService) async {
    final triggers = NotificationScheduleService.getScheduledNotifications(epreuve);
    
    int index = 0;
    triggers.forEach((triggerTime, message) {
      if (triggerTime.isAfter(DateTime.now())) {
        final notificationId = (epreuve.id.hashCode + index) & 0x7FFFFFFF;
        notificationService.scheduleNotification(
          id: notificationId,
          title: "Rappel Examen: ${epreuve.name}",
          body: message,
          scheduledDate: triggerTime,
        );
      }
      index++;
    });
  }

  Future<void> _cancelNotifications(Epreuve epreuve, dynamic notificationService) async {
    // Cancel potential notifications (assuming max 10 per exam)
    for (int i = 0; i < 10; i++) {
      final notificationId = (epreuve.id.hashCode + i) & 0x7FFFFFFF;
      await notificationService.cancelNotification(notificationId);
    }
  }
}
