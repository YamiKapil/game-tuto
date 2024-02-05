import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_game_tuto/components/background_tile.dart';
import 'package:flame_game_tuto/components/checkpoint.dart';
import 'package:flame_game_tuto/components/collision_block.dart';
import 'package:flame_game_tuto/components/fruit.dart';
import 'package:flame_game_tuto/components/player.dart';
import 'package:flame_game_tuto/components/saw.dart';
import 'package:flame_game_tuto/pixel_adventure.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<PixelAdventure> {
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

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    // add(Player(character: 'Ninja Frog'));
    return super.onLoad();
  }

  /// adding background on the level
  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    // const tileSize = 64;

    // /// need to know how many tiles is needed..
    // final numTilesY = (game.size.y / tileSize).floor();
    // final numTilesX = (game.size.x / tileSize).floor();
    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);

      /// looping to create background tile
      // for (double y = 0; y < game.size.y / numTilesY; y++) {
      //   for (double x = 0; x < numTilesX; x++) {
      //     final backgroungTile = BackgroundTile(
      //       color: backgroundColor ?? 'Gray',
      //       position: Vector2(x * tileSize, y * tileSize - tileSize),
      //     );
      //     add(backgroungTile);
      //   }
      // }
    }
  }

  void _spawningObjects() {
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
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = CheckPoint(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            add(checkpoint);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
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
  }
}
