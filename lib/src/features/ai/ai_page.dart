import 'package:flutter/material.dart';

/// AI Assistant page where users can input or record tasks to be parsed.
class AIPage extends StatefulWidget {
  const AIPage({Key? key}) : super(key: key);

  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMicPressed() {
    // TODO: Integrate audio recording and speech-to-text
  }

  void _onSubmit() {
    final input = _controller.text;
    // TODO: Parse input into tasks and present options
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Describe tasks to create...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: _onMicPressed,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}