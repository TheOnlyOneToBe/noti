

class SeedDateService {
  /// Parse une date au format "YYYY-MM-DD"
  DateTime parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      throw FormatException("Format de date invalide pour $dateStr: $e");
    }
  }

  /// Parse une date et heure au format ISO 8601 "YYYY-MM-DDTHH:mm:ss"
  DateTime parseDateTime(String dateTimeStr) {
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      throw FormatException("Format de datetime invalide pour $dateTimeStr: $e");
    }
  }

  /// Vérifie si une date est dans le futur
  bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}
