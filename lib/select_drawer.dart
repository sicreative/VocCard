import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'common_helper.dart';
import 'db.dart';
import 'package:flutter/services.dart';

class SelectDrawer extends StatefulWidget {

  final BuildContext mothercontext;

  static int save_num_of_item = 0;

  SelectDrawer(this.mothercontext);

  @override
  _SelectDrawerState createState() => _SelectDrawerState();

// Callbacks for change requirement after user change the sorting parameters
  static List<void Function()?> _updateCallbacks = List.empty(growable: true);

  static int addCallback(void Function() callback){
    _updateCallbacks.add(callback);
    return _updateCallbacks.length-1;
  }

  static void removeCallback(int id){
    if (_updateCallbacks.length > id)
      _updateCallbacks.removeAt(id);
  }

  static void _callUpdate(){

      for(int i = _updateCallbacks.length-1;i>=0;--i ){

        try {
          _updateCallbacks[i]!();
        } catch (e) {
        }
      }
  }
}

class _SelectDrawerState extends State<SelectDrawer> {

  /// for call native function (Save/Load)
  static const platform = const MethodChannel('com.sicreative.vocabularycard.vocabulary_card/file');



  List<bool> level_select =
      List.generate(VocabularyLevel.values.length, (index) => true);
  List<bool> type_select =
      List.generate(VocabularyType.values.length, (index) => true);
  List<bool> colorlabel_select =
  List.generate(colorlabel_colors.length, (index) => true);

  VocabularyDatePeriod select_duration = VocabularyDatePeriod.Today;

  int select_numOfChoose = 4;

  VocabularyMode select_mode = VocabularyMode.New;


/// validator for at least one type selected
  void _updateType() async {
    int values = 0;
    for (int i = 0; i < type_select.length; ++i) {
      if (type_select[i]) {
        values |= 1 << i;
      }
    }
    _updatePrefDB('type', values);
  }

  /// validator for at least one level selected
  void _updateLevel() async {
    int values = 0;
    for (int i = 0; i < level_select.length; ++i) {
      if (level_select[i]) {
        values |= 1 << i;
      }
    }
    _updatePrefDB('level', values);
  }

  /// validator for at least one colorlabel selected
  void _updateColorLabel() async {
    int values = 0;
    for (int i = 0; i < colorlabel_colors.length; ++i) {
      if (colorlabel_select[i]) {
        values |= 1 << i;
      }
    }
    _updatePrefDB('colorlabel', values);
  }

  void _updateDuration() async {
    _updatePrefDB('duration', select_duration.index);
  }

  void _updateNumOfChoose() async {
    _updatePrefDB('numofchoose', select_numOfChoose);
  }


  void _updateMode() async {
    _updatePrefDB('mode', select_mode.index);
  }

  void _updatePrefDB(String type, int value) async {
    Db.setPref(type, value);
    SelectDrawer._callUpdate();
  }

