import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/services/local_notification_service.dart';
import '../entities/epreuve.dart';

final notificationScheduleServiceProvider = Provider((ref) {
  final localService = ref.watch(localNotificationServiceProvider);
  return NotificationScheduleService(localService);
});

class NotificationScheduleService {
  final LocalNotificationService _localNotificationService;

  NotificationScheduleService(this._localNotificationService);

  /// Méthode statique pour l'UI de prévisualisation.
  /// Retourne une Map <Offset depuis le début, Message>.
  /// Utilise la même logique que scheduleNotificationsForEpreuve mais sans dépendances.
  static Map<Duration, String> calculatePreviewReminders(Duration duration) {
    final Map<Duration, String> reminders = {};
    
    // Définitions des triggers (identiques à la méthode d'instance)
    // Offset par rapport à la fin
    final triggers = [
      _NotificationTrigger(
        offset: const Duration(hours: 1, minutes: 30),
        message: "Rappel : 1h30 avant la fin.",
        isBeforeEnd: true,
        suffixId: 1,
      ),
      _NotificationTrigger(
        offset: const Duration(minutes: 30),
        message: "Rappel : 30 min avant la fin.",
        isBeforeEnd: true,
        suffixId: 2,
      ),
      _NotificationTrigger(
        offset: Duration.zero,
        message: "L'épreuve est terminée.",
        isBeforeEnd: false,
        suffixId: 3,
      ),
    ];

    for (final trigger in triggers) {
      Duration triggerFromStart;
      if (trigger.isBeforeEnd) {
        triggerFromStart = duration - trigger.offset;
      } else {
        triggerFromStart = duration; // Fin
      }

      // On ne garde que si le trigger est après le début de l'épreuve (et pas avant)
      if (triggerFromStart >= Duration.zero) {
        reminders[triggerFromStart] = trigger.message;
      }
    }

    return reminders;
  }

  /// Planifie les notifications pour une épreuve.
  /// Retourne la liste des IDs des notifications effectivement planifiées.
  Future<List<int>> scheduleNotificationsForEpreuve(Epreuve epreuve) async {
    final List<int> scheduledIds = [];
    final now = DateTime.now();

    // Réutilisation de la logique pour cohérence, mais ici on a besoin des dates absolues
    // On peut dupliquer la logique des triggers pour avoir accès aux messages dynamiques (avec le nom)
    
    final triggers = [
      _NotificationTrigger(
        offset: const Duration(hours: 1, minutes: 30),
        message: "L'épreuve ${epreuve.name} se termine dans 1h30.",
        isBeforeEnd: true,
        suffixId: 1,
      ),
      _NotificationTrigger(
        offset: const Duration(minutes: 30),
        message: "L'épreuve ${epreuve.name} se termine dans 30 minutes.",
        isBeforeEnd: true,
        suffixId: 2,
      ),
      _NotificationTrigger(
        offset: Duration.zero,
        message: "L'épreuve ${epreuve.name} est terminée.",
        isBeforeEnd: false, // C'est la fin exacte
        suffixId: 3,
      ),
    ];

    for (final trigger in triggers) {
      final scheduledDate = trigger.isBeforeEnd
          ? epreuve.endTime.subtract(trigger.offset)
          : epreuve.endTime;

      // Vérification supplémentaire : le trigger ne doit pas être avant le début de l'épreuve
      if (scheduledDate.isBefore(epreuve.startTime)) {
        continue;
      }

      // Ignorer si la date est passée
      if (scheduledDate.isBefore(now)) {
        continue;
      }

      // Générer un ID unique et déterministe
      final int notificationId = _generateNotificationId(epreuve.id, trigger.suffixId);

      await _localNotificationService.schedule(
        id: notificationId,
        title: "Rappel Épreuve",
        body: trigger.message,
        scheduledDate: scheduledDate,
        payload: epreuve.id, // Utile pour la navigation
      );

      scheduledIds.add(notificationId);
    }

    debugPrint('NotificationScheduleService: Scheduled ${scheduledIds.length} notifications for epreuve ${epreuve.id}');
    return scheduledIds;
  }

  /// Annule toutes les notifications liées à une épreuve.
  /// Utilise les IDs stockés dans l'épreuve si disponibles, sinon recalcule les IDs théoriques.
  Future<void> cancelNotificationsForEpreuve(Epreuve epreuve) async {
    List<int> idsToCancel = [];

    if (epreuve.notificationIds.isNotEmpty) {
      idsToCancel = epreuve.notificationIds;
    } else {
      // Fallback : recalculer les IDs théoriques (1, 2, 3)
      idsToCancel = [
        _generateNotificationId(epreuve.id, 1),
        _generateNotificationId(epreuve.id, 2),
        _generateNotificationId(epreuve.id, 3),
      ];
    }

    await _localNotificationService.cancelMultiple(idsToCancel);
    debugPrint('NotificationScheduleService: Cancelled notifications for epreuve ${epreuve.id}');
  }

  /// Reprogramme les notifications (Annule puis Planifie).
  /// Retourne la nouvelle liste d'IDs.
  Future<List<int>> rescheduleNotificationsForEpreuve(Epreuve epreuve) async {
    await cancelNotificationsForEpreuve(epreuve);
    return await scheduleNotificationsForEpreuve(epreuve);
  }

  /// Génère un ID unique stable (int 32-bit) à partir de l'ID de l'épreuve (String) et d'un suffixe.
  int _generateNotificationId(String epreuveId, int suffix) {
    int hash = 0;
    for (int i = 0; i < epreuveId.length; i++) {
      hash = 0x3FFFFFFF & (31 * hash + epreuveId.codeUnitAt(i));
    }
    
    // Better strategy: Hash combined string
    final combinedKey = "${epreuveId}_$suffix";
    int finalHash = 0;
    for (int i = 0; i < combinedKey.length; i++) {
      finalHash = 0x3FFFFFFF & (31 * finalHash + combinedKey.codeUnitAt(i));
    }
    
    return finalHash;
  }
}

class _NotificationTrigger {
  final Duration offset;
  final String message;
  final bool isBeforeEnd;
  final int suffixId;

  _NotificationTrigger({
    required this.offset,
    required this.message,
    required this.isBeforeEnd,
    required this.suffixId,
  });
}
