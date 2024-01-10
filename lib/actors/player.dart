import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_game_tuto/pixel_adventure.dart';

/// setting enum for player state..
enum PlayerState {
  idle,
  running,
  jumping,
}

enum PlayerDirection {
  left,
  right,
  none,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  final String character;
  Player({
    required this.character,
    position,
  }) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;

  /// 0.05 is 20fps
  final double stepTime = 0.05;

  /// setting default player direction
  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() async {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);

    /// setting animation for different player states
    /// list of animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };

    /// setting current state(animation)
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
