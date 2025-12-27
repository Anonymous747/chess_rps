import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_interceptor.dart';
import 'package:chess_rps/data/service/dio_logger_interceptor.dart';
import 'package:dio/dio.dart';

class CollectionItem {
  final int id;
  final String name;
  final String? description;
  final CollectionCategory category;
  final CollectionRarity rarity;
  final String? iconName;
  final String? colorHex;
  final bool isPremium;
  final int? unlockLevel;
  final int? unlockPrice;
  final int? seasonId;
  final Map<String, dynamic>? itemMetadata;

  CollectionItem({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.rarity,
    this.iconName,
    this.colorHex,
    required this.isPremium,
    this.unlockLevel,
    this.unlockPrice,
    this.seasonId,
    this.itemMetadata,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: CollectionCategory.values.firstWhere(
        (e) => e.value == json['category'],
        orElse: () => CollectionCategory.PIECES,
      ),
      rarity: CollectionRarity.values.firstWhere(
        (e) => e.value == json['rarity'],
        orElse: () => CollectionRarity.COMMON,
      ),
      iconName: json['icon_name'] as String?,
      colorHex: json['color_hex'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      unlockLevel: json['unlock_level'] as int?,
      unlockPrice: json['unlock_price'] as int?,
      seasonId: json['season_id'] as int?,
      itemMetadata: json['item_metadata'] as Map<String, dynamic>?,
    );
  }
}

enum CollectionCategory {
  PIECES('pieces'),
  BOARDS('boards'),
  AVATARS('avatars'),
  EFFECTS('effects');

  final String value;
  const CollectionCategory(this.value);
}

enum CollectionRarity {
  COMMON('common'),
  UNCOMMON('uncommon'),
  RARE('rare'),
  EPIC('epic'),
  LEGENDARY('legendary');

  final String value;
  const CollectionRarity(this.value);

  String get displayName {
    switch (this) {
      case CollectionRarity.COMMON:
        return 'Common';
      case CollectionRarity.UNCOMMON:
        return 'Uncommon';
      case CollectionRarity.RARE:
        return 'Rare';
      case CollectionRarity.EPIC:
        return 'Epic';
      case CollectionRarity.LEGENDARY:
        return 'Legendary';
    }
  }
}

class UserCollectionItem {
  final int id;
  final int userId;
  final int itemId;
  final CollectionItem item;
  final bool isOwned;
  final bool isEquipped;
  final DateTime? obtainedAt;
  final String? obtainedVia;
  final int? obtainedCost;

  UserCollectionItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    this.obtainedAt,
    this.obtainedVia,
    this.obtainedCost,
  });

  factory UserCollectionItem.fromJson(Map<String, dynamic> json) {
    return UserCollectionItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      itemId: json['item_id'] as int,
      item: CollectionItem.fromJson(json['item'] as Map<String, dynamic>),
      isOwned: json['is_owned'] as bool? ?? false,
      isEquipped: json['is_equipped'] as bool? ?? false,
      obtainedAt: json['obtained_at'] != null
          ? DateTime.parse(json['obtained_at'] as String)
          : null,
      obtainedVia: json['obtained_via'] as String?,
      obtainedCost: json['obtained_cost'] as int?,
    );
  }
}

class CollectionStats {
  final int totalItems;
  final int ownedItems;
  final int equippedItems;
  final Map<String, int> itemsByCategory;
  final Map<String, int> itemsByRarity;

  CollectionStats({
    required this.totalItems,
    required this.ownedItems,
    required this.equippedItems,
    required this.itemsByCategory,
    required this.itemsByRarity,
  });

