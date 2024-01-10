import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_game_tuto/pixel_adventure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// remove physical mobile bar..
  await Flame.device.fullScreen();

  /// making landscape by default
  await Flame.device.setLandscape();

  PixelAdventure game = PixelAdventure();

  /// using kDebugMode so that we donot have to always restart when we make
  /// any changes in the game..
  runApp(
    GameWidget(game: kDebugMode ? PixelAdventure() : game),
  );
}
