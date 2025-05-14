/// Model representing a communication item (Call, Email, or Text).
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Types of communications.
enum CommunicationType { Call, Email, Text }

/// A simple model for a communication entry.
class CommunicationItem {
  final String id;
  final CommunicationType type;
  final String description;
  final DateTime date;
  final bool completed;

  CommunicationItem({
    required this.id,
    required this.type,
    required this.description,
    required this.date,
    this.completed = false,
  });

  CommunicationItem copyWith({
    String? id,
    CommunicationType? type,
    String? description,
    DateTime? date,
    bool? completed,
  }) {
    return CommunicationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }
}