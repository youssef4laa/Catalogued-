import 'package:flutter/material.dart';
import '../models/watchlist_item.dart';
import '../models/tmdb_metadata.dart';
import '../services/storage_service_factory.dart';
import '../services/tmdb_service.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late StorageInterface _storageService;
  List<WatchlistItem> _items = [];

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageServiceFactory.createStorageService();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _storageService.getWatchlistItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AddItemDialog(),
    );

    if (result != null) {
      final newItem = WatchlistItem(
        id: DateTime.now().toString(),
        title: result['title']!,
        type: result['type']!,
        dateAdded: DateTime.now(),
        notes: result['notes'],
        metadata: result['metadata'] != null
            ? TMDBMetadata.fromJson(result['metadata'])
            : null,
      );

      await _storageService.addWatchlistItem(newItem);
      _loadItems();
    }
  }

  Future<void> _toggleItemStatus(WatchlistItem item) async {
    final updatedItem = WatchlistItem(
      id: item.id,
      title: item.title,
      type: item.type,
      completed: !item.completed,
      dateAdded: item.dateAdded,
      notes: item.notes,
    );

    await _storageService.updateWatchlistItem(updatedItem);
    _loadItems();
  }

  Future<void> _deleteItem(String id) async {
    await _storageService.removeWatchlistItem(id);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogued'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.type),
                if (item.notes?.isNotEmpty ?? false)
                  Text(
                    item.notes!,
                    style: TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: item.completed,
                  onChanged: (_) => _toggleItemStatus(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(item.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = 'movie';
  final _tmdbService = TMDBService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _onSearchChanged(String value) async {
    if (value.length < 2 || (_selectedType != 'movie' && _selectedType != 'tv show')) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _tmdbService.searchMovie(value);
      setState(() {
        _searchResults = (results['results'] as List)
            .where((result) =>
                (result['media_type'] == 'movie' && _selectedType == 'movie') ||
                (result['media_type'] == 'tv' && _selectedType == 'tv show'))
            .take(5)
            .toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final metadata = TMDBMetadata(
      tmdbId: result['id'].toString(),
      posterPath: result['poster_path'],
      overview: result['overview'],
      rating: (result['vote_average'] as num?)?.toDouble(),
      releaseDate: result['release_date'] ?? result['first_air_date'],
      genres: [], // We'll need to fetch full details to get genres
    );

    _titleController.text = result['title'] ?? result['name'] ?? '';
    Navigator.pop(context, {
      'title': _titleController.text,
      'type': _selectedType,
      'notes': _notesController.text,
      'metadata': metadata.toJson(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          if (_searchResults.isNotEmpty)
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result['title'] ?? result['name'] ?? ''),
                    subtitle: Text(
                      result['release_date'] ?? result['first_air_date'] ?? '',
                    ),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: ['Movie', 'TV Show', 'Book', 'Anime', 'Manga', 'Podcast', 'Other']
                .map((type) => DropdownMenuItem(
                      value: type.toLowerCase(),
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Navigator.pop(context, {
                'title': _titleController.text,
                'type': _selectedType,
                'notes': _notesController.text,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}