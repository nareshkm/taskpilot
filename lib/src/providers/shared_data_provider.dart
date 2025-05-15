import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/share_request.dart';
import '../models/collaboration.dart';
import '../models/shared_task.dart';
import '../services/shared_data_service.dart';
import '../services/notification_service.dart';
import '../models/user.dart';
import '../services/notification_service.dart';

/// Holds all share-related data: requests, collaborations, and shared tasks.
class SharedDataState {
  final List<ShareRequest> shareRequests;
  final List<Collaboration> collaborations;
  final List<SharedTask> sharedTasks;

  SharedDataState({
    required this.shareRequests,
    required this.collaborations,
    required this.sharedTasks,
  });

  SharedDataState copyWith({
    List<ShareRequest>? shareRequests,
    List<Collaboration>? collaborations,
    List<SharedTask>? sharedTasks,
  }) {
    return SharedDataState(
      shareRequests: shareRequests ?? this.shareRequests,
      collaborations: collaborations ?? this.collaborations,
      sharedTasks: sharedTasks ?? this.sharedTasks,
    );
  }
}

/// Manages share data and persists it to JSON.
class SharedDataNotifier extends StateNotifier<SharedDataState> {
  SharedDataNotifier()
      : super(SharedDataState(
          shareRequests: [],
          collaborations: [],
          sharedTasks: [],
        )) {
    _loadData();
  }

  final _service = SharedDataService();

  Future<void> _loadData() async {
    final requests = await _service.loadShareRequests();
    final collabs = await _service.loadCollaborations();
    final tasks = await _service.loadSharedTasks();
    state = SharedDataState(
      shareRequests: requests,
      collaborations: collabs,
      sharedTasks: tasks,
    );
  }

  /// Send a new share request from [fromUserId] to [toUserId].
  Future<void> sendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    // Prevent duplicate pending requests
    if (state.shareRequests.any((r) =>
        r.fromUserId == fromUserId &&
        r.toUserId == toUserId &&
        r.status == 'pending')) {
      // Notify sender that duplicate request is not allowed
      NotificationService().showSimpleNotification(
        id: 'duplicate-$fromUserId-$toUserId',
        title: 'Invite Already Sent',
        body: 'You have already sent an invite to this user.',
      );
      return;
    }
    // Prevent inviting existing collaborators
    if (state.collaborations.any((c) =>
        (c.user1 == fromUserId && c.user2 == toUserId) ||
        (c.user1 == toUserId && c.user2 == fromUserId))) {
      NotificationService().showSimpleNotification(
        id: 'collaborator-$fromUserId-$toUserId',
        title: 'Already Collaborating',
        body: 'You are already collaborating with this user.',
      );
      return;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final req = ShareRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: 'pending',
      timestamp: DateTime.now(),
    );
    final updated = [...state.shareRequests, req];
    state = state.copyWith(shareRequests: updated);
    await _sync();
    // Notify sender that request has been created
    NotificationService().showSimpleNotification(
      id: req.id,
      title: 'Share Request Sent',
      body: 'Your request to share tasks has been sent.',
    );
  }

  /// Accept the share request [requestId] and establish collaboration.
  Future<void> acceptRequest(String requestId) async {
    final req = state.shareRequests.firstWhere((r) => r.id == requestId);
    final updatedReqs = state.shareRequests
        .map((r) => r.id == requestId ?
            ShareRequest(
              id: r.id,
              fromUserId: r.fromUserId,
              toUserId: r.toUserId,
              status: 'accepted',
              timestamp: r.timestamp,
              metadata: r.metadata,
            ) : r)
        .toList();
    final collab = Collaboration(
      id: requestId,
      user1: req.fromUserId,
      user2: req.toUserId,
      since: DateTime.now(),
    );
    state = state.copyWith(
      shareRequests: updatedReqs,
      collaborations: [...state.collaborations, collab],
    );
    await _sync();
    // Notify that request was accepted
    NotificationService().showSimpleNotification(
      id: requestId,
      title: 'Share Request Accepted',
      body: 'Your share request has been accepted.',
    );
  }

  /// Decline the share request [requestId].
  Future<void> declineRequest(String requestId) async {
    final updatedReqs = state.shareRequests
        .map((r) => r.id == requestId ?
            ShareRequest(
              id: r.id,
              fromUserId: r.fromUserId,
              toUserId: r.toUserId,
              status: 'declined',
              timestamp: r.timestamp,
              metadata: r.metadata,
            ) : r)
        .toList();
    state = state.copyWith(shareRequests: updatedReqs);
    await _sync();
  }
  /// Share an existing task [taskId] from [fromUserId] to [toUserId].
  Future<void> shareTask({
    required String taskId,
    required String fromUserId,
    required String toUserId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final shared = SharedTask(
      id: id,
      taskId: taskId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      timestamp: DateTime.now(),
    );
    final updated = [...state.sharedTasks, shared];
    state = state.copyWith(sharedTasks: updated);
    await _sync();
    // Notify both parties
    NotificationService().showSimpleNotification(
      id: id,
      title: 'Task Shared',
      body: 'A task was shared with user $toUserId',
    );
  }
  /// Add a comment [text] by [authorId] to shared task [sharedTaskId].
  Future<void> addComment({
    required String sharedTaskId,
    required String authorId,
    required String text,
  }) async {
    final updatedList = state.sharedTasks.map((st) {
      if (st.id != sharedTaskId) return st;
      // Retrieve existing comments
      final existing = (st.metadata['comments'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ?? [];
      final commentId = DateTime.now().millisecondsSinceEpoch.toString();
      final newEntry = {
        'id': commentId,
        'authorId': authorId,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final updatedMeta = Map<String, dynamic>.from(st.metadata)
        ..['comments'] = [...existing, newEntry];
      return SharedTask(
        id: st.id,
        taskId: st.taskId,
        fromUserId: st.fromUserId,
        toUserId: st.toUserId,
        timestamp: st.timestamp,
        metadata: updatedMeta,
      );
    }).toList();
    state = state.copyWith(sharedTasks: updatedList);
    await _sync();
    NotificationService().showSimpleNotification(
      id: sharedTaskId,
      title: 'New Comment',
      body: 'A comment was added to a shared task.',
    );
  }

  /// Internal sync to persist state in JSON file.
  Future<void> _sync() async {
    await _service.saveAll(
      shareRequests: state.shareRequests,
      collaborations: state.collaborations,
      sharedTasks: state.sharedTasks,
    );
  }
}

/// Provider exposing share data state.
final sharedDataProvider =
    StateNotifierProvider<SharedDataNotifier, SharedDataState>(
  (ref) => SharedDataNotifier(),
);