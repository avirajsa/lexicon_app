import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String hint;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hint = "Search for a word...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: onSearch,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
