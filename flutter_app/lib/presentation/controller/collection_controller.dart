import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/collection/collection_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'collection_controller.g.dart';

@riverpod
CollectionService collectionService(Ref ref) {
  return CollectionService();
}

@riverpod
class CollectionController extends _$CollectionController {
  @override
  Future<List<CollectionItem>> build() async {
    AppLogger.info('Initializing collection controller', tag: 'CollectionController');
    final service = ref.read(collectionServiceProvider);
    try {
      return await service.getCollectionItems();
    } catch (e) {
      AppLogger.error('Error loading collection items', tag: 'CollectionController', error: e);
      return [];
    }
  }

  Future<void> refreshItems({CollectionCategory? category}) async {
    try {
      final service = ref.read(collectionServiceProvider);
      final items = await service.getCollectionItems(category: category);
      state = AsyncValue.data(items);
      AppLogger.info('Collection items refreshed', tag: 'CollectionController');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing collection items', tag: 'CollectionController', error: e);
      // Only update to error if we don't have previous data
      final previousState = state;
      if (!previousState.hasValue) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }
}

@riverpod
class UserCollectionController extends _$UserCollectionController {
  @override
  Future<List<UserCollectionItem>> build() async {
    AppLogger.info('Initializing user collection controller', tag: 'UserCollectionController');
    final service = ref.read(collectionServiceProvider);
    try {
      return await service.getMyCollection();
    } catch (e) {
      AppLogger.error('Error loading user collection', tag: 'UserCollectionController', error: e);
      return [];
    }
  }

  Future<void> refreshCollection({CollectionCategory? category, bool ownedOnly = false}) async {
    try {
      final service = ref.read(collectionServiceProvider);
      final items = await service.getMyCollection(category: category, ownedOnly: ownedOnly);
      state = AsyncValue.data(items);
      AppLogger.info('User collection refreshed', tag: 'UserCollectionController');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing user collection', tag: 'UserCollectionController', error: e);
      // Only update to error if we don't have previous data
      final previousState = state;
      if (!previousState.hasValue) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> equipItem(int itemId, CollectionCategory category) async {
    try {
      final service = ref.read(collectionServiceProvider);
      await service.equipItem(itemId, category);
      // Refresh collection after equipping
      await refreshCollection();
      AppLogger.info('Item equipped successfully', tag: 'UserCollectionController');
    } catch (e) {
      AppLogger.error('Error equipping item', tag: 'UserCollectionController', error: e);
      rethrow;
    }
  }

  Future<void> unlockItem(int itemId) async {
    try {
      final service = ref.read(collectionServiceProvider);
      await service.unlockItem(itemId);
      // Refresh collection after unlocking
      await refreshCollection();
      AppLogger.info('Item unlocked successfully', tag: 'UserCollectionController');
    } catch (e) {
      AppLogger.error('Error unlocking item', tag: 'UserCollectionController', error: e);
      rethrow;
    }
  }
}

@riverpod
class CollectionStatsController extends _$CollectionStatsController {
  @override
  Future<CollectionStats> build() async {
    AppLogger.info('Initializing collection stats controller', tag: 'CollectionStatsController');
    final service = ref.read(collectionServiceProvider);
    try {
      return await service.getCollectionStats();
    } catch (e) {
      AppLogger.error('Error loading collection stats', tag: 'CollectionStatsController', error: e);
      // Return default stats on error
      return CollectionStats(
        totalItems: 0,
        ownedItems: 0,
        equippedItems: 0,
        itemsByCategory: {},
        itemsByRarity: {},
      );
    }
  }

  Future<void> refreshStats() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(collectionServiceProvider);
      final stats = await service.getCollectionStats();
      state = AsyncValue.data(stats);
      AppLogger.info('Collection stats refreshed', tag: 'CollectionStatsController');
    } catch (e) {
      AppLogger.error('Error refreshing collection stats', tag: 'CollectionStatsController', error: e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

