import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'features/dashboard/dashboard_page.dart';
import 'features/dashboard/todo_provider.dart';
import 'features/dashboard/dashboard_providers.dart';
import 'features/dashboard/goal_provider.dart';
import 'features/dashboard/goal_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/reports/reports_page.dart';

import 'theme.dart';
import 'package:flutter/foundation.dart';
import 'features/shared/shared_page.dart';
import 'features/calendar/calendar_overview_page.dart';
import 'features/ai/ai_page.dart';
import 'features/shared/invitations_page.dart';

import 'models/user.dart';

// Notifier holding the current user; replaceable by real auth in future.
class CurrentUserNotifier extends StateNotifier<User> {
  CurrentUserNotifier() : super(dummyUsers.first);
}
/// Provider for the currently signed-in user (dummy for now).
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User>(
  (ref) => CurrentUserNotifier(),
);
/// Provider for managing the app's theme mode (light/dark/system).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class TaskPilotApp extends ConsumerWidget {
  const TaskPilotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'TaskPilot',
      theme: slackLightTheme,
      darkTheme: slackDarkTheme,
      themeMode: themeMode,
      home: _buildHome(),
    );
  }
  
  /// Selects the home page based on whether onboarding has been seen.
  Widget _buildHome() {
    final seen = Hive.box('settings').get('seenOnboarding', defaultValue: false) as bool;
    return seen ? const MainPage() : const OnboardingPage();
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;

  static final List<Widget> _pages = [
    DashboardPage(),         // Home
    SharedPage(),            // Shared tasks
    CalendarOverviewPage(),  // Calendar overview
    AIPage(),                // AI assistant
    ReportsPage(),           // Reports (extra)
    GoalPage(),              // Goals (extra)
    ProfilePage(),           // Profile (extra)
  ];

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    // Main scaffold with bottom navigation and optional drawer
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('TaskPilot'),
        actions: [
          // Toggle light/dark mode
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final current = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
                  current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      drawer: isWeb
          ? null
          : Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Consumer(
                builder: (ctx, ref, _) {
                  final currentUser = ref.watch(currentUserProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Signed in as', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      DropdownButton<User>(
                        value: currentUser,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: dummyUsers
                            .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.name),
                        ))
                            .toList(),
                        onChanged: (u) {
                          if (u != null) {
                            ref.read(currentUserProvider.notifier).state = u;
                          }
                        },
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        underline: Container(),
                        iconEnabledColor: Colors.white,
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                setState(() => _currentIndex = 4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Goals'),
              onTap: () {
                setState(() => _currentIndex = 5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                setState(() => _currentIndex = 6);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Invitations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InvitationsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex < 4 ? _currentIndex : 0,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.share), label: 'Shared'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI'),
        ],
      ),
    );
    if (isWeb) {
      // Permanent side menu for web with user switcher
      return Row(
        children: [
          Material(
            color: Theme.of(context).colorScheme.background,
            child: SizedBox(
              width: 240,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                    child: Consumer(
                      builder: (ctx, ref, _) {
                        final currentUser = ref.watch(currentUserProvider);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Signed in as', style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            DropdownButton<User>(
                              value: currentUser,
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              items: dummyUsers
                                  .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u.name),
                              ))
                                  .toList(),
                              onChanged: (u) {
                                if (u != null) {
                                  ref.read(currentUserProvider.notifier).state = u;
                                }
                              },
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              underline: Container(),
                              iconEnabledColor: Colors.white,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Reports'),
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Goals'),
                    onTap: () => setState(() => _currentIndex = 5),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () => setState(() => _currentIndex = 6),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text('Invitations'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InvitationsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: scaffold),
        ],
      );
    }
    return scaffold;
  }
}


// ReportsPage is implemented in features/reports/reports_page.dart


/// Profile page showing motivational badges and stats.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Goals achieved
    final goals = ref.watch(goalListProvider);
    final achieved = goals.where((g) => g.progress >= g.target).length;
    // Habit streak (reuse logic)
    final todoTasks = ref.watch(todoListProvider);
    final priorityTasks = ref.watch(topPrioritiesProvider);
    final allTasks = [...todoTasks, ...priorityTasks];
    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 7; i++) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final count = allTasks.where((t) {
        if (!t.completed) return false;
        if (t.isRepetitive) return true;
        return t.date.year == day.year &&
            t.date.month == day.month &&
            t.date.day == day.day;
      }).length;
      if (count >= 3) {
        streak++;
      } else {
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Motivational Badges', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.secondary),
            title: Text('Goals Achieved'),
            trailing: Text('$achieved'),
          ),
          ListTile(
            leading: Icon(Icons.timeline, color: Theme.of(context).colorScheme.secondary),
            title: Text('Habit Streak'),
            trailing: Text('$streak days'),
          ),
        ],
      ),
    );
  }
}