import 'package:flutter/material.dart';
import '../../domain/services/notification_schedule_service.dart';

class ReminderPreviewWidget extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;

  const ReminderPreviewWidget({
    super.key,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final duration = endTime.difference(startTime);
    if (duration.isNegative) {
      return const Text("L'heure de fin doit être après l'heure de début.", style: TextStyle(color: Colors.red));
    }

    final reminders = NotificationScheduleService.calculateReminders(duration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Durée calculée : ${duration.inHours}h ${duration.inMinutes.remainder(60)}min",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text("Notifications planifiées :"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: reminders.entries.map((entry) {
            final offset = entry.key;
            final message = entry.value;
            
            // Show absolute time for clarity
            final triggerTime = startTime.add(offset);
            final timeStr = "${triggerTime.hour.toString().padLeft(2, '0')}:${triggerTime.minute.toString().padLeft(2, '0')}";

            return Chip(
              avatar: const Icon(Icons.notifications_active, size: 16),
              label: Text("$timeStr - $message"),
              backgroundColor: Colors.blue.shade50,
            );
          }).toList(),
        ),
      ],
    );
  }
}
