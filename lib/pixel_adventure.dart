import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_game_tuto/components/player.dart';
import 'package:flame_game_tuto/components/level.dart';
import 'package:flutter/material.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  /// overriding the background color
  @override
  Color backgroundColor() => const Color(0xff211F30);

  /// adding camera to get to the level
  late CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');

  /// creating joystick
  late JoystickComponent joystick;
  bool showJoystick = false;
  List<String> levelNames = [
    'Level-01',
    'Level-01',
  ];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    /// loading images into cache
    /// donot use if loading more images
    await images.loadAllImages();
    // final myworld = Level(
    //   levelName: 'Level-01',
    //   player: player,
    // );
    // cam = CameraComponent.withFixedResolution(
    //   world: myworld,
    //   width: 640,
    //   height: 360,
    // );
    // cam.viewfinder.anchor = Anchor.topLeft;
    // // add(Level());

    // /// adding more than one thing
    // addAll(
    //   [
    //     cam,
    //     myworld,
    //   ],
    // );

    /// making level dynamic...
    _loadLevel();

    if (showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),

      /// can give radius to the knob.
      // knobRadius: ,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        // player.playerDirection = PlayerDirection.left;
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        // player.playerDirection = PlayerDirection.right;
        player.horizontalMovement = 1;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    if (currentLevelIndex < levelNames.length) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      /// no more levels
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level myworld = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );
      cam = CameraComponent.withFixedResolution(
        world: myworld,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll(
        [cam, myworld],
      );
    });
  }
}
