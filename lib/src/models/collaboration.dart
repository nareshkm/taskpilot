/// Represents a confirmed collaboration between two users.
class Collaboration {
  /// Unique identifier for this collaboration.
  final String id;

  /// One user in the collaboration.
  final String user1;

  /// The other user in the collaboration.
  final String user2;

  /// When the collaboration was established.
  final DateTime since;

  /// Arbitrary metadata for future use.
  final Map<String, dynamic> metadata;

  Collaboration({
    required this.id,
    required this.user1,
    required this.user2,
    required this.since,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  factory Collaboration.fromJson(Map<String, dynamic> json) {
    return Collaboration(
      id: json['id'] as String,
      user1: json['user1'] as String,
      user2: json['user2'] as String,
      since: DateTime.parse(json['since'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1': user1,
      'user2': user2,
      'since': since.toIso8601String(),
      'metadata': metadata,
    };
  }
}