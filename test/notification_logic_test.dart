import 'package:flutter_test/flutter_test.dart';
import 'package:noti/domain/services/notification_schedule_service.dart';

void main() {
  group('NotificationScheduleService Logic', () {
    test('Calculates correct reminders for 2 hours exam', () {
      const duration = Duration(hours: 2);
      final reminders = NotificationScheduleService.calculateReminders(duration);

      // Expected: End, -1h, -30m
      expect(reminders.length, 3);
      expect(reminders.containsKey(duration), true, reason: 'Should notify at end');
      expect(reminders.containsKey(const Duration(hours: 1)), true, reason: 'Should notify at 1h remaining (1h from start)');
      expect(reminders.containsKey(const Duration(hours: 1, minutes: 30)), true, reason: 'Should notify at 30m remaining (1h30 from start)');
    });

    test('Calculates correct reminders for 3 hours exam', () {
      const duration =  Duration(hours: 3);
      final reminders = NotificationScheduleService.calculateReminders(duration);

      // Expected: End, -1h30, -30m
      expect(reminders.length, 3);
      expect(reminders.containsKey(duration), true);
      // -1h30 remaining -> 1h30 from start
      expect(reminders.containsKey(const Duration(hours: 1, minutes: 30)), true);
      // -30m remaining -> 2h30 from start
      expect(reminders.containsKey(const Duration(hours: 2, minutes: 30)), true);
    });

    test('Calculates correct reminders for 4 hours exam', () {
      const duration = Duration(hours: 4);
      final reminders = NotificationScheduleService.calculateReminders(duration);

      // Expected: End, -2h, -1h, -30m
      expect(reminders.length, 4);
      expect(reminders.containsKey(duration), true);
      // -2h remaining -> 2h from start
      expect(reminders.containsKey(const Duration(hours: 2)), true);
      // -1h remaining -> 3h from start
      expect(reminders.containsKey(const Duration(hours: 3)), true);
      // -30m remaining -> 3h30 from start
      expect(reminders.containsKey(const Duration(hours: 3, minutes: 30)), true);
    });

    test('Calculates fallback for short exam (45 mins)', () {
      const duration = Duration(minutes: 45);
      final reminders = NotificationScheduleService.calculateReminders(duration);

      // Expected: End, -30m
      expect(reminders.containsKey(duration), true);
      // -30m remaining -> 15m from start
      expect(reminders.containsKey(const Duration(minutes: 15)), true);
    });
  });
}
