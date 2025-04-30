class History {
  final String userId;
  final String contentId;
  final DateTime timestamp;

  History({
    required this.userId,
    required this.contentId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'contentId': contentId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}