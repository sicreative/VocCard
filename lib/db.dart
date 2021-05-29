import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'common_helper.dart';
import 'package:csv/csv.dart';


class Db {
  static int dbversion = 1;
  static const String db_file = 'card_database.db';
  static const String db_table = "cards";
  static const String db_preftable = "pref";
  static Db? _self;
  static String db_search = "";
  Future<Database>? database;

  List<String>? _shiffle;
  VocabularyQuiz? _quiz;

  Db() {}

  static Future<void> openDB() async {
    if (_self == null) _self = Db();

    if (_self!.database == null) await _self!._openDB();

    final Database db = (await _self!.database)!;

    if (!db.isOpen) await _self!._openDB();

    return;
  }

  Future<void> _openDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), db_file),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE pref(id INTEGER PRIMARY KEY,type INTEGER, level INTEGER,duration INTEGER,mode INTEGER,numofchoose INTEGER,colorlabel INTEGER)");

        db.insert(db_preftable, {
          'id': 0,
          'type': 0xFFFFFF,
          'level': 0xFFFFFF,
          'duration': 0,
          'mode': 3,
          'numofchoose': 4,
          'colorlabel': 0xFFFFFF,
        });

        return db.execute(
          "CREATE TABLE cards(id INTEGER PRIMARY KEY AUTOINCREMENT, vocabulary TEXT NOT NULL UNIQUE,"
          "type INTERGER,level INTERGER,mean TEXT,note TEXT, colorlabel INTEGER, addtime INTEGER, lastacesstime INTEGER,"
          "show_count INTERGER,wrong_count INTERGER, correct_count INTERGER)",
        );
      },
      onUpgrade: (db, oldversion, newversion) {
        // Work for latest upgrade
      },
      onDowngrade: (db, oldversion, newversion) {
        // Not possible downgrade
        assert(oldversion <= newversion);
      },

      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: dbversion,
    );

    assert(database != null);

    _builtShuffleTable();
  }

  static Future<void> closeDB() async {
    if (_self != null) _self!._closeDB();

    _self = null;
  }

  Future<void> _closeDB() async {
    if (database == null) return;
    final Database db = await database!;
    if (db.isOpen) db.close();

    assert(!db.isOpen);
  }

  static Future<int> insertCsv(String csv) async {
    List<List> list = CsvToListConverter().convert(csv);

    int count = 0;

    if (list.length < 2 || list[0].length != 11) return count;

    for (int i = 1; i < list.length; ++i) {
      try {
        VocCard card = VocCard(
            vocabulary: list[i][0],
            type: VocabularyType.values[list[i][1]],
            level: VocabularyLevel.values[list[i][2]],
            note: list[i][3],
            mean: list[i][4],
            show_count: list[i][5],
            wrong_count: list[i][6],
            correct_count: list[i][7],
            addtime:
                DateTime.fromMicrosecondsSinceEpoch(list[i][8], isUtc: true),
            lastacesstime:
                DateTime.fromMicrosecondsSinceEpoch(list[i][9], isUtc: true),
            colorlabel: list[i][10]);

        await Db.insertUpdateCard(card);
        ++count;
      } on FormatException {
        continue;
      }
    }

    return count;
  }

  static Future<String> getAllCsv() async {
    return getCsv(await getAllCards());
  }

  static String getCsv(List<VocCard> cards) {
    if (cards.isEmpty) return '';

    List<List<dynamic>> csvlist = List.generate(cards.length + 1, (index) {
      if (index == 0) return VocCard.toListHeader();

      return cards[index - 1].toList();
    });

    //header

    return ListToCsvConverter().convert(csvlist);
  }

  static Future<int> updateCard(VocCard card) async {
    if (_self == null) openDB();

    return _self!._updateCard(card);
  }

  Future<int> _updateCard(VocCard card) async {
    // Get a reference to the database.
    if (database == null) openDB();

    final Database db = await database!;

    if (!db.isOpen) throw ("db is not open!");

    if ((await getCards(card.vocabulary)).isEmpty)
      throw ("can't found the vocabulary");

    int result = await db.update(
      db_table,
      card.toMap(),
      where: 'vocabulary = ?',
      whereArgs: [card.vocabulary],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    //Rebuilt shuffle table
    _builtShuffleTable();

    return result;
  }

  static Future<int> insertUpdateCard(VocCard card) async {
    if (_self == null) openDB();

    return _self!._insertUpdateCard(card);
  }

  static Future<int> insertCard(VocCard card) async {
    if (_self == null) openDB();

    return _self!._insertCard(card);
  }

  Future<int> _insertUpdateCard(VocCard card) async {
    // Get a reference to the database.
    if (database == null) openDB();

    final Database db = await database!;

    if (!db.isOpen) throw ("db is not open!");

    int result = await db.insert(
      db_table,
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    //Rebuilt shuffle table
    _builtShuffleTable();

    return result;
  }

  Future<int> _insertCard(VocCard card) async {
    // Get a reference to the database.
    if (database == null) openDB();

    final Database db = await database!;

    if (!db.isOpen) throw ("db is not open!");

    if ((await getCards(card.vocabulary)).isNotEmpty)
      throw ("the vocabulary already inserted");

    int result = await db.insert(
      db_table,
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    //Rebuilt shuffle table
    _builtShuffleTable();

    return result;
  }

  static Future<int> deleteAllCards() async {
    if (_self == null) openDB();
    return _self!._deleteCards(null);
  }

  static Future<int> deleteCard(String? voc) async {
    if (_self == null) openDB();

    return _self!._deleteCards([voc!]);
  }

  static Future<int> deleteCards(List<String> voc) async {
    if (_self == null) openDB();

    return _self!._deleteCards(voc);
  }

  Future<int> _deleteCards(List<String>? voc) async {
    if (database == null) await _openDB();
    final Database db = await database!;
    if (voc == null)
      return db.delete(db_table);
    else
      return db.delete(db_table, where: 'vocabulary=?', whereArgs: voc);
  }

  static Future<List<VocCard>> getAllCards() async {
    return getCards(null);
  }

  static Future<List<VocCard>> getCardsPref(int offset) async {
    if (_self == null) openDB();
    return _self!._getCards(null, offset: offset, pref: true);
  }

  static Future<List<VocCard>> getCardsPrefLimit(int limit, int offset) async {
    if (_self == null) openDB();
    return _self!._getCards(null, limit: limit, offset: offset, pref: true);
  }

  static Future<List<VocCard>> getCards(String? voc) async {
    if (_self == null) openDB();

    return _self!._getCards(voc);
  }

  static Future<int> getNumOfCard({bool withpref = true}) async {
    if (_self == null) openDB();

    return _self!._getNumOfCard(withpref: withpref);
  }

  Future<int> _getNumOfCard({bool withpref = true}) async {
    final Database db = await database!;

    final List<Map<String, dynamic>> maps = await db.query(db_table,
        columns: ['COUNT(*)'], where: withpref ? await _getPrefWhere() : null);
    return maps[0]['COUNT(*)'];
  }

  Future<String> _getPrefWhere() async {
    final Database db = await database!;
    final List<Map<String, dynamic>> prefs = await db.query(db_preftable);

    int type = prefs[0]['type'];
    int level = prefs[0]['level'];
    int duration = prefs[0]['duration'];
    int mode = prefs[0]['mode'];
    int colorlabel = prefs[0]['colorlabel'];

    StringBuffer where = StringBuffer();

    for (int i = 0; i < VocabularyType.values.length; i++) {
      if ((type & 1) == 0) {
        if (where.isNotEmpty) {
          where.write(' AND ');
        }

        where.write('NOT type=$i');
      }
      type >>= 1;
    }

    for (int i = 0; i < vocabularyLevelBackgroundColors.length; i++) {
      if ((level & 1) == 0) {
        if (where.isNotEmpty) {
          where.write(' AND ');
        }

        where.write('NOT level=$i');
      }
      level >>= 1;
    }

    for (int i = 0; i < colorlabel_colors.length; i++) {
      if ((colorlabel & 1) == 0) {
        if (where.isNotEmpty) {
          where.write(' AND ');
        }
        where.write('NOT colorlabel=$i');
      }
      colorlabel >>= 1;
    }

    DateTime time = DateTime.now();

    if (duration == VocabularyDatePeriod.Today.index)
      time = time.subtract(Duration(
          minutes: time.minute, seconds: time.second, hours: time.hour));
    if (duration == VocabularyDatePeriod.Week.index)
      time = time.subtract(Duration(days: 7));
    else if (duration == VocabularyDatePeriod.Month.index) {
      int day = time.day;
      int month = time.month;
      while (month == time.month || day < time.day)
        time = time.subtract(Duration(days: 1));
    } else if (duration == VocabularyDatePeriod.Year.index) {
      int leap = time.year % 4 == 0 ? 1 : 0;
      if (time.year % 100 == 0 && time.year % 400 != 0) leap = 0;
      time = time.subtract(Duration(days: 365 + leap));
    } else if (duration == VocabularyDatePeriod.All.index) {
      time = DateTime.fromMicrosecondsSinceEpoch(0);
    }

    int secondsSinceEpoch = time.microsecondsSinceEpoch;

    if (where.isNotEmpty) {
      where.write(' AND ');
    }
    where.write('( addtime >= $secondsSinceEpoch ) ');

    if (Db.db_search != "") {
      String val = Db.db_search;
      val = val.replaceAll(RegExp(r'%'), ' %');
      val = val.replaceAll(RegExp(r'_'), ' _');

      if (where.isNotEmpty) {
        where.write(' AND ');
      }

      where.write(" ( vocabulary LIKE '%$val%' ESCAPE ' ') ");
    }

    if (mode != VocabularyMode.All.index) {
      where.write(' AND ');

      if (mode == VocabularyMode.New.index)
        where.write(' ( wrong_count = 0 AND correct_count = 0 ) ');
      else if (mode == VocabularyMode.Correct.index)
        where.write(' ( correct_count > 0 ) ');
      else if (mode == VocabularyMode.Wrong.index)
        where.write(' ( wrong_count > 0 ) ');
    }

    return where.toString();
  }

  Future<List<VocCard>> _getCards(String? voc,
      {int limit = 9999999999, int offset = 0, bool pref = false}) async {
    if (database == null) await _openDB();
    final Database db = await database!;

    late List<Map<String, dynamic>> maps;

    if (voc != null) {
      maps = await db.query(db_table, where: "vocabulary = '$voc'");
    } else {
      String orderby = "vocabulary";

      String where = await _getPrefWhere();

      if (pref)
        maps = await db.query(db_table,
            orderBy: orderby, limit: limit, offset: offset, where: where);
      else
        maps = await db.query(db_table,
            orderBy: orderby, limit: limit, offset: offset);
    }

    return List.generate(maps.length, (i) {
      return VocCard(
          vocabulary: maps[i]['vocabulary'],
          type: VocabularyType.values[maps[i]['type']],
          level: VocabularyLevel.values[maps[i]['level']],
          mean: maps[i]['mean'],
          note: maps[i]['note'],
          show_count: maps[i]['show_count'],
          wrong_count: maps[i]['wrong_count'],
          correct_count: maps[i]['correct_count'],
          addtime: DateTime.fromMicrosecondsSinceEpoch(maps[i]['addtime'],
              isUtc: true),
          lastacesstime: DateTime.fromMicrosecondsSinceEpoch(
              maps[i]['lastacesstime'],
              isUtc: true),
          colorlabel: maps[i]['colorlabel']);
    });
  }

  Future<void> _builtShuffleTable() async {
    if (database == null) return;
    final Database db = await database!;
    final int limit = 50;

    final List<Map<String, dynamic>> maps = await db.query(db_table,
        columns: ['vocabulary'],
        orderBy: 'RANDOM()',
        where: await _getPrefWhere(),
        limit: limit);

    _shiffle = List.generate(maps.length, (index) => maps[index]['vocabulary']);
  }

  static void resetShuttle() {
    if (_self != null) _self!._shiffle = null;
  }

  static void getQuiz(
      int numOfChoose, ValueChanged<VocabularyQuiz> quizChanged) async {
    if (_self == null) await openDB();

    _self!._getQuiz(numOfChoose, quizChanged);
  }

  Future<void> _getQuiz(
      int numOfChoose, ValueChanged<VocabularyQuiz> quizChanged) async {
    if (_shiffle == null || _shiffle!.length < numOfChoose)
      await _builtShuffleTable();

    List<VocCard> cards = List.empty(growable: true);

    while (_shiffle != null && _shiffle!.length > 0 && --numOfChoose >= 0) {
      List<VocCard> card = await getCards(_shiffle!.last);

      cards.add(card[0]);

      _shiffle!.removeLast();
    }
    if (cards.isNotEmpty) {
      cards[0].lastacesstime = DateTime.now();
      cards[0].show_count = cards[0].show_count! + 1;
      updateCard(cards[0]);
    }
    _quiz = VocabularyQuiz(cards);
    quizChanged(_quiz!);
  }

  static void setPref(String type, int value) async {
    if (_self == null) await openDB();
    _self!._setPref(type, value);
  }

  Future<int> _setPref(String type, int value) async {
    final Database db = await database!;
    return db.update(db_preftable, {'$type': '$value'});
  }

  static Future<void> getNumOfChoose(
      void Function(int numOfChoose) callback) async {
    final num = await getPref("numofchoose");
    callback(num);
  }

  static Future<int> getPref(String type) async {
    if (_self == null) await openDB();
    return _self!._getPref(type);
  }

  Future<int> _getPref(String type) async {
    if (database == null) return 0;
    final Database db = await database!;
    final List<Map<String, dynamic>> prefs = await db.query(db_preftable);
    return prefs[0][type];
  }

/// For testing purpose, build fake data
  static Future<void> buildFakeData() async {
    await Db.deleteAllCards();

    for (int i = 0; i < 1000; i++) {
      VocCard card = VocCard(
          vocabulary: "fake$i",
          type: VocabularyType.values[i % VocabularyType.values.length],
          level: VocabularyLevel.values[i % VocabularyLevel.values.length],
          mean: "fake mean $i",
          note: "fake note $i");

      await Db.insertCard(card);
    }
  }
}

/// Encapsulate data for each Vocabulary
class VocCard {
  DateTime? addtime;
  DateTime? lastacesstime;
  int? colorlabel;
  final String? vocabulary;
  String? mean;
  String? note;
  VocabularyType? type;
  VocabularyLevel? level;
  int? show_count;
  int? wrong_count;
  int? correct_count;
  bool delete = false;

  VocCard(
      {required this.vocabulary,
      required this.type,
      required this.level,
      required this.mean,
      required this.note,
      this.addtime,
      this.lastacesstime,
      this.colorlabel = 0,
      this.show_count = 0,
      this.wrong_count = 0,
      this.correct_count = 0}) {
    if (addtime == null) addtime = DateTime.now();
    if (lastacesstime == null)
      lastacesstime = DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
  }

  List<dynamic> toList() {
    return [
      vocabulary,
      type!.index,
      level!.index,
      note,
      mean,
      show_count,
      wrong_count,
      correct_count,
      addtime!.toUtc().microsecondsSinceEpoch,
      lastacesstime!.toUtc().microsecondsSinceEpoch,
      colorlabel
    ];
  }

  static List<String> toListHeader() {
    return [
      'vocabulary',
      'type',
      'level',
      'note',
      'mean',
      'show_count',
      'wrong_count',
      'correct_count',
      'addtime',
      'lastacesstime',
      'colorlabel'
    ];
  }

  Map<String, dynamic> toMap() {
    return Map.fromIterables(toListHeader(), toList());
  }

  @override
  String toString() {
    return 'Card{ vocabulary: $vocabulary, type: $type, level: $level,'
        ' addtime:$addtime, lastaccesstime:$lastacesstime'
        ' note: $note, colorlabel: $colorlabel, show_count: $show_count, wrong_count: $wrong_count, correct_count: $correct_count }';
  }
}

/// Encapsulate class for each Quiz
///
/// _cards should provide for initialise as the first (index:0) is the correct answer
/// A sequence list will be build up for card display sequence
class VocabularyQuiz {
  List<VocCard> _cards;
  int numOfChoose = 0;
  int _ans = 0;
  List<String>? _seq;
  List<bool>? _selected;
  bool _choosed = false;

  VocabularyQuiz(this._cards) {
    numOfChoose = _cards.length;
    shuffle();
  }

  /// shuffle the sequence list to make the answer on random position
  List<String>? shuffle() {
    _seq = List.generate(numOfChoose, (index) => _cards[index].vocabulary!);
    _selected = List.generate(numOfChoose, (index) => false);
    List<int> seq = List.generate(numOfChoose, (index) => index);

    seq.shuffle();

    for (int i = 0; i < numOfChoose; i++) {
      _seq![i] = _cards[seq[i]].mean!;
      _selected![i] = false;
      if (seq[i] == 0) _ans = i;
    }

    return _seq;
  }

  String getVocabulary() {
    return numOfChoose == 0 ? "" : _cards[0].vocabulary!;
  }

  List<String>? getChoose() {
    return _seq;
  }

  int getAns() {
    return _ans;
  }

  bool checkAns(int index) {
    if (_selected == null) return false;
    _selected![index] = true;
    bool ans = isCorrect(index);
    if (ans)
      addCorrectCount();
    else
      addWrongCount();
    return (ans);
  }

  void resetSelected(int index) {
    _selected![index] = false;
  }

  bool isSelected(int index) {
    if (_selected == null) return false;

    return _selected![index];
  }

  bool isCorrect(int index) {
    return getAns() == index;
  }

  void addWrongCount() {
    if (_choosed) return;

    _cards[0].wrong_count = _cards[0].wrong_count! + 1;
    Db.updateCard(_cards[0]);
    _choosed = true;
  }


  /// Only first attempt will be counted as correct
  /// wrong_count will be reset to 0 when correct ans choosed on first try
  void addCorrectCount() {

    if (_choosed) return;
    _cards[0].wrong_count = 0;
    _cards[0].correct_count = _cards[0].correct_count! + 1;
    Db.updateCard(_cards[0]);
    _choosed = true;
  }

  VocCard getCollectCard() {
    return _cards[0];
  }
}

