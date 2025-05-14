import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../models/user.dart';
import '../../models/share_request.dart';
import '../../models/collaboration.dart';
import '../../providers/shared_data_provider.dart';

/// Page for managing share invitations (incoming, sent, collaborators).
class InvitationsPage extends ConsumerStatefulWidget {
  const InvitationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InvitationsPage> createState() => _InvitationsPageState();
}

enum InvitationTab { incoming, sent, collaborators }

class _InvitationsPageState extends ConsumerState<InvitationsPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final sharedState = ref.watch(sharedDataProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invitations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Incoming'),
              Tab(text: 'Sent'),
              Tab(text: 'Collaborators'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIncoming(currentUser, sharedState.shareRequests),
            _buildSent(currentUser, sharedState.shareRequests),
            _buildCollaborators(currentUser, sharedState.collaborations),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showSendRequestDialog(context, currentUser.id),
          child: const Icon(Icons.send),
          tooltip: 'Send Invite',
        ),
      ),
    );
  }

  Widget _buildIncoming(User user, List<ShareRequest> requests) {
    final list = requests
        .where((r) => r.toUserId == user.id && r.status == 'pending')
        .toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final r = list[i];
        final from = dummyUsers.firstWhere(
            (u) => u.id == r.fromUserId,
            orElse: () => dummyUsers.first);
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text('From ${from.name}'),
          subtitle: Text('Status: ${r.status}'),
          trailing: Row(
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
          ),
        );
      },
    );
  }

  Widget _buildSent(User user, List<ShareRequest> requests) {
    final list = requests.where((r) => r.fromUserId == user.id).toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final r = list[i];
        final to = dummyUsers.firstWhere(
            (u) => u.id == r.toUserId,
            orElse: () => dummyUsers.first);
        return ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text('To ${to.name}'),
          subtitle: Text('Status: ${r.status}'),
        );
      },
    );
  }

  Widget _buildCollaborators(User user, List<Collaboration> collabs) {
    final list = collabs
        .where((c) => c.user1 == user.id || c.user2 == user.id)
        .toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final c = list[i];
        final otherId = c.user1 == user.id ? c.user2 : c.user1;
        final other = dummyUsers.firstWhere(
            (u) => u.id == otherId,
            orElse: () => dummyUsers.first);
        return ListTile(
          leading: const Icon(Icons.group),
          title: Text(other.name),
          subtitle: Text('Since ${DateFormat.yMMMd().format(c.since)}'),
        );
      },
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
          decoration:
              const InputDecoration(labelText: 'Select User to Invite'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                if (selected != null) {
                  ref
                      .read(sharedDataProvider.notifier)
                      .sendRequest(
                        fromUserId: fromUserId,
                        toUserId: selected!,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Send')),
        ],
      ),
    );
  }
}