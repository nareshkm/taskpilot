import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/share_request.dart';
import '../models/collaboration.dart';
import '../models/shared_task.dart';

/// Service for persisting share-related data locally as JSON.
class SharedDataService {
  SharedDataService._();
  static final SharedDataService _instance = SharedDataService._();
  factory SharedDataService() => _instance;

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shared_data.json');
  }

  /// Loads the entire shared data structure from file.
  Future<Map<String, dynamic>> _readRaw() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents) as Map<String, dynamic>;
      }
    } catch (_) {}
    // Default empty structure
    return {
      'shareRequests': [],
      'collaborations': [],
      'sharedTasks': [],
    };
  }

  Future<void> _writeRaw(Map<String, dynamic> data) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(data));
  }

  /// Loads share requests from storage.
  Future<List<ShareRequest>> loadShareRequests() async {
    final raw = await _readRaw();
    final list = raw['shareRequests'] as List<dynamic>;
    return list.map((e) => ShareRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Loads collaborations from storage.
  Future<List<Collaboration>> loadCollaborations() async {
    final raw = await _readRaw();
    final list = raw['collaborations'] as List<dynamic>;
    return list.map((e) => Collaboration.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Loads shared tasks from storage.
  Future<List<SharedTask>> loadSharedTasks() async {
    final raw = await _readRaw();
    final list = raw['sharedTasks'] as List<dynamic>;
    return list.map((e) => SharedTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Persists all data back to storage.
  Future<void> saveAll({
    required List<ShareRequest> shareRequests,
    required List<Collaboration> collaborations,
    required List<SharedTask> sharedTasks,
  }) async {
    final raw = {
      'shareRequests': shareRequests.map((e) => e.toJson()).toList(),
      'collaborations': collaborations.map((e) => e.toJson()).toList(),
      'sharedTasks': sharedTasks.map((e) => e.toJson()).toList(),
    };
    await _writeRaw(raw);
  }
}