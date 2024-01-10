import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_game_tuto/levels/level.dart';

class PixelAdventure extends FlameGame {
  /// overriding the background color
  @override
  Color backgroundColor() => const Color(0xff211F30);

  /// adding camera to get to the level
  late final CameraComponent cam;
  final myworld = Level(levelName: 'Level-01');
  @override
  FutureOr<void> onLoad() async {
    /// loading images into cache
    /// donot use if loading more images
    await images.loadAllImages();
    cam = CameraComponent.withFixedResolution(
      world: myworld,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    // add(Level());

    /// adding more than one thing
    addAll(
      [
        cam,
        myworld,
      ],
    );

    return super.onLoad();
  }
}
