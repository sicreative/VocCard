import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vocabulary_card/color_star_icon_button.dart';
import 'db.dart';
import 'edit_card.dart';
import 'select_drawer.dart';
import 'common_helper.dart';

class ListCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListCardStatefulWidget(title: 'Flutter Demo Home Page');
  }
}

class ListCardStatefulWidget extends StatefulWidget {
  ListCardStatefulWidget({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _ListCardState createState() => _ListCardState();
}

/// Used for the vocabulary sort textfield to ensure without space
class NoSpaceTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.indexOf(' ') != -1) {
      return oldValue;
    }
    return newValue;
  }
}


class _ListCardState extends State<ListCardStatefulWidget> {
  final numOfVocGetOnce = 10;
  int numOfVoc = 0;
  List<VocCard> cards = new List.empty(growable: true);
  DateTime? today;
  bool _delete_mode = false;
  bool _delete_mode_isAll = false;
  bool _search_mode = false;
  TextEditingController _searchTextController = TextEditingController();

  // for drawer update callback [dispose]
  int? _drawerCallbackID;

  _toEditCard(String vocabulary) async {
    await Navigator.pushNamed(
      context,
      '/edit',
      arguments: EditArguments(vocabulary),
    );

    _resetCards();
  }

  _resetCards() async {
    setState(() {
      numOfVoc = 0;
      cards.clear();
    });

    _addCards();

  }

  _addAllCards() async {
    final List<VocCard> result = await Db.getCardsPref(cards.length);

    if (result == null && result.isEmpty) return;
    cards.addAll(result);

    cards.forEach((card) {
      card.delete = !_delete_mode_isAll;
    });

    setState(() {
      _delete_mode_isAll = !_delete_mode_isAll;
    });
  }

  _addCards() async {
    final List<VocCard> result =
        await Db.getCardsPrefLimit(numOfVocGetOnce, cards.length);

    if (result == null && result.isEmpty) return;
    cards.addAll(result);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _drawerCallbackID = SelectDrawer.addCallback(() async {
      await _resetCards();
    });

    today = DateTime.now();

    today = today!.subtract(Duration(
        hours: today!.hour, minutes: today!.month, seconds: today!.second));

    _resetCards();
  }




  @override
  void dispose() {
    if (_drawerCallbackID != null)
      SelectDrawer.removeCallback(_drawerCallbackID!);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: _search_mode
            ? TextField(
                controller: _searchTextController,
                inputFormatters: [NoSpaceTextInputFormatter()],
                onChanged: (String value) async {
                  Db.db_search = value;
                  _resetCards();
                },
              )
            : Text(
                AppLocalizations.of(context)!.list_appbar_title,
                style: appbarTitleStyle,
              ),

        backgroundColor: appbarBackgroundColor,
        foregroundColor: appbarForegroundColor,
        iconTheme: IconThemeData(color: appbarForegroundColor),
        leadingWidth: 100,
        leading: Builder(builder: (BuildContext context) {
          return Row(children: [
            if (ModalRoute.of(context)!.canPop)
              IconButton(
                icon: Icon(
                  appbarTitleBackIcon,
                ),
                onPressed: () {
                  Db.db_search = "";
                  Navigator.pop(context);
                  },
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
          if (!_delete_mode)
          IconButton(
            icon:Icon(_search_mode?Icons.search_off:Icons.search),
            onPressed: () {
              setState(() {
                Db.db_search = "";
                _searchTextController.text = "";
                _search_mode=!_search_mode;
                _resetCards();
              });
            },

          ),
          if (_delete_mode && cards.isNotEmpty)
            IconButton(
              icon:
                  Icon(_delete_mode_isAll ? Icons.remove_done : Icons.done_all),
              onPressed: () {
                setState(() {
                  _addAllCards();
                });
              },
            ),
          if (cards.isNotEmpty)
            IconButton(
              icon: Icon(_delete_mode ? Icons.delete_outline : Icons.delete),
              onPressed: () {
                if (_delete_mode) {
                  cards.forEach((card) {
                    if (card.delete) Db.deleteCard(card.vocabulary);
                  });
                  _resetCards();
                } else {}
                setState(() {
                  _delete_mode = !_delete_mode;
                  _delete_mode_isAll = false;
                });
              },
            ),
        ],
      ),
      drawer: SelectDrawer(context),

      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {

          ///Load more when user scrolled almost end
          if (index == cards.length - 5) {
            _addCards();
          }

          ///Check the card inserted in today or within a week
          int period = 2;

          if (cards[index].addtime!.isAfter(today!))
            period = 0;
          else if (cards[index]
              .addtime!
              .isAfter(today!.subtract(Duration(days: 7)))) period = 1;

          return ListTile(
            leading: ColorStarIconButton(card: cards[index], state: this),
            title: Text(
              cards[index].vocabulary!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: _delete_mode
                ? Icon(cards[index].delete
                    ? Icons.check_box
                    : Icons.check_box_outline_blank)
                : null,
            subtitle: Row(children: [
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: vocabularyTypeBackgroundColors[
                            cards[index].type!.index],
                        borderRadius: BorderRadius.circular(6)),
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: Text(
                          getVocabularyTypeLocalizationfromIndex(
                              cards[index].type!.index, context),
                          style: TextStyle(color: vocabularyLevelTextColor),
                        ))),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: vocabularyLevelBackgroundColors[
                            cards[index].level!.index],
                        borderRadius: BorderRadius.circular(6)),
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: Text(
                          getVocabularyLevelCerfLocalizationfromIndex(
                              cards[index].level!.index, context),
                          style: TextStyle(color: vocabularyLevelTextColor),
                        ))),
              ),
              if (period < 2)
                Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: duration_colors[period],
                            borderRadius: BorderRadius.circular(6)),
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                            child: Text(
                              getDurationLocalizationfromIndex(period, context),
                              style:
                                  TextStyle(color: vocabularyLevelTextColor),
                            )))),
            ]),
            onTap: () {
              if (!_delete_mode) {
                _toEditCard(cards[index].vocabulary!);
              } else {
                setState(() {
                  cards[index].delete = !cards[index].delete;
                });
              }
            }, //
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
