import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../models/task.dart';
import '../../models/shared_task.dart';
import '../../models/user.dart';
import '../../providers/shared_data_provider.dart';
import '../dashboard/todo_provider.dart';
import '../../providers/auth_provider.dart';

/// Page showing tasks shared with me and tasks I shared, with search, zebra striping, and actions.
class SharedPage extends ConsumerStatefulWidget {
  const SharedPage({Key? key}) : super(key: key);
  @override
  ConsumerState<SharedPage> createState() => _SharedPageState();
}

class _SharedPageState extends ConsumerState<SharedPage> {
  bool _searching = false;
  String _search = '';
  int _sortCol = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final sharedState = ref.watch(sharedDataProvider);
    final tasksAll = ref.watch(todoListProvider);
    final withMe = sharedState.sharedTasks.where((st) => st.toUserId == currentUser.id).toList();
    final byMe = sharedState.sharedTasks.where((st) => st.fromUserId == currentUser.id).toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: !_searching
              ? const Text('Shared Tasks')
              : TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Search...'),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                ),
          actions: [
            IconButton(
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: () => setState(() { _searching = !_searching; if (!_searching) _search = ''; }),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'With Me'), Tab(text: 'By Me')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTable(withMe, tasksAll, currentUser),
            _buildTable(byMe, tasksAll, currentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<SharedTask> list, List<Task> tasksAll, User user) {
    // filter
    var rows = list.where((st) {
      final t = tasksAll.firstWhere((t) => t.id == st.taskId, orElse: () => Task(id: st.taskId, title: '', date: st.timestamp, isRepetitive: false, ownerId: st.fromUserId));
      final p = dummyUsers.firstWhere((u) => u.id == (st.fromUserId == user.id ? st.toUserId : st.fromUserId));
      if (_search.isNotEmpty) {
        return t.title.toLowerCase().contains(_search) || p.name.toLowerCase().contains(_search);
      }
      return true;
    }).toList();
    if (rows.isEmpty) return const Center(child: Text('No results.'));
    // sort
    rows.sort((a, b) {
      int c;
      switch (_sortCol) {
        case 0:
          c = tasksAll.firstWhere((t) => t.id == a.taskId).title
              .compareTo(tasksAll.firstWhere((t) => t.id == b.taskId).title);
          break;
        case 1:
          c = dummyUsers.firstWhere((u) => u.id == (a.fromUserId == user.id ? a.toUserId : a.fromUserId)).name
              .compareTo(dummyUsers.firstWhere((u) => u.id == (b.fromUserId == user.id ? b.toUserId : b.fromUserId)).name);
          break;
        case 2:
          c = tasksAll.firstWhere((t) => t.id == a.taskId).date
              .compareTo(tasksAll.firstWhere((t) => t.id == b.taskId).date);
          break;
        case 3:
          c = a.timestamp.compareTo(b.timestamp);
          break;
        default:
          c = 0;
      }
      return _sortAsc ? c : -c;
    });
    // column widths
    const w = [200.0, 150.0, 120.0, 120.0, 100.0, 150.0];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: _sortCol,
          sortAscending: _sortAsc,
          columns: List.generate(6, (i) {
            final labels = ['Title', 'Partner', 'Date', 'Shared On', 'Status', 'Actions'];
            return DataColumn(
              label: InkWell(
                onTap: () => setState(() {
                  if (_sortCol == i) _sortAsc = !_sortAsc;
                  else { _sortCol = i; _sortAsc = true; }
                }),
                child: Row(children: [
                  Text(labels[i]),
                  if (_sortCol == i)
                    Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                ]),
              ),
            );
          }),
          rows: List<DataRow>.generate(rows.length, (idx) {
            final st = rows[idx];
            final t = tasksAll.firstWhere((t) => t.id == st.taskId, orElse: () => Task(id: st.taskId, title: '[missing]', date: st.timestamp, isRepetitive: false, ownerId: st.fromUserId));
            final p = dummyUsers.firstWhere((u) => u.id == (st.fromUserId == user.id ? st.toUserId : st.fromUserId));
            final comments = (st.metadata['comments'] as List<dynamic>?)?.length ?? 0;
            final completed = t.completed;
            return DataRow(
              color: MaterialStateProperty.resolveWith((_) => idx.isEven
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Theme.of(context).colorScheme.surface),
              onSelectChanged: (_) => _showCommentsDialog(t, st),
              cells: [
                DataCell(Container(width: w[0], child: Text(t.title))),
                DataCell(Container(width: w[1], child: Text(p.name))),
                DataCell(Container(width: w[2], child: Text(DateFormat.yMMMd().format(t.date)))),
                DataCell(Container(width: w[3], child: Text(DateFormat.jm().format(st.timestamp)))),
                DataCell(Container(width: w[4], child: Chip(
                  label: Text(completed?'Completed':'Pending'),
                  backgroundColor: completed
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.secondary,
                  visualDensity: VisualDensity.compact,
                ))),
                DataCell(Container(width: w[5], child: Row(children: [
                  IconButton(icon: const Icon(Icons.comment), onPressed: () => _showCommentsDialog(t, st)),
                  IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
                ]))),
              ],
            );
          }),
        ),
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
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    final c = comments[i];
                    final author = dummyUsers.firstWhere((u) => u.id == c['authorId'] as String);
                    return ListTile(
                      title: Text(author.name),
                      subtitle: Text(c['text'] as String),
                      trailing: Text(DateFormat.jm().format(DateTime.parse(c['timestamp'] as String))),
                    );
                  },
                ),
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Add a comment'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              final user = ref.read(currentUserProvider);
              ref.read(sharedDataProvider.notifier).addComment(
                    sharedTaskId: st.id,
                    authorId: user.id,
                    text: text,
                  );
            }
            Navigator.pop(ctx);
          }, child: const Text('Submit'))
        ],
      ),
    );
  }
}