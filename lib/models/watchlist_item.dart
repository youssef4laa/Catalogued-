class WatchlistItem {
  final String id;
  final String title;
  final String type; // movie, tv show, book, etc.
  final bool completed;
  final DateTime? dateAdded;
  final String? notes;
  final TMDBMetadata? metadata;

  WatchlistItem({
    required this.id,
    required this.title,
    required this.type,
    this.completed = false,
    this.dateAdded,
    this.notes,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'completed': completed,
      'dateAdded': dateAdded?.toIso8601String(),
      'notes': notes,
      'metadata': metadata?.toJson(),
    };
  }

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      completed: json['completed'] ?? false,
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'])
          : null,
      notes: json['notes'],
      metadata: json['metadata'] != null
          ? TMDBMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}