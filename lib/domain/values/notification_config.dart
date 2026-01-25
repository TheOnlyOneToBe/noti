enum NotificationType {
  start,
  halfway, // Not used yet but good to have
  warning, // Generic warning
  end,
}

class NotificationTrigger {
  final Duration offsetFromStart;
  final String message;
  final NotificationType type;

  const NotificationTrigger({
    required this.offsetFromStart,
    required this.message,
    required this.type,
  });
  
  @override
  String toString() => 'Trigger at $offsetFromStart: $message';
}
