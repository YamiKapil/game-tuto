import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_game_tuto/components/player_hitbox.dart';
import 'package:flame_game_tuto/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruit;
  Fruit({
    this.fruit = 'Apple',
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  final double stepTime = 0.05;
  final hitBox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );
  bool _collected = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    priority = -1;
    add(
      RectangleHitbox(
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height),
        collisionType: CollisionType.passive,
      ),
    );

    /// from frame data means all the animation is in one line..
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }

  void collidedWithPlayer() async {
    /// no need to use collected cause we are checking collision only when it starts
    if (!_collected) {
      /// animation for fruit collected
      _collected = true;
      if (game.playSounds) {
        FlameAudio.play(
          'collect_fruit.wav',
          volume: game.soundVolume,
        );
      }
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
    }
    await animationTicker?.completed;
    removeFromParent();
    // Future.delayed(const Duration(milliseconds: 400), () {
    //   removeFromParent();
    // });
  }
}
