/// Represents a user in the TaskPilot system.
class User {
  /// Unique ID of the user.
  final String id;

  /// Display name.
  final String name;

  /// Email address.
  final String email;

  const User({required this.id, required this.name, required this.email});
}

/// Dummy users for local testing.
const List<User> dummyUsers = [
  User(id: '1', name: 'Alice', email: 'alice@example.com'),
  User(id: '2', name: 'Bob', email: 'bob@example.com'),
  User(id: '3', name: 'Carol', email: 'carol@example.com'),
  User(id: '4', name: 'Dave', email: 'dave@example.com'),
];