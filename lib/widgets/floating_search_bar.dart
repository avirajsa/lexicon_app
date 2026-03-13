import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';

class FloatingSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final FocusNode? focusNode;
  final String hint;

  const FloatingSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.focusNode,
    this.hint = "Look up a word",
  });

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              if (val.recognizedWords.isNotEmpty) {
                widget.controller.text = val.recognizedWords;
                if (val.finalResult) {
                  _isListening = false;
                  widget.onSearch();
                }
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withAlpha(40) 
                : Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onSubmitted: (_) => widget.onSearch(),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: _isListening ? "Listening..." : widget.hint,
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _isListening 
                ? Colors.redAccent.withAlpha(150) 
                : Theme.of(context).hintColor,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: IconButton(
            icon: Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded, 
              color: _isListening ? Colors.redAccent : AppTheme.iconColor,
              size: 24,
            ),
            onPressed: _listen,
          ),
          suffixIcon: widget.controller.text.isNotEmpty 
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded, 
                  color: Theme.of(context).disabledColor, 
                  size: 20
                ),
                onPressed: () {
                  widget.controller.clear();
                  setState(() {});
                },
              )
            : const SizedBox(width: 48),
        ),
        onChanged: (text) {
          setState(() {});
        },
      ),
    );
  }
}