  factory CollectionStats.fromJson(Map<String, dynamic> json) {
    return CollectionStats(
      totalItems: json['total_items'] as int? ?? 0,
      ownedItems: json['owned_items'] as int? ?? 0,
      equippedItems: json['equipped_items'] as int? ?? 0,
      itemsByCategory: Map<String, int>.from(
        json['items_by_category'] as Map<String, dynamic>? ?? {},
      ),
      itemsByRarity: Map<String, int>.from(
        json['items_by_rarity'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CollectionService {
  final Dio _dio;

  CollectionService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Endpoint.apiBase,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            )..interceptors.addAll([
                DioLoggerInterceptor(),
                AuthInterceptor(),
              ]);

  Future<List<CollectionItem>> getCollectionItems({
    CollectionCategory? category,
    CollectionRarity? rarity,
  }) async {
    try {
      AppLogger.info('Fetching collection items', tag: 'CollectionService');
      final queryParams = <String, dynamic>{};
      if (category != null) {
        queryParams['category'] = category.value;
      }
      if (rarity != null) {
        queryParams['rarity'] = rarity.value;
      }

      final response = await _dio.get(
        '/api/v1/collection/items',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CollectionItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch collection items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Error fetching collection items: ${e.message}',
          tag: 'CollectionService', error: e);
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch collection items');
    } catch (e) {
      AppLogger.error('Unexpected error fetching collection items: $e',
          tag: 'CollectionService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<UserCollectionItem>> getMyCollection({
    CollectionCategory? category,
    bool ownedOnly = false,
  }) async {
    try {
      AppLogger.info('Fetching user collection', tag: 'CollectionService');
      final queryParams = <String, dynamic>{};
      if (category != null) {
        queryParams['category'] = category.value;
      }
      if (ownedOnly) {
        queryParams['owned_only'] = true;
      }

      final response = await _dio.get(
        '/api/v1/collection/my-items',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserCollectionItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch user collection: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Error fetching user collection: ${e.message}',
          tag: 'CollectionService', error: e);
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch user collection');
    } catch (e) {
      AppLogger.error('Unexpected error fetching user collection: $e',
          tag: 'CollectionService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<CollectionStats> getCollectionStats() async {
    try {
      AppLogger.info('Fetching collection stats', tag: 'CollectionService');
      final response = await _dio.get('/api/v1/collection/stats');

      if (response.statusCode == 200) {
        return CollectionStats.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch collection stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Error fetching collection stats: ${e.message}',
          tag: 'CollectionService', error: e);
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch collection stats');
    } catch (e) {
      AppLogger.error('Unexpected error fetching collection stats: $e',
          tag: 'CollectionService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<UserCollectionItem>> equipItem(int itemId, CollectionCategory category) async {
    try {
      AppLogger.info('Equipping item $itemId in category ${category.value}',
          tag: 'CollectionService');
      final response = await _dio.post(
        '/api/v1/collection/equip',
        data: {
          'item_id': itemId,
          'category': category.value,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserCollectionItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to equip item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Error equipping item: ${e.message}',
          tag: 'CollectionService', error: e);
      throw Exception(e.response?.data['detail'] ?? 'Failed to equip item');
    } catch (e) {
      AppLogger.error('Unexpected error equipping item: $e',
          tag: 'CollectionService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<UserCollectionItem>> equipAvatarByIcon(String iconName) async {
    try {
      AppLogger.info('Equipping avatar by icon: $iconName', tag: 'CollectionService');
      final response = await _dio.post(
        '/api/v1/collection/equip-avatar-by-icon',
        data: {
          'icon_name': iconName,
          'category': CollectionCategory.AVATARS.value,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserCollectionItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to equip avatar: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Error equipping avatar by icon: ${e.message}',
          tag: 'CollectionService', error: e);
      throw Exception(e.response?.data['detail'] ?? 'Failed to equip avatar');
    } catch (e) {
      AppLogger.error('Unexpected error equipping avatar by icon: $e',
          tag: 'CollectionService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserCollectionItem> unlockItem(int itemId) async {
    try {
      AppLogger.info('Unlocking item $itemId', tag: 'CollectionService');
      final response = await _dio.post('/api/v1/collection/unlock/$itemId');

      if (response.statusCode == 200) {
        return UserCollectionItem.fromJson(response.data);
      } else {
        throw Exception('Failed to unlock item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Error unlocking item: ${e.message}',
          tag: 'CollectionService', error: e);
      throw Exception(e.response?.data['detail'] ?? 'Failed to unlock item');
    } catch (e) {
      AppLogger.error('Unexpected error unlocking item: $e',
          tag: 'CollectionService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }
}

