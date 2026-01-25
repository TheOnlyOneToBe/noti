import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/i_exam_repository.dart';
import '../../infrastructure/repositories/hive_exam_repository.dart';
import '../../infrastructure/services/local_notification_service.dart';

part 'providers.g.dart';

@riverpod
IExamRepository examRepository(ExamRepositoryRef ref) {
  return HiveExamRepository();
}

@riverpod
LocalNotificationService notificationService(NotificationServiceRef ref) {
  return LocalNotificationService();
}
