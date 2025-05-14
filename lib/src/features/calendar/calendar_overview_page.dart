import 'package:flutter/material.dart';

/// Page showing a calendar overview where users can navigate dates.
class CalendarOverviewPage extends StatelessWidget {
  const CalendarOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Overview'),
      ),
      body: const Center(
        child: Text(
          'Calendar overview will be displayed here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}