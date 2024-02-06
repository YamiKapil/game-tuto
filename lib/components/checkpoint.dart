import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_game_tuto/components/player.dart';
import 'package:flame_game_tuto/pixel_adventure.dart';

class CheckPoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  CheckPoint({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  // bool reachedCheckpoint = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = false;
    add(RectangleHitbox(
      // moving 18 from the left and 56 from the top.
      position: Vector2(18, 56),
      size: Vector2(12, 8),
      collisionType: CollisionType.passive,
    ));
    priority = -1;
    animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   if (other is Player && !reachedCheckpoint) {
  //     _reachedCheckpoint();
  //   }
  //   super.onCollision(intersectionPoints, other);
  // }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async {
    // reachedCheckpoint = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );
    // const flagDuration = Duration(milliseconds: 1300);
    await animationTicker?.completed;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ),
    );
    // Future.delayed(flagDuration, () {
    //   animation = SpriteAnimation.fromFrameData(
    //     game.images.fromCache(
    //         'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
    //     SpriteAnimationData.sequenced(
    //       amount: 10,
    //       stepTime: 0.05,
    //       textureSize: Vector2.all(64),
    //     ),
    //   );
    // });
  }
}
