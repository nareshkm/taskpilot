/// Represents a task that has been shared between users.
class SharedTask {
  /// Unique identifier for this shared record.
  final String id;

  /// The original task ID that was shared.
  final String taskId;

  /// The user who shared the task.
  final String fromUserId;

  /// The user who received the task.
  final String toUserId;

  /// When the task was shared.
  final DateTime timestamp;

  /// Arbitrary metadata for future use.
  final Map<String, dynamic> metadata;

  SharedTask({
    required this.id,
    required this.taskId,
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  factory SharedTask.fromJson(Map<String, dynamic> json) {
    return SharedTask(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}