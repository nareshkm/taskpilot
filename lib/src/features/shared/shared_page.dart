import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../models/user.dart';
import '../../models/share_request.dart';
import '../../models/collaboration.dart';
import '../../models/shared_task.dart';
import '../../models/task.dart';
import '../../providers/shared_data_provider.dart';
import '../../features/dashboard/todo_provider.dart';

/// A page for handling share requests, collaborators, and shared tasks.
class SharedPage extends ConsumerStatefulWidget {
  const SharedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SharedPage> createState() => _SharedPageState();
}

/// The sections available in the SharedPage.
enum SharedSubPage { incoming, sent, collaborators, sharedWithMe, sharedByMe }

class _SharedPageState extends ConsumerState<SharedPage> {
  SharedSubPage _subPage = SharedSubPage.incoming;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final state = ref.watch(sharedDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared'),
        actions: [
          PopupMenuButton<SharedSubPage>(
            icon: const Icon(Icons.menu),
            onSelected: (page) => setState(() => _subPage = page),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: SharedSubPage.incoming,
                  child: Text('Incoming Requests')),
              const PopupMenuItem(
                  value: SharedSubPage.sent, child: Text('Sent Requests')),
              const PopupMenuItem(
                  value: SharedSubPage.collaborators,
                  child: Text('Collaborators')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: SharedSubPage.sharedWithMe,
                  child: Text('Tasks Shared With Me')),
              const PopupMenuItem(
                  value: SharedSubPage.sharedByMe,
                  child: Text('Tasks I Shared')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Request',
            onPressed: () => _showSendRequestDialog(context, currentUser.id),
          ),
        ],
      ),
      body: _buildSubPage(context, currentUser, state),
    );
  }

  Widget _buildSubPage(BuildContext context, User currentUser,
      SharedDataState sharedState) {
    switch (_subPage) {
      case SharedSubPage.incoming:
        final incoming = sharedState.shareRequests
            .where((r) => r.toUserId == currentUser.id && r.status == 'pending')
            .toList();
        return ListView.builder(
          itemCount: incoming.length,
          itemBuilder: (ctx, i) {
            final r = incoming[i];
            final from = dummyUsers.firstWhere(
                (u) => u.id == r.fromUserId,
                orElse: () => dummyUsers.first);
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text('Request from ${from.name}'),
              subtitle: Text('Status: ${r.status}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
              ]),
            );
          },
        );
      case SharedSubPage.sent:
        final sent = sharedState.shareRequests
            .where((r) => r.fromUserId == currentUser.id)
            .toList();
        return ListView.builder(
          itemCount: sent.length,
          itemBuilder: (ctx, i) {
            final r = sent[i];
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
      case SharedSubPage.collaborators:
        final collabs = sharedState.collaborations
            .where((c) => c.user1 == currentUser.id || c.user2 == currentUser.id)
            .toList();
        return ListView.builder(
          itemCount: collabs.length,
          itemBuilder: (ctx, i) {
            final c = collabs[i];
            final otherId = c.user1 == currentUser.id ? c.user2 : c.user1;
            final other = dummyUsers.firstWhere(
                (u) => u.id == otherId,
                orElse: () => dummyUsers.first);
            return ListTile(
              leading: const Icon(Icons.group),
              title: Text(other.name),
              subtitle:
                  Text('Since ${DateFormat.yMMMd().format(c.since)}'),
            );
          },
        );
      case SharedSubPage.sharedWithMe:
      case SharedSubPage.sharedByMe:
        final tasksAll = ref.watch(todoListProvider);
        final list = sharedState.sharedTasks.where((st) =>
            _subPage == SharedSubPage.sharedByMe
                ? st.fromUserId == currentUser.id
                : st.toUserId == currentUser.id);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Partner')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Shared On')),
            ],
            rows: list.map((st) {
              final t = tasksAll.firstWhere(
                (t) => t.id == st.taskId,
                orElse: () => Task(
                  id: st.taskId,
                  title: '[missing]',
                  date: st.timestamp,
                  isRepetitive: false,
                  ownerId: st.fromUserId,
                ),
              );
              final partnerId = _subPage == SharedSubPage.sharedByMe
                  ? st.toUserId
                  : st.fromUserId;
              final partner = dummyUsers.firstWhere(
                (u) => u.id == partnerId,
                orElse: () => dummyUsers.first,
              );
              final comments = (st.metadata['comments']
                      as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ?? [];
              return DataRow(
                onSelectChanged: (_) => _showCommentsDialog(
                    context, st.id),
                cells: [
                  DataCell(Row(children: [
                    Text(t.title),
                    if (comments.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.comment, size: 16),
                      Text('${comments.length}'),
                    ]
                  ])),
                  DataCell(Text(partner.name)),
                  DataCell(Text(DateFormat.yMd().format(t.date))),
                  DataCell(Text(DateFormat.jm().format(st.timestamp))),
                ],
              );
            }).toList(),
          ),
        );
    }
  }

  void _showSendRequestDialog(BuildContext context, String fromUserId) {
    String? selectedUserId;
    final collaborators = ref
        .read(sharedDataProvider)
        .collaborations
        .where((c) => c.user1 == fromUserId || c.user2 == fromUserId)
        .toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Collaboration Request'),
        content: DropdownButtonFormField<String>(
          items: dummyUsers
              .where((u) => u.id != fromUserId)
              .map((u) => DropdownMenuItem(
                    value: u.id,
                    child: Text(u.name),
                  ))
              .toList(),
          onChanged: (v) => selectedUserId = v,
          decoration: const InputDecoration(
              labelText: 'Select User'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                if (selectedUserId != null) {
                  ref
                      .read(sharedDataProvider.notifier)
                      .sendRequest(
                        fromUserId: fromUserId,
                        toUserId: selectedUserId!,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Send')),
        ],
      ),
    );
  }

  void _showCommentsDialog(
      BuildContext context, String sharedTaskId) {
    final st = ref
        .read(sharedDataProvider)
        .sharedTasks
        .firstWhere((s) => s.id == sharedTaskId);
    final comments = (st.metadata['comments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comments'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    final c = comments[i];
                    final author = dummyUsers.firstWhere(
                        (u) => u.id == c['authorId'] as String,
                        orElse: () => dummyUsers.first);
                    return ListTile(
                      title: Text(author.name),
                      subtitle: Text(c['text'] as String),
                      trailing: Text(
                          DateFormat.jm()
                              .format(DateTime.parse(c['timestamp'] as String))),
                    );
                  },
                ),
              ),
              TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: 'Add a comment'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
          ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final currentUser = ref.read(currentUserProvider);
                  ref.read(sharedDataProvider.notifier).addComment(
                        sharedTaskId: sharedTaskId,
                        authorId: currentUser.id,
                        text: text,
                      );
                }
                Navigator.pop(ctx);
              },
              child: const Text('Submit')),
        ],
      ),
    );
  }
}