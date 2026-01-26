import 'package:freezed_annotation/freezed_annotation.dart';

part 'epreuve.freezed.dart';
part 'epreuve.g.dart';

enum ExamStatus { past, ongoing, upcoming }

@freezed
class Epreuve with _$Epreuve {
  const Epreuve._(); // Private constructor for methods

  const factory Epreuve({
    required String id,
    required String name,
    required String filiereId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) = _Epreuve;

  factory Epreuve.fromJson(Map<String, dynamic> json) => _$EpreuveFromJson(json);

  /// Automatically calculated duration
  Duration get duration => endTime.difference(startTime);

  ExamStatus get status {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return ExamStatus.past;
    if (now.isAfter(startTime) && now.isBefore(endTime)) return ExamStatus.ongoing;
    return ExamStatus.upcoming;
  }
}
