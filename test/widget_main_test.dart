// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocabulary_card/edit_card.dart';
import 'package:vocabulary_card/list_card.dart';



import 'package:vocabulary_card/main.dart';

void main() {
  testWidgets('Main UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => MainApp(),
        '/edit': (context) => EditCard(),
        '/list': (context) => ListCard(),
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', 'TW'),
      ],
      theme: ThemeData.light(),
    ));
    await tester.pumpAndSettle();

    //Find Appbar drawer button
    final IconHeadlineFinder = find.byIcon(Icons.view_headline);

    expect(IconHeadlineFinder, findsOneWidget);





    //Find floating button and tap
    final FloatingButtonFinder = find.byType(FloatingActionButton);

    expect(FloatingButtonFinder, findsOneWidget);

    await tester.tap(FloatingButtonFinder);

    await tester.pump();


    //Find Add button and tap
    final AddFinder = find.byIcon(Icons.add);

    expect(AddFinder, findsOneWidget);

    await tester.tap(AddFinder);

    await tester.pump();

    //Find List button and tap
    final ListFinder = find.byIcon(Icons.list);

    expect(ListFinder, findsOneWidget);

    await tester.tap(ListFinder);

    await tester.pump();

    //Find Next button and tap (some as floating button)
    final NextFinder = find.byIcon(Icons.navigate_next);

    expect(NextFinder, findsOneWidget);

    await tester.tap(NextFinder);

    await tester.pump();






  });
}
