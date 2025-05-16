import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/recognized_texts_provider.dart';
import '../dashboard/todo_provider.dart';

class AIPage extends ConsumerStatefulWidget {
  const AIPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AIPage> createState() => _AIPageState();
}

class _AIPageState extends ConsumerState<AIPage> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMicPressed() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (mounted) setState(() => _isListening = false);
          print('Speech recognition error: $error');
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            final text = result.recognizedWords.trim();
            if (mounted) {
              setState(() => _controller.text = text);
            }
          },
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _onAddPressed() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(recognizedTextsProvider.notifier).addText(text);
    _controller.clear();
  }

  void _confirmTask(String text) {
    final todoNotifier = ref.read(todoListProvider.notifier);
    todoNotifier.add(
      text,
      date: DateTime.now(),
      ownerId: 'system', // Replace with the correct user ID if needed
    );
    ref.read(recognizedTextsProvider.notifier).removeText(text);
  }

  void _editTask(String text) {
    _controller.text = text;
    ref.read(recognizedTextsProvider.notifier).removeText(text);
  }

  void _cancelTask(String text) {
    ref.read(recognizedTextsProvider.notifier).removeText(text);
  }

  Widget _buildRecognizedWidgets() {
    final recognizedTexts = ref.watch(recognizedTextsProvider);
    if (recognizedTexts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: recognizedTexts.map((text) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _confirmTask(text),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editTask(text),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _cancelTask(text),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Describe tasks to create...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildRecognizedWidgets(),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: _isListening ? Colors.red : Colors.black,
                  ),
                  iconSize: 28,
                  onPressed: _onMicPressed,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _onAddPressed,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
