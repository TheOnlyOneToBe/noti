import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/i_exam_repository.dart';
import '../../infrastructure/repositories/hive_exam_repository.dart';
import '../../infrastructure/services/local_notification_service.dart';
import '../../infrastructure/data/data_seeder.dart';

part 'providers.g.dart';

@riverpod
DataSeeder dataSeeder(DataSeederRef ref) {
  final repository = ref.watch(examRepositoryProvider);
  return DataSeeder(repository);
}

@riverpod
IExamRepository examRepository(ExamRepositoryRef ref) {
  return HiveExamRepository();
}

@Riverpod(keepAlive: true)
LocalNotificationService notificationService(NotificationServiceRef ref) {
  return LocalNotificationService();
}
