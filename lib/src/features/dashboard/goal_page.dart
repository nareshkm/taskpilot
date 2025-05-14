import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_item.dart';
import 'goal_provider.dart';

/// Page for displaying and managing user goals.
class GoalPage extends ConsumerWidget {
  const GoalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalListProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: goals.isEmpty
            ? Center(child: Text('No goals set.', style: Theme.of(context).textTheme.bodyMedium))
            : ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progress = goal.progress / goal.target;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(goal.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 4),
                          Text('${goal.progress} / ${goal.target}'),
                        ],
                      ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge for completed goal
                      if (goal.progress >= goal.target)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.emoji_events,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => ref.read(goalListProvider.notifier).incrementProgress(goal.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => ref.read(goalListProvider.notifier).remove(goal.id),
                      ),
                    ],
                  ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Goal title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Target (e.g. 10)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final target = int.tryParse(targetController.text) ?? 0;
              if (title.isNotEmpty && target > 0) {
                ref.read(goalListProvider.notifier).add(title, target);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}