import 'dart:async';
import 'package:flutter/material.dart';
import '../services/dictionary_api.dart';
import '../widgets/search_bar.dart';
import '../widgets/definition_card.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final DictionaryApiService _apiService = DictionaryApiService();
  
  DictionaryEntry? _entry;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  Future<void> _handleSearch() async {
    final word = _searchController.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _entry = null;
    });

    final result = await _apiService.fetchDefinition(word);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          _entry = result;
        } else {
          _errorMessage = "Sorry, we couldn't find a definition for that word.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 60),
          CustomSearchBar(
            controller: _searchController,
            onSearch: _handleSearch,
          ),
          const SizedBox(height: 60),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Colors.white24),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (_entry != null) {
      return DefinitionCard(entry: _entry!);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: Opacity(
          opacity: 0.3,
          child: Column(
            children: [
              const Icon(Icons.menu_book_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                "Type a word to begin",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
