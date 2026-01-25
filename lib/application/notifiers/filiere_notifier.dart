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

  Future<void> deleteFiliere(String id) async {
    final repository = ref.read(examRepositoryProvider);
    await repository.deleteFiliere(id);
    ref.invalidateSelf();
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
    final triggers = NotificationScheduleService.getScheduledNotifications(epreuve);
    
    // We use a simple hash of ID + index for notification ID, or just random
    // Better: store notification IDs in Epreuve? 
    // For this MVP, we'll generate IDs based on Epreuve ID hash.
    
    int index = 0;
    triggers.forEach((triggerTime, message) {
      // Create a unique ID for each notification
      final notificationId = (epreuve.id.hashCode + index) & 0x7FFFFFFF; // Ensure positive int
      
      notificationService.scheduleNotification(
        id: notificationId,
        title: "Rappel Examen: ${epreuve.name}",
        body: message,
        scheduledDate: triggerTime,
      );
      index++;
    });

    // 3. Refresh
    ref.invalidateSelf();
    await future;
  }
}
