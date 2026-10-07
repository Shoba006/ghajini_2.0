import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghajini_app/main.dart';

void main() {
  testWidgets('Home Screen displays AI Memory Prosthesis title and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const GhajiniApp());
    await tester.pumpAndSettle();

    expect(find.text('AI Memory Prosthesis'), findsOneWidget);
    expect(find.text('Your personal memory assistant'), findsOneWidget);
    expect(find.byKey(const Key('recognize_person_btn')), findsOneWidget);
    expect(find.byKey(const Key('ask_memory_btn')), findsOneWidget);
    expect(find.text('NEXT REMINDER'), findsOneWidget);
    expect(find.text('Doctor appointment'), findsOneWidget);
    expect(find.text('11:00 AM'), findsOneWidget);
  });

  testWidgets('Navigation to Recognition Screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const GhajiniApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('recognize_person_btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('capture_btn')), findsOneWidget);
  });

  testWidgets('Navigation to Chat Screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const GhajiniApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ask_memory_btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('question_input')), findsOneWidget);
    expect(find.byKey(const Key('ask_btn')), findsOneWidget);
  });
}
