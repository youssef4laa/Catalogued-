import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import '../models/watchlist_item.dart';

class CloudStorageService {
  static const String _fileName = 'watchlist.json';
  final FirebaseStorage _storage;
  final String _userId;

  CloudStorageService(this._userId) : _storage = FirebaseStorage.instance;

  Future<String> _getFilePath() async {
    return 'users/$_userId/$_fileName';
  }

  Future<List<WatchlistItem>> getWatchlistItems() async {
    try {
      final filePath = await _getFilePath();
      final ref = _storage.ref(filePath);
      final data = await ref.getData();
      
      if (data == null) return [];
      
      final String jsonStr = utf8.decode(data);
      final List<dynamic> decodedItems = jsonDecode(jsonStr);
      return decodedItems.map((item) => WatchlistItem.fromJson(item)).toList();
    } catch (e) {
      // If file doesn't exist or other error, return empty list
      return [];
    }
  }

  Future<void> saveWatchlistItems(List<WatchlistItem> items) async {
    final filePath = await _getFilePath();
    final ref = _storage.ref(filePath);
    
    final String encodedItems = jsonEncode(
      items.map((item) => item.toJson()).toList(),
    );
    
    final bytes = utf8.encode(encodedItems);
    await ref.putData(bytes);
  }

  Future<void> addWatchlistItem(WatchlistItem item) async {
    final items = await getWatchlistItems();
    items.add(item);
    await saveWatchlistItems(items);
  }

  Future<void> removeWatchlistItem(String id) async {
    final items = await getWatchlistItems();
    items.removeWhere((item) => item.id == id);
    await saveWatchlistItems(items);
  }

  Future<void> updateWatchlistItem(WatchlistItem updatedItem) async {
    final items = await getWatchlistItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await saveWatchlistItems(items);
    }
  }
}
