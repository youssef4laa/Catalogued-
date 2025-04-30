import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'storage_service.dart';
import 'cloud_storage_service.dart';
import '../models/watchlist_item.dart';

class StorageServiceFactory {
  static Future<StorageInterface> createStorageService() async {
    // Check if user is signed in with Firebase
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // Use cloud storage if user is signed in
      return CloudStorageService(user.uid);
    } else {
      // Fallback to local storage if not signed in
      final prefs = await SharedPreferences.getInstance();
      return StorageService(prefs);
    }
  }
}

// Common interface for both storage implementations
abstract class StorageInterface {
  Future<List<WatchlistItem>> getWatchlistItems();
  Future<void> saveWatchlistItems(List<WatchlistItem> items);
  Future<void> addWatchlistItem(WatchlistItem item);
  Future<void> removeWatchlistItem(String id);
  Future<void> updateWatchlistItem(WatchlistItem updatedItem);
}