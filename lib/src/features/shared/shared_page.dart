import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../models/user.dart';
import '../../models/shared_task.dart';
import '../../models/task.dart';
import '../../providers/shared_data_provider.dart';
import '../dashboard/todo_provider.dart';

/// Page showing tasks shared with me and tasks I shared, in two tabs.
class SharedPage extends ConsumerStatefulWidget {
  const SharedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SharedPage> createState() => _SharedPageState();
}

enum SharedTab { withMe, byMe }

class _SharedPageState extends ConsumerState<SharedPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final sharedState = ref.watch(sharedDataProvider);
    final tasksAll = ref.watch(todoListProvider);
    final sharedWithMe = sharedState.sharedTasks
        .where((st) => st.toUserId == currentUser.id)
        .toList();
    final sharedByMe = sharedState.sharedTasks
        .where((st) => st.fromUserId == currentUser.id)
        .toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shared Tasks'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTable(context, sharedWithMe, tasksAll, currentUser.id),
            _buildTable(context, sharedByMe, tasksAll, currentUser.id),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<SharedTask> list,
      List<Task> tasksAll, String currentUserId) {
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
          final task = tasksAll.firstWhere(
            (t) => t.id == st.taskId,
            orElse: () => Task(
              id: st.taskId,
              title: '[missing]',
              date: st.timestamp,
              isRepetitive: false,
              ownerId: st.fromUserId,
            ),
          );
          final partnerId = st.fromUserId == currentUserId
              ? st.toUserId
              : st.fromUserId;
          final partner = dummyUsers.firstWhere(
            (u) => u.id == partnerId,
            orElse: () => dummyUsers.first,
          );
          final comments =
              (st.metadata['comments'] as List<dynamic>?) ?? [];
          return DataRow(
            onSelectChanged: (_) => _showCommentsDialog(task, st),
            cells: [
              DataCell(Row(children: [
                Text(task.title),
                if (comments.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.comment, size: 16),
                  Text('${comments.length}'),
                ],
              ])),
              DataCell(Text(partner.name)),
              DataCell(Text(DateFormat.yMMMd().format(task.date))),
              DataCell(Text(DateFormat.jm().format(st.timestamp))),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showCommentsDialog(Task task, SharedTask st) {
    final comments = (st.metadata['comments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ?? [];
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comments for "${task.title}"'),
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
                      trailing: Text(DateFormat.jm()
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
                  ref
                      .read(sharedDataProvider.notifier)
                      .addComment(
                        sharedTaskId: st.id,
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

  Widget _buildTable(BuildContext context, List<SharedTask> list,
      List<Task> tasksAll, String currentUserId) {
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
          final partnerId = st.fromUserId == currentUserId
              ? st.toUserId
              : st.fromUserId;
          final partner = dummyUsers.firstWhere(
            (u) => u.id == partnerId,
            orElse: () => dummyUsers.first,
          );
          final comments = (st.metadata['comments'] as List<dynamic>?) ?? [];
          return DataRow(
            cells: [
              DataCell(Row(children: [
                Text(t.title),
                if (comments.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.comment, size: 16),
                  Text('${comments.length}'),
                ],
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