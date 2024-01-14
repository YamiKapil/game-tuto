import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_game_tuto/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({
    position,
    this.color = 'Gray',
  }) : super(position: position);
  final double scrollSpeed = 0.4;

  @override
  FutureOr<void> onLoad() {
    /// set priority -1 to get it behind the level
    priority = -1;
    size = Vector2.all(64);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    double tileSize = 64;

    /// getting the game screen height
    int scrollHeight = (game.size.y / tileSize).floor();
    if (position.y > scrollHeight * tileSize) position.y = -tileSize;
    super.update(dt);
  }
}
