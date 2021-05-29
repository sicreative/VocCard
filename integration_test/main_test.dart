
//https://dart.dev/null-safety#known-issues


import 'dart:developer' as developer;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocabulary_card/edit_card.dart';
import 'package:vocabulary_card/list_card.dart';
import 'package:vocabulary_card/main.dart';
import 'package:vocabulary_card/common_helper.dart';
import 'package:vocabulary_card/color_star_icon_button.dart';
import 'package:vocabulary_card/db.dart';


class MainTestApp extends MainApp {

  static BuildContext? context;

  @override
  Widget build(BuildContext context) {

    MainTestApp.context = context;
    return MainAppStatefulWidget(title: 'Vocabulary Card');
  }
}

Widget getDecorateBoxChild(WidgetTester tester,int pos){

 final DecoratedBoxFinder = find.byType(DecoratedBox);
  expect(DecoratedBoxFinder, findsWidgets);
 final  DecorateBoxList = tester.widgetList(DecoratedBoxFinder);
  return ((DecorateBoxList.elementAt(pos) as DecoratedBox).child as Container).child!;
}

Decoration getDecorateBoxDecorate(WidgetTester tester,int pos){

  final DecoratedBoxFinder = find.byType(DecoratedBox);
  expect(DecoratedBoxFinder, findsWidgets);
  final  DecorateBoxList = tester.widgetList(DecoratedBoxFinder);
  return ((DecorateBoxList.elementAt(pos) as DecoratedBox).decoration);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();




  testWidgets("failing test example", (WidgetTester tester) async {




    await tester.pumpWidget(MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => MainTestApp(),
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

    //Delete all card
    await Db.deleteAllCards();
    expect(await Db.getNumOfCard(), 0);

    //Build fake data
    await Db.buildFakeData();

    //Get num of card after build fake data
    final int numOfCard = await Db.getNumOfCard(withpref: false);

   // ensure fake data injected
    expect(numOfCard>0,true );



    final IconAddFinder = find.byIcon(Icons.add);
    expect(IconAddFinder, findsOneWidget);
    await tester.tap(IconAddFinder);

    await tester.pumpAndSettle();


    final EditAppBarFinder = find.byType(AppBar);
    expect(EditAppBarFinder,findsOneWidget);
    
    final title = (tester.firstWidget(EditAppBarFinder) as AppBar).title as Text;
    
    expect(title.data,AppLocalizations.of(MainTestApp.context!)!.editcard_newcard_title);


    final textforms = find.byType(TextFormField);

    expect(textforms,findsNWidgets(3));

    for(int i=0;i<textforms.evaluate().length;++i){
      await tester.enterText(textforms.at(i), "new$i");
      await tester.pumpAndSettle();
    };

    await tester.tap(find.text(AppLocalizations.of(MainTestApp.context!)!.editcard_submit));

    await tester.pumpAndSettle();

   int card = await Db.getNumOfCard(withpref: false);

    developer.log('$card card', name: 'si.creative.voc');

    expect(card, numOfCard+1);





    final BackButtonFinder = find.byType(BackButton);

    expect(BackButtonFinder,findsOneWidget);
    

    await tester.tap(BackButtonFinder);

    await tester.pumpAndSettle();


    final IconHeadlineFinder = find.byIcon(Icons.view_headline);

    expect(IconHeadlineFinder, findsOneWidget);
    
    await tester.tap(IconHeadlineFinder);

    await tester.pumpAndSettle();

    final DecoratedBoxFinder = find.byType(DecoratedBox);
    expect(DecoratedBoxFinder, findsWidgets);


    final DecorateBoxList = tester.widgetList(DecoratedBoxFinder);

    final State = find.byType(MainAppStatefulWidget);

    expect(State, findsOneWidget);




    for(int i=0;i<DecorateBoxList.length;++i){

      if (!((DecorateBoxList.elementAt(i) as DecoratedBox).child is Container))
        continue;


      Widget child = ((DecorateBoxList.elementAt(i) as DecoratedBox).child as Container).child!;
      if (child.runtimeType == Text) {


          if (AppLocalizations.of(MainTestApp.context!)!.drawer_save ==
              (child as Text).data)
              continue;

          if (AppLocalizations.of(MainTestApp.context!)!.drawer_load ==
              (child as Text).data)
              continue;




        if((getDecorateBoxDecorate(tester,i) as BoxDecoration).color == vocabularyUnselectedColor){
          await tester.tap(DecoratedBoxFinder.at(i));
          await tester.pumpAndSettle();
        }



          expect((getDecorateBoxDecorate(tester,i) as BoxDecoration).color!=vocabularyUnselectedColor,true);

          continue;

      }else if (child.runtimeType == AnimatedOpacity){
        if ((child as AnimatedOpacity).opacity < 1){
          await tester.tap(DecoratedBoxFinder.at(i));
          await tester.pumpAndSettle();
        }


        child = getDecorateBoxChild(tester,i);
        expect((child as AnimatedOpacity).opacity,1.0);

        await tester.tap(DecoratedBoxFinder.at(i));
        await tester.pumpAndSettle();

        child = getDecorateBoxChild(tester,i);
        expect((child as AnimatedOpacity).opacity,0.3);

        await tester.tap(DecoratedBoxFinder.at(i));
        await tester.pumpAndSettle();

        child = getDecorateBoxChild(tester,i);
        expect((child as AnimatedOpacity).opacity,1.0);




      }
    }







    await tester.tap(find.byType(ColorStarIconButton).first);
    await tester.pumpAndSettle();

    final IconListFinder = find.byIcon(Icons.list);

    expect(IconListFinder, findsOneWidget);

    await tester.tap(IconListFinder);
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

    int numofcard = await Db.getNumOfCard();

    final IconDeleteFinder = find.byIcon(Icons.delete);

    expect(IconDeleteFinder, findsOneWidget);

    await tester.tap(IconDeleteFinder);

    await tester.pumpAndSettle();

    final IconDeleteCancelFinder = find.byIcon(Icons.delete_outline);

    expect(IconDeleteCancelFinder, findsOneWidget);

    final IconDeleteAllDoneFinder = find.byIcon(Icons.done_all);

    expect(IconDeleteAllDoneFinder, findsOneWidget);

    await tester.tap(IconDeleteAllDoneFinder);

    await tester.pumpAndSettle();

    final IconDeleteAllRemoveFinder = find.byIcon(Icons.remove_done);

    expect(IconDeleteAllRemoveFinder, findsOneWidget);

    await tester.tap(IconDeleteCancelFinder);

    await tester.pumpAndSettle();

    expect(await Db.getNumOfCard()<=numofcard,true);



  });
}