import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecognizedTextsNotifier extends StateNotifier<List<String>> {
  RecognizedTextsNotifier() : super([]);

  void addText(String text) {
    if (!state.contains(text)) {
      state = [...state, text];
    }
  }

  void removeText(String text) {
    state = state.where((t) => t != text).toList();
  }

  void clearAll() {
    state = [];
  }
}

final recognizedTextsProvider =
StateNotifierProvider<RecognizedTextsNotifier, List<String>>(
        (ref) => RecognizedTextsNotifier());
