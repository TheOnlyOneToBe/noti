import '../entities/epreuve.dart';

class NotificationScheduleService {
  /// Calculates the list of relative offsets (from the start of the exam) 
  /// for notifications based on the exam duration.
  /// 
  /// Returns a Map where key is the duration from start, and value is the message.
  static Map<Duration, String> calculateReminders(Duration duration) {
    final Map<Duration, String> reminders = {};
    
    // Always add end notification
    reminders[duration] = "L'épreuve est terminée.";

    if (duration >= const Duration(hours: 4)) {
      // Rappel à 2h restantes
      reminders[duration - const Duration(hours: 2)] = "Il reste 2 heures.";
      // Rappel à 1h restante
      reminders[duration - const Duration(hours: 1)] = "Il reste 1 heure.";
      // Rappel à 30 min restantes
      reminders[duration - const Duration(minutes: 30)] = "Il reste 30 minutes.";
    } else if (duration >= const Duration(hours: 3)) {
       // Rappel à 1h30 restantes
      reminders[duration - const Duration(hours: 1, minutes: 30)] = "Il reste 1 heure 30 minutes.";
      // Rappel à 30 min restantes
      reminders[duration - const Duration(minutes: 30)] = "Il reste 30 minutes.";
    } else if (duration >= const Duration(hours: 2)) {
      // Rappel à 1h restante
      reminders[duration - const Duration(hours: 1)] = "Il reste 1 heure.";
      // Rappel à 30 min restantes
      reminders[duration - const Duration(minutes: 30)] = "Il reste 30 minutes.";
    } else {
      // Fallback for short exams (< 2h)
      // If duration > 30 mins, warn at 30 mins remaining
      if (duration > const Duration(minutes: 30)) {
        reminders[duration - const Duration(minutes: 30)] = "Il reste 30 minutes.";
      }
      // If duration > 10 mins, warn at 5 mins remaining (Bonus, not requested but smart)
      // Keeping it simple as per strict instructions first.
    }

    return reminders;
  }

  /// Generates absolute DateTime triggers for an Epreuve
  static Map<DateTime, String> getScheduledNotifications(Epreuve epreuve) {
    final duration = epreuve.duration;
    final offsets = calculateReminders(duration);
    
    final Map<DateTime, String> schedules = {};
    offsets.forEach((offset, message) {
      final triggerTime = epreuve.startTime.add(offset);
      schedules[triggerTime] = message;
    });
    
    return schedules;
  }
}
