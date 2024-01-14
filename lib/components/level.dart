import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_game_tuto/components/collision_block.dart';
import 'package:flame_game_tuto/components/player.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  final String levelName;
  final Player player;
  Level({
    required this.levelName,
    required this.player,
  });
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      // "Level-01.tmx",
      "$levelName.tmx",
      Vector2(16, 16), // or we can do Vector2.all(16)
    );

    /// adding level to the Level
    add(level);

    /// spawn point
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoint');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            // final player = Player(
            //   character: 'Ninja Frog',
            //   position: Vector2(spawnPoint.x, spawnPoint.y),
            // );
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          default:
        }
      }
    }
    // add(Player(character: 'Ninja Frog'));

    /// adding collision
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
    return super.onLoad();
  }
}
