import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class BackgroundTile extends ParallaxComponent {
  /// parallax component have access to out game ref so no need to extend our
  /// hasgame ref
  final String color;
  BackgroundTile({
    position,
    this.color = 'Gray',
  }) : super(position: position);
  final double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    /// set priority -1 to get it behind the level
    priority = -10;
    size = Vector2.all(64);
    // sprite = Sprite(game.images.fromCache('Background/$color.png'));
    parallax = await game.loadParallax(
      [
        ParallaxImageData('Background/$color.png'),
      ],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );
    return super.onLoad();
  }

  // @override
  // void update(double dt) {
  //   position.y += scrollSpeed;
  //   double tileSize = 64;

  //   /// getting the game screen height
  //   int scrollHeight = (game.size.y / tileSize).floor();
  //   if (position.y > scrollHeight * tileSize) position.y = -tileSize;
  //   super.update(dt);
  // }
}
