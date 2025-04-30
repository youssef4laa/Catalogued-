import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/watchlist_item.dart';
import 'storage_service_factory.dart';

class StorageService implements StorageInterface {
  static const String _key = 'watchlist_items';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<List<WatchlistItem>> getWatchlistItems() async {
    final String? itemsJson = _prefs.getString(_key);
    if (itemsJson == null) return [];

    final List<dynamic> decodedItems = jsonDecode(itemsJson);
    return decodedItems
        .map((item) => WatchlistItem.fromJson(item))
        .toList();
  }

  Future<void> saveWatchlistItems(List<WatchlistItem> items) async {
    final String encodedItems = jsonEncode(
      items.map((item) => item.toJson()).toList(),
    );
    await _prefs.setString(_key, encodedItems);
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