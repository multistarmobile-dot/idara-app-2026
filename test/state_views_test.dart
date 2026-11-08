import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idara_khair_ul_ibad/shared/widgets/state_views.dart';

void main() {
  testWidgets('EmptyState shows title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(icon: Icons.bookmark_border, title: 'خالی', message: 'پیغام'),
        ),
      ),
    );
    expect(find.text('خالی'), findsOneWidget);
    expect(find.text('پیغام'), findsOneWidget);
  });

  testWidgets('ErrorState retry button calls callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(message: 'خرابی', onRetry: () => tapped = true),
        ),
      ),
    );
    await tester.tap(find.byType(FilledButton));
    expect(tapped, isTrue);
  });
}