  void _retrievePref() async {
    int type = await Db.getPref('type');
    int level = await Db.getPref('level');
    int colorlabel = await Db.getPref('colorlabel');
    final duration = await Db.getPref('duration');
    final mode = await Db.getPref('mode');
    final numOfChoose = await Db.getPref('numofchoose');
    setState(() {
      select_duration = VocabularyDatePeriod.values[duration];
      select_mode = VocabularyMode.values[mode];
      select_numOfChoose = numOfChoose;

      ///transfer bool array to integer flags
      for (int i = 0; i < type_select.length; ++i) {
        type_select[i] = (type & 1) == 1;
        type >>= 1;
      }
      for (int i = 0; i < level_select.length; ++i) {
        level_select[i] = (level & 1) == 1;
        level >>= 1;
      }
      for (int i = 0; i < colorlabel_select.length; ++i) {
        colorlabel_select[i] = (colorlabel & 1) == 1;
        colorlabel >>= 1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _retrievePref();

    platform.setMethodCallHandler((call) async  {
      if (call.method=='loadresult'){

       if( call.arguments['result']!="true" ){
         ScaffoldMessenger.of(widget.mothercontext).showSnackBar(SnackBar(
           content: Text(AppLocalizations.of(widget.mothercontext)!.load_failure),
         ));
         return;
       }

       int count = await Db.insertCsv(call.arguments['csv']);

       SelectDrawer._callUpdate();

       ScaffoldMessenger.of(widget.mothercontext).showSnackBar(SnackBar(
           content: Text(AppLocalizations.of(widget.mothercontext)!.load_sucessful(count.toString())),
         ));

      }else if (call.method=='saveresult'){

        if( call.arguments['result']!="true" ){
          ScaffoldMessenger.of(widget.mothercontext).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(widget.mothercontext)!.save_failure),
          ));
          return;
        }

          ScaffoldMessenger.of(widget.mothercontext).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(widget.mothercontext)!.save_sucessful( SelectDrawer.save_num_of_item.toString())),
          ));
        }

    });
  }

  void _typeOnTap(int i) {
    int selected_count = 0;
    type_select.forEach((element) {
      if (element == true) selected_count++;
    });
    if (selected_count == 1 && type_select[i] == true) return;
    setState(() {
      type_select[i] = !type_select[i];
      _updateType();
    });
  }

  void _levelOnTap(int i) {
    int selected_count = 0;
    level_select.forEach((element) {
      if (element == true) selected_count++;
    });
    if (selected_count == 1 && level_select[i] == true) return;
    setState(() {
      level_select[i] = !level_select[i];
      _updateLevel();
    });
  }

  void _colorlabelOnTap(int i) {
    int selected_count = 0;
    colorlabel_select.forEach((element) {
      if (element == true) selected_count++;
    });
    if (selected_count == 1 && colorlabel_select[i] == true) return;
    setState(() {
      colorlabel_select[i] = !colorlabel_select[i];
      _updateColorLabel();
    });
  }

  Future<void> _save() async{

    Navigator.pop(context);

    String csv = await Db.getAllCsv();

    if (csv.isEmpty) {
      ScaffoldMessenger.of(widget.mothercontext).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(widget.mothercontext)!.save_noitem)));
      return;
    }

    int pos = 0;
    int count = 0;
     do{
      pos = csv.indexOf('\n', pos);
      if (pos<0)
        break;
      ++count;
      ++pos;


    }while(true);
   SelectDrawer.save_num_of_item = count;



    try {

      await platform.invokeMethod('save',{'csv':csv});
      
    } on PlatformException catch (e) {

    }
  }


  Future<void> _load() async{
    Navigator.pop(context);
    try {

      ScaffoldMessenger.of(widget.mothercontext).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(widget.mothercontext)!.load_waiting),
        duration: Duration(seconds: 5),));

       await platform.invokeMethod('load');

    } on PlatformException catch (e) {

    }

  }

  @override
  Widget build(BuildContext context) {
    Widget? child = Column(
      children: [
        Spacer(flex: 3),
        for (int j = 0; j < type_select.length; j++)
          Row(
            children: [
              for (int i = j; i <= j; i++)
                Container(
                  padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                  child: InkWell(
                    onTap: () {
                      _typeOnTap(i);
                    },
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: type_select[i]
                                ? vocabularyTypeBackgroundColors[i]
                                : vocabularyUnselectedColor,
                            borderRadius: BorderRadius.circular(6)),
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                            child: Text(
                              getVocabularyTypeLocalizationfromIndex(
                                  i, context),
                              style:
                                  TextStyle(color: vocabularyLevelTextColor),
                            ))),
                  ),
                ),
            ],
          ),
        Spacer(flex: 2),
        Row(
          children: [
            for (int i = 0;
                i < vocabularyLevelBackgroundColors.length / 2;
                i++)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {_levelOnTap(i)},
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: level_select[i]
                              ? vocabularyLevelBackgroundColors[i]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(
                            getVocabularyLevelCerfLocalizationfromIndex(
                                i, context),
                            style:
                                TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),
        Row(
          children: [
            for (int i =
                    (vocabularyLevelBackgroundColors.length / 2).toInt();
                i < vocabularyLevelBackgroundColors.length;
                i++)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {
                    _levelOnTap(i);
                  },
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: level_select[i]
                              ? vocabularyLevelBackgroundColors[i]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(
                            getVocabularyLevelCerfLocalizationfromIndex(
                                i, context),
                            style:
                                TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),
        Spacer(flex: 2),
        Row(
          children: [
            for (int i = 0; i < 2; i++)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                     select_duration = VocabularyDatePeriod.values[i];
                     _updateDuration();
                    });
                  },
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: select_duration.index == i
                              ? duration_colors[i]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(
                            getDurationLocalizationfromIndex(i, context),
                            style:
                                TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),
        Row(
          children: [
            for (int i = 2; i < 4; i++)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      select_duration = VocabularyDatePeriod.values[i];
                      _updateDuration();
                    });
                  },
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: select_duration.index == i
                              ? duration_colors[i]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(
                            getDurationLocalizationfromIndex(i, context),
                            style:
                                TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),
        Row(
          children: [
            for (int i = 4; i < 5; i++)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      select_duration = VocabularyDatePeriod.values[i];
                      _updateDuration();
                    });
                  },
                  child: DecoratedBox(

                      decoration: BoxDecoration(
                          color: select_duration.index == i
                              ? duration_colors[i]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(
                            getDurationLocalizationfromIndex(i, context),
                            style:
                                TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),
        Spacer(flex: 2),
        Row(
          children: [
            for (int i = 1; i <=8 ; i*=2)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      select_numOfChoose = i;
                      _updateNumOfChoose();
                    });
                  },
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: select_numOfChoose == i
                              ? vocabularyTypeBackgroundColors[i]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(
                            i.toString(),
                            style:
                            TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),
        Spacer(flex: 2),
        Row(
          children: [
            for (int i = 0; i <2 ; ++i)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      select_mode = VocabularyMode.values[i];
                      _updateMode();
                    });
                  },
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: select_mode.index == i
                              ? vocabularyTypeBackgroundColors[3+i]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(

                            getDrawerModeLocalizationfromIndex(i, context),
                            style:
                            TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),        Row(
          children: [
            for (int i = 2; i <4 ; ++i)
              Container(
                padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      select_mode = VocabularyMode.values[i];
                      _updateMode();
                    });
                  },
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: select_mode.index == i
                              ? vocabularyLevelBackgroundColors[i+1]
                              : vocabularyUnselectedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(

                            getDrawerModeLocalizationfromIndex(i, context),
                            style:
                            TextStyle(color: vocabularyLevelTextColor),
                          ))),
                ),
              ),
          ],
        ),Spacer(flex:2),
    Row(
        children: [
          for (int i = 0; i <4 ; ++i)
            Container(
              padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
              child: InkWell(
                onTap: () {
                setState(() {
                  _colorlabelOnTap(i);
              });
              },
                child: DecoratedBox(
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(6)),
                child: Container(
                padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                 child: AnimatedOpacity(
                    opacity:colorlabel_select[i]?1.0:0.3 ,
                    duration: Duration(milliseconds: 500),
                    child:Icon(
                        (colorlabel_select[i] && i!=0)?Icons.star_rounded:Icons.star_outline_rounded,
                        color: i==0?Colors.black:colorlabel_colors[i],
                        )
                    ),
                )
                        )
                        ),
              ),

            ],
        ),
        Row(
        children: [
          for (int i = 4; i <maxOfChoose ; ++i)
            Container(
              padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
              child: InkWell(
                onTap: () {
                  setState(() {
                  _colorlabelOnTap(i);
                  });
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(6)),
                  child: Container(
                  padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                  child: AnimatedOpacity(
                  opacity:colorlabel_select[i]?1.0:0.3 ,
                  duration: Duration(milliseconds: 500),
                  child:Icon(
                      (colorlabel_select[i] && i!=0)?Icons.star_rounded:Icons.star_outline_rounded,
                        color: i==0?Colors.black:colorlabel_colors[i],
                    )
                  ),
                  )
                ),
              ),
            ),
          ],
        ),
        Spacer(flex: 2),
        Row(
              children: [

                  Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                    child: InkWell(
                      onTap: () {
                        _save();
                      },
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: vocabularyUnselectedColor
                              borderRadius: BorderRadius.circular(6)),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: Text(

                                AppLocalizations.of(context)!.drawer_save,
                                style:
                                TextStyle(color: vocabularyLevelTextColor),
                              ))),
                    ),
                  ),
                  Container(
                  padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                        child: InkWell(
                          onTap: () {

                            _load();

                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: vocabularyUnselectedColor
                              borderRadius: BorderRadius.circular(6)),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                child: Text(

                                  AppLocalizations.of(context)!.drawer_load,
                                  style:
                                  TextStyle(color: vocabularyLevelTextColor),
                            ))),
                          ),
                        ),

              ],

        )
        Spacer(flex: 3),
      ],
    );

    return Container(
        width: 160,
        child: Drawer(
          child: child,
        ));
  }
}
