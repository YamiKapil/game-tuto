import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_game_tuto/components/checkpoint.dart';
import 'package:flame_game_tuto/components/collision_block.dart';
import 'package:flame_game_tuto/components/enemy.dart';
import 'package:flame_game_tuto/components/fruit.dart';
import 'package:flame_game_tuto/components/player_hitbox.dart';
import 'package:flame_game_tuto/components/saw.dart';
import 'package:flame_game_tuto/components/utils.dart';
import 'package:flame_game_tuto/pixel_adventure.dart';
import 'package:flutter/services.dart';

/// setting enum for player state..
enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing,
}

// enum PlayerDirection {
//   left,
//   right,
//   none,
// }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  final String character;
  Player({
    this.character = 'Ninja Frog',
    position,
  }) : super(position: position);

  /// 0.05 is 20fps
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  /// setting default player direction
  // PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  double horizontalMovement = 0;

  /// adding collision blocks
  List<CollisionBlock> collisionBlocks = [];

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  // final double _jumpForce = 180;

  /// when we are falling, the more we fall the faster we fall
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;

  /// reference to player starting position
  Vector2 startingPosition = Vector2.zero();
  bool gotHit = false;

  /// player hitbox
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  /// check if the player have reached checkpoint
  bool reachedCheckpoint = false;

  /// checking player direction face
  // bool isFacingRight = true;

  /// fixed delta time for making jump similar to all the devices..
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    _loadAllAnimations();

    /// getting player initial position and setting it..
    startingPosition = Vector2(position.x, position.y);
    // debugMode = false;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        // _updatePlayerMoment(dt);
        /// pass the new delta times..
        _updatePlayerMoment(fixedDeltaTime);
        _checkHorizontalCollisions();

        /// do gravity always after horizontal collision
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollision();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    /// or it can also be done as below
    // final isLeftKeyPressed = [
    //   LogicalKeyboardKey.keyA,
    //   LogicalKeyboardKey.arrowLeft
    // ].any(keysPressed.contains);

    // if (isLeftKeyPressed && isRightKeyPressed) {
    //   playerDirection = PlayerDirection.none;
    // } else if (isLeftKeyPressed) {
    //   playerDirection = PlayerDirection.left;
    // } else if (isRightKeyPressed) {
    //   playerDirection = PlayerDirection.right;
    // } else {
    //   playerDirection = PlayerDirection.none;
    // }

    /// refactoring above player movement code
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    hasJumped = [LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.keyW]
        .any(keysPressed.contains);
    return super.onKeyEvent(event, keysPressed);
  }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  // if (!reachedCheckpoint) {
  //   if (other is Fruit) {
  //     /// coliding...
  //     other.collidedWithPlayer();
  //   }
  //   if (other is Saw) {
  //     /// respawn on death
  //     _respawn();
  //   }
  //   if (other is CheckPoint) {
  //     _reachedCheckpoint();
  //   }
  // }
  //   super.onCollision(intersectionPoints, other);
  // }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) {
        /// coliding...
        other.collidedWithPlayer();
      }
      if (other is Saw) {
        /// respawn on death
        _respawn();
      }
      if (other is CheckPoint) {
        _reachedCheckpoint();
      }
      if (other is Enemy) {
        other.collidedWithPlayer();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() async {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    /// setting animation for different player states
    /// list of animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
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

  /// appearing and disappearing.. animation
  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void _updatePlayerMoment(double dt) {
    // double dirX = 0.0;
    // double dirY = 0.0;
    // switch (playerDirection) {
    //   case PlayerDirection.left:
    //     if (isFacingRight) {
    //       flipHorizontallyAroundCenter();
    //       isFacingRight = false;
    //     }
    //     current = PlayerState.running;
    //     dirX -= moveSpeed;
    //     break;
    //   case PlayerDirection.right:
    //     if (!isFacingRight) {
    //       flipHorizontallyAroundCenter();
    //       isFacingRight = true;
    //     }
    //     current = PlayerState.running;
    //     dirX += moveSpeed;
    //     break;
    //   case PlayerDirection.none:
    //     current = PlayerState.idle;
    //     break;
    //   default:
    // }
    // velocity = Vector2(dirX, dirY);
    // position += velocity * dt;

    /// checking has jump
    if (hasJumped && isOnGround) _playerJump(dt);

    /// if we dont want the player to jump mid air
    /// do false else comment this line
    if (velocity.y > _gravity) isOnGround = false;

    /// refactoring the above player movement code..
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    /// check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    // } else {
    //   playerState = PlayerState.idle;
    // }

    /// check if falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    /// check if jumping set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;
    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      // handle collision  ...
      /// if block is not platform then check horizontal collision
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;

    /// clamping the fall to stop player from falling faster
    ///  when there is more height
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollision() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        // handle platform..
        /// let the player jump through the playform but when he is above
        /// he should be on the playform
        /// no collison on jump
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play(
        'jump.wav',
        volume: game.soundVolume,
      );
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _respawn() async {
    if (game.playSounds) {
      FlameAudio.play(
        'hit.wav',
        volume: game.soundVolume,
      );
    }

    /// duration is 50 times amount of frame which is 7
    // const hitDuration = Duration(milliseconds: 350);
    // const appearingDuration = Duration(milliseconds: 350);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    /// method to know if the animation is completed or not to do some
    /// activities instead of using future.delay everywhere..
    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(canMoveDuration, () {
      gotHit = false;
    });
    // Future.delayed(hitDuration, () {
    //   scale.x = 1;
    //   position = startingPosition - Vector2.all(32);
    //   current = PlayerState.appearing;
    //   Future.delayed(appearingDuration, () {
    //     velocity = Vector2.zero();
    //     position = startingPosition;
    //     _updatePlayerState();
    //     Future.delayed(canMoveDuration, () {
    //       gotHit = false;
    //     });
    //   });
    // });
  }

  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    if (game.playSounds) {
      FlameAudio.play(
        'disappear.wav',
        volume: game.soundVolume,
      );
    }
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    // const reachedCheckpointDuration = Duration(milliseconds: 350);

    await animationTicker?.completed;
    animationTicker?.reset();
    reachedCheckpoint = false;
    position = Vector2.all(-640);
    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(waitToChangeDuration, () {
      game.loadNextLevel();
    });
    // Future.delayed(reachedCheckpointDuration, () {
    //   reachedCheckpoint = false;

    //   /// removing player from the screen..
    //   /// for now just placing player way off the screen..
    //   position = Vector2.all(-640);

    //   /// moving to next level..
    //   const waitToChangeDuration = Duration(seconds: 3);
    //   Future.delayed(waitToChangeDuration, () {
    //     game.loadNextLevel();
    //   });
    // });
  }

  void collidedWithEnemy() {
    _respawn();
  }
}
