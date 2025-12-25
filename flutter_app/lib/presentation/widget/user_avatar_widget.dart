import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/collection/collection_service.dart';
import 'package:chess_rps/presentation/utils/avatar_utils.dart';
import 'package:chess_rps/presentation/widget/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chess_rps/presentation/controller/collection_controller.dart';

/// Reusable widget to display user avatar
/// Fetches the equipped avatar from user collection and displays it
class UserAvatarWidget extends ConsumerWidget {
  final double size;
  final String? avatarIconName; // Optional: if provided, use this instead of fetching
  final bool showEditIcon;
  final VoidCallback? onTap;
  final Border? border;
  final BoxShadow? shadow;

  const UserAvatarWidget({
    Key? key,
    this.size = 48,
    this.avatarIconName,
    this.showEditIcon = false,
    this.onTap,
    this.border,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If avatarIconName is provided, use it directly
    if (avatarIconName != null) {
      return _buildAvatarImage(
        context,
        AvatarUtils.getAvatarImagePath(avatarIconName),
        size: size,
        showEditIcon: showEditIcon,
        onTap: onTap,
        border: border,
        shadow: shadow,
      );
    }

    // Otherwise, fetch from user collection
    final userCollectionAsync = ref.watch(userCollectionControllerProvider);

    return userCollectionAsync.when(
      data: (userCollection) {
        // Find equipped avatar
        UserCollectionItem? equippedAvatar;
        try {
          equippedAvatar = userCollection.firstWhere(
            (uc) => uc.isEquipped && uc.item.category == CollectionCategory.AVATARS,
          );
        } catch (e) {
          // No equipped avatar
          equippedAvatar = null;
        }

        final avatarPath = equippedAvatar != null
            ? AvatarUtils.getAvatarImagePath(equippedAvatar.item.iconName)
            : AvatarUtils.getDefaultAvatarPath();

        return _buildAvatarImage(
          context,
          avatarPath,
          size: size,
          showEditIcon: showEditIcon,
          onTap: onTap,
          border: border,
          shadow: shadow,
        );
      },
      loading: () => SkeletonAvatar(
        size: size,
        color: Palette.backgroundTertiary,
      ),
      error: (_, __) => _buildAvatarImage(
        context,
        AvatarUtils.getDefaultAvatarPath(),
        size: size,
        showEditIcon: showEditIcon,
        onTap: onTap,
        border: border,
        shadow: shadow,
      ),
    );
  }

  Widget _buildAvatarImage(
    BuildContext context,
    String avatarPath, {
    required double size,
    required bool showEditIcon,
    VoidCallback? onTap,
    Border? border,
    BoxShadow? shadow,
  }) {
    final boxShadowList = shadow != null
        ? <BoxShadow>[shadow]
        : <BoxShadow>[
            BoxShadow(
              color: Palette.purpleAccent.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ];
    
    final avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ??
            Border.all(
              color: Palette.glassBorder,
              width: 2,
            ),
        boxShadow: boxShadowList,
      ),
      child: ClipOval(
        child: Image.asset(
          avatarPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                ),
              ),
              child: Icon(
                Icons.person,
                color: Palette.textPrimary,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );

    if (showEditIcon) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            avatarWidget,
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(size * 0.1),
                decoration: BoxDecoration(
                  color: Palette.purpleAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Palette.background, width: 2),
                ),
                child: Icon(
                  Icons.edit,
                  color: Palette.textPrimary,
                  size: size * 0.15,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

/// Widget to display avatar for a specific user by their avatar icon name
/// Used when displaying other users' avatars (friends, leaderboard, etc.)
class UserAvatarByIconWidget extends StatelessWidget {
  final String? avatarIconName;
  final double size;
  final Border? border;
  final BoxShadow? shadow;
  final VoidCallback? onTap;

  const UserAvatarByIconWidget({
    Key? key,
    this.avatarIconName,
    this.size = 48,
    this.border,
    this.shadow,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarPath = avatarIconName != null
        ? AvatarUtils.getAvatarImagePath(avatarIconName)
        : AvatarUtils.getDefaultAvatarPath();

    final avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ??
            Border.all(
              color: Palette.glassBorder,
              width: 2,
            ),
        boxShadow: shadow != null
            ? <BoxShadow>[shadow as BoxShadow]
            : <BoxShadow>[
                BoxShadow(
                  color: Palette.purpleAccent.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: ClipOval(
        child: Image.asset(
          avatarPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                ),
              ),
              child: Icon(
                Icons.person,
                color: Palette.textPrimary,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
