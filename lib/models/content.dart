class Content {
  final String id;
  final String title;
  final String type;
  final String difficulty;
  final String url;
  final List<String> topics;

  Content({required this.id, required this.title, required this.type, required this.difficulty, required this.url, required this.topics});

  factory Content.fromMap(Map<String, dynamic> data, String id) {
    return Content(
      id: id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      difficulty: data['difficulty'] ?? '',
      url: data['url'] ?? '',
      topics: List<String>.from(data['topics'] ?? []),
    );
  }
}