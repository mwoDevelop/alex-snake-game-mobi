import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alex_snake_flutter/main.dart';
import 'package:alex_snake_flutter/game/snake_game.dart';

void main() {
  testWidgets('Snake game starts and snake is visible', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AlexSnakeGameMobi());

    // Verify that the SnakeGame widget is present.
    expect(find.byType(SnakeGame), findsOneWidget);

    // Verify that the snake is visible (you might need to adjust this based on your actual implementation)
    // This is a basic check, you might need to add more specific checks based on your game logic
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
