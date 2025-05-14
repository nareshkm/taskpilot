import 'dart:convert';

/// A request to share tasks between users.
class ShareRequest {
  /// Unique identifier of this request.
  final String id;

  /// ID of the user who sent the request.
  final String fromUserId;

  /// ID of the user to whom the request is sent.
  final String toUserId;

  /// Status of the request: 'pending', 'accepted', or 'declined'.
  final String status;

  /// When the request was created.
  final DateTime timestamp;

  /// Arbitrary metadata for future use.
  final Map<String, dynamic> metadata;

  ShareRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.timestamp,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  factory ShareRequest.fromJson(Map<String, dynamic> json) {
    return ShareRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}