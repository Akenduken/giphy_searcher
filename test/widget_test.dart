// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:giphy_searcher/main.dart';

void main() {
  testWidgets('Test search start', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    var label = find.text("Try to search something");
    expect(label, findsOneWidget);


    final searchButton = find.byType(IconButton);
    expect(searchButton, findsOneWidget);
    //start search
    await tester.tap(searchButton);
    await tester.pump();
    // enter hi
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'hi');

    await tester.tap(searchButton);
    await tester.pump();
    // it would be great to add some tests
    // mock giphy dependency
  });
}
