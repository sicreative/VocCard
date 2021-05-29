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
import 'package:vocabulary_card/common_helper.dart';
import 'package:vocabulary_card/edit_card.dart';
import 'package:vocabulary_card/list_card.dart';

import 'package:vocabulary_card/main.dart';

void main() {
  testWidgets('Listcard UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      title: 'Vocabulary_Card',
      initialRoute: '/list',
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




    final ListViewFinder = find.byType(ListView);

    expect(ListViewFinder, findsOneWidget);



    final IconDrawerFinder = find.byIcon(appbarTitleDrawerIcon);

    expect(IconDrawerFinder, findsOneWidget);

    final IconSearchFinder = find.byIcon(Icons.search);

    expect(IconSearchFinder, findsOneWidget);

    await tester.tap(IconSearchFinder);

    await tester.pumpAndSettle();

    final IconSearchOffFinder = find.byIcon(Icons.search_off);

    expect(IconSearchOffFinder, findsOneWidget);


  });
}
