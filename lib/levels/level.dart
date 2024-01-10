import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_game_tuto/actors/player.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  late TiledComponent level;
  final String levelName;
  Level({required this.levelName});

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

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          final player = Player(
            character: 'Ninja Frog',
            position: Vector2(spawnPoint.x, spawnPoint.y),
          );
          add(player);
          break;
        default:
      }
    }
    // add(Player(character: 'Ninja Frog'));
    return super.onLoad();
  }
}
