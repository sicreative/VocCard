import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'color_star_icon_button.dart';
import 'select_drawer.dart';
import 'db.dart';
import 'edit_card.dart';
import 'list_card.dart';
import 'common_helper.dart';

// Copyright 2021 SC Lee
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Vocabulary Card
///
/// A simple vocabulary flash card for learning new vocabulary
///


void main() {
  runApp(MaterialApp(
    title: 'VocabularyCard',
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
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    ],
    theme: ThemeData.light(),
  ));
}

class MainApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MainAppStatefulWidget(title: 'Vocabulary Card');
  }
}

class MainAppStatefulWidget extends StatefulWidget {
  MainAppStatefulWidget({Key? key, this.title}) : super(key: key);

  final String? title;
  final Duration duration = Duration(seconds: 2);



  final Color nextIconColor = Colors.green;

  final int selectedIconFadeInMs = 500;
  final int selectedIconRemainMs = 3000;
  final int selectedIconFadeOutMs = 500;
  final Color selectedIconCorrectColor = Colors.green;
  final Color selectedIconWrongColor = Colors.red;



  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainAppStatefulWidget>
    with TickerProviderStateMixin {



  // for drawer update callback [dispose]
  int? _drawerCallbackID;

  VocabularyQuiz? quiz;
  int numOfChoose = 0;

  // Animations for card slide effect
  List<AnimationController> _controllers = List.empty(growable: true);
  List<Animation<Offset>> _offsetAnimations = List.empty(growable: true);

  void _newCard() async {
    await Navigator.pushNamed(context, '/edit');
    Db.resetShuttle();
    _newQuiz();
  }

  void _listCard() async {
    await Navigator.pushNamed(context, '/list');
    Db.resetShuttle();
    _newQuiz();
  }

  void _newQuiz() {
    Db.getQuiz(
        numOfChoose,
        (VocabularyQuiz q) => {
              setState(() {
                quiz = q;
                for (int i = 0; i < numOfChoose; i++) {
                  _controllers[i].reset();
                  _controllers[i].forward();
                }
              })
            });
  }

  void _resetQuiz() {
    Db.getNumOfChoose((numOfChoose) {
      assert(numOfChoose>0 && numOfChoose<=maxOfChoose);
      setState(() {
        this.numOfChoose = numOfChoose;
        Db.resetShuttle();
        _newQuiz();
      });
    });
  }


  @override
  void initState() {
    super.initState();


    // Build Animation Controller
    //
    // Each choose have their own AnimationController as various offset speed applied
    // make cards slide out as like a sequence from top to down.
    for (int i = 0; i < maxOfChoose; ++i) {
      final AnimationController controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      _controllers.add(controller);

      Animation<Offset> offsetAnimation =
          Tween<Offset>(begin: Offset(1.0 + (i * 1.0), 0.0), end: Offset.zero)
              .animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));

      _offsetAnimations.add(offsetAnimation);


    }

    _drawerCallbackID = SelectDrawer.addCallback(() {
      _resetQuiz();
    });

    _resetQuiz();
  }

  @override
  void dispose() {
    for (int i = 0; i < maxOfChoose; ++i) _controllers[i].dispose();
    if (_drawerCallbackID != null)
      SelectDrawer.removeCallback(_drawerCallbackID!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        onPressed: () {
          _newQuiz();
        },
        backgroundColor: widget.nextIconColor,
      ),
      appBar: AppBar(
        leadingWidth: 100,
        title: Text(
          AppLocalizations.of(context)!.main_appbar_title,
          style: appbarTitleStyle,
        ),
        iconTheme: IconThemeData(color: appbarForegroundColor),
        leading: Builder(builder: (BuildContext context) {
          return Row(children: [
            if (ModalRoute.of(context)!.canPop)
              IconButton(
                icon: Icon(
                  appbarTitleBackIcon,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            IconButton(
              icon: Icon(
                appbarTitleDrawerIcon
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          ]);
        }),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              _newCard();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.list,
            ),
            onPressed: () {
              _listCard();
            },
          ),
        ],
        backgroundColor: appbarBackgroundColor,
      ),
      drawer: SelectDrawer(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(flex: 10),
            Row(mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start
                ,children: [
              Text(
                quiz == null
                    ? AppLocalizations.of(context)!.main_waiting
                    : quiz!.getVocabulary(),
                style: Theme.of(context).textTheme.headline4,
              ),
              if (quiz!=null && quiz!.numOfChoose!=0)
                ColorStarIconButton(card: quiz!.getCollectCard(), state: this)
            ]),
            Spacer(flex: 1),
            if (quiz != null && quiz!.numOfChoose >= numOfChoose)
              for (int i = 0; i < quiz!.numOfChoose; ++i)
                SlideTransition(
                  position: _offsetAnimations[i],
                  child: Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          ListTile(
                            onTap: () async {
                              setState(() {
                                quiz!.checkAns(i);
                              });

                              //if () _newQuiz();
                            },
                            leading: Text((i + 1).toString(),
                                style: TextStyle(fontSize: 24)),
                            trailing: AnimatedOpacity(
                              opacity: quiz!.isSelected(i) ? 1.0 : 0.0,
                              duration: Duration(milliseconds: widget.selectedIconFadeOutMs),
                              onEnd: () {

                                if (quiz!.isSelected(i))
                                  Future.delayed(Duration(milliseconds: widget.selectedIconRemainMs),
                                      () {
                                    setState(() {
                                      quiz!.resetSelected(i);
                                      if (quiz!.isCorrect(i))
                                        Future.delayed(
                                             Duration(milliseconds: widget.selectedIconFadeOutMs),
                                            () {
                                          _newQuiz();
                                        });
                                    });
                                  });
                              },
                              child: Icon(
                                  quiz!.isCorrect(i)
                                      ? Icons.check_circle
                                      : Icons.highlight_off,
                                  color: quiz!.isCorrect(i)
                                      ? widget.selectedIconCorrectColor
                                      : widget.selectedIconWrongColor),
                            ),
                            title: Text(quiz!.getChoose()![i]),
                          ),
                        ]),
                  ),
                ),
            if (quiz == null || quiz!.numOfChoose < numOfChoose)
              Text(AppLocalizations.of(context)!.main_morewords),
            Spacer(flex: 10),
          ],
        ),

      ),
    );
  }
}
