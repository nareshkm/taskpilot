import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/user.dart';
import '../../models/share_request.dart';
import '../../models/collaboration.dart';
import '../../providers/shared_data_provider.dart';
import '../../app.dart';
import '../../providers/auth_provider.dart';

class InvitationsPage extends ConsumerStatefulWidget {
  const InvitationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends ConsumerState<InvitationsPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final sharedState = ref.watch(sharedDataProvider);

    final pendingRequests = sharedState.shareRequests
        .where((r) => r.status == 'pending')
        .toList();

    final collaborations = sharedState.collaborations
        .where((c) => c.user1 == currentUser.id || c.user2 == currentUser.id)
        .toList();

    final combinedList = [
      ...pendingRequests.map((r) => _ListItem.pending(r)),
      ...collaborations.map((c) => _ListItem.collaborator(c)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: combinedList.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No Invitations or Collaborators Yet.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: combinedList.length,
        itemBuilder: (context, index) {
          final item = combinedList[index];
          return _buildListItem(context, ref, currentUser, item);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSendRequestDialog(context, currentUser.id),
        child: const Icon(Icons.send),
        tooltip: 'Send Invite',
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, WidgetRef ref, User user, _ListItem item) {
    switch (item.type) {
      case _ListItemType.pending:
        final r = item.request!;
        final isIncoming = r.toUserId == user.id;
        final otherUserId = isIncoming ? r.fromUserId : r.toUserId;
        final otherUser = dummyUsers.firstWhere(
              (u) => u.id == otherUserId,
          orElse: () => dummyUsers.first,
        );

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text(otherUser.name[0])),
            title: Text(otherUser.name),
            subtitle: Text(isIncoming ? 'Incoming Invitation' : 'Sent Invitation'),
            trailing: isIncoming
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    ref.read(sharedDataProvider.notifier).acceptRequest(r.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    ref.read(sharedDataProvider.notifier).declineRequest(r.id);
                  },
                ),
              ],
            )
                : null,
          ),
        );

      case _ListItemType.collaborator:
        final c = item.collaboration!;
        final otherId = c.user1 == user.id ? c.user2 : c.user1;
        final other = dummyUsers.firstWhere(
              (u) => u.id == otherId,
          orElse: () => dummyUsers.first,
        );

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text(other.name[0])),
            title: Text(other.name),
            subtitle:
            Text('Collaborator since ${DateFormat.yMMMd().format(c.since)}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              tooltip: 'Revoke Collaboration',
              onPressed: () {
                _confirmRevokeCollaboration(context, ref, c.id);
              },
            ),
          ),
        );
    }
  }

  void _confirmRevokeCollaboration(
      BuildContext context, WidgetRef ref, String collaborationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Collaboration'),
        content: const Text('Are you sure you want to revoke this collaboration?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(sharedDataProvider.notifier)
                  .revokeCollaboration(collaborationId);
              Navigator.pop(ctx);
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _showSendRequestDialog(BuildContext context, String fromUserId) {
    String? selected;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Invitation'),
        content: DropdownButtonFormField<String>(
          items: dummyUsers
              .where((u) => u.id != fromUserId)
              .map((u) => DropdownMenuItem(
            value: u.id,
            child: Text(u.name),
          ))
              .toList(),
          onChanged: (v) => selected = v,
          decoration: const InputDecoration(labelText: 'Select User to Invite'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selected != null) {
                ref.read(sharedDataProvider.notifier).sendRequest(
                  fromUserId: fromUserId,
                  toUserId: selected!,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

// Helper classes to combine pending invitations and collaborators into a single list

enum _ListItemType { pending, collaborator }

class _ListItem {
  final _ListItemType type;
  final ShareRequest? request;
  final Collaboration? collaboration;

  _ListItem.pending(this.request)
      : type = _ListItemType.pending,
        collaboration = null;

  _ListItem.collaborator(this.collaboration)
      : type = _ListItemType.collaborator,
        request = null;
}
