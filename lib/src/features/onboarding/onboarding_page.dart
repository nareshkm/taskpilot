import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../dashboard/goal_page.dart';
import '../dashboard/goal_provider.dart';
import '../dashboard/wellness_provider.dart';
import '../../models/wellness_item.dart';
// import '../dashboard/goal_page.dart'; // duplicate import removed
import '../../app.dart';

/// Onboarding wizard shown on first launch.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  final _goalController = TextEditingController();
  final _targetController = TextEditingController();
  int _initialRating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        currentStep: _step,
        onStepContinue: _nextStep,
        onStepCancel: _prevStep,
        steps: [
          Step(
            title: const Text('Welcome'),
            content: const Text('Welcome to TaskPilot! Let’s get started.'),
          ),
          Step(
            title: const Text('Set a Goal'),
            content: Column(
              children: [
                TextField(
                  controller: _goalController,
                  decoration: const InputDecoration(labelText: 'Goal title'),
                ),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Your Wellness'),
            content: Column(
              children: [
                Text('Rate your day'),
                Slider(
                  value: _initialRating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$_initialRating',
                  onChanged: (v) => setState(() => _initialRating = v.toInt()),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('All Set!'),
            content: const Text('You’re ready to go!'),
          ),
        ],
      ),
    );
  }

  void _nextStep() async {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      // Save onboarding flag
      final box = Hive.box('settings');
      box.put('seenOnboarding', true);
      // If goal entered, add it
      final goal = _goalController.text.trim();
      final target = int.tryParse(_targetController.text) ?? 0;
      if (goal.isNotEmpty && target > 0) {
        ref.read(goalListProvider.notifier).add(goal, target);
      }
      // Add wellness baseline
      final selectedDate = DateTime.now();
      final id = selectedDate.millisecondsSinceEpoch.toString();
      ref.read(wellnessListProvider.notifier).upsert(
        WellnessItem(
          id: id,
          date: selectedDate,
          productivity: _initialRating,
          mood: _initialRating,
          health: _initialRating,
          fitness: _initialRating,
          family: _initialRating,
          fun: _initialRating,
          spiritual: _initialRating,
        ),
      );
      // Navigate to main
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }
}