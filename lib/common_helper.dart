import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum VocabularyType { Noun, Verb, Adj, Adv, Prep, Pron, Deter, Conj }
enum VocabularyLevel { C2, C1, B2, B1, A2, A1 }
enum VocabularyDatePeriod { Today, Week, Month, Year, All }
enum VocabularyMode { New, Wrong, Correct, All }

const appbarTitleDrawerIcon = Icons.view_headline;

const appbarTitleBackIcon = Icons.arrow_back;

const appbarForegroundColor = Colors.black;

const appbarBackgroundColor = Colors.white;

const appbarTitleStyle = TextStyle(color: appbarForegroundColor, fontFamily: 'Georgia', fontSize: 16);


const vocabularyLevelTextColor = Color(0xFCFFFFFF);

const vocabularyUnselectedColor = Colors.grey;
const maxOfChoose = 8;

const vocabularyLevelBackgroundColors = [
  Colors.lightGreen,
  Colors.green,
  Colors.lightBlueAccent,
  Colors.lightBlue,
  Colors.purple,
  Colors.deepPurple
];

const vocabularyTypeBackgroundColors = [
  Colors.red,
  Colors.purple,
  Colors.lightBlueAccent,
  Colors.amber,
  Colors.blueGrey,
  Colors.deepPurple,
  Colors.deepOrange,
  Colors.lime,
  Colors.deepPurpleAccent
];

String getVocabularyTypeLocalizationfromIndex(int index, BuildContext context) {
  switch (index) {
    case 7:
      return AppLocalizations.of(context)!.voc_type_conj;
    case 6:
      return AppLocalizations.of(context)!.voc_type_deter;
    case 5:
      return AppLocalizations.of(context)!.voc_type_pron;
    case 4:
      return AppLocalizations.of(context)!.voc_type_prep;
    case 3:
      return AppLocalizations.of(context)!.voc_type_adv;
    case 2:
      return AppLocalizations.of(context)!.voc_type_adj;
    case 1:
      return AppLocalizations.of(context)!.voc_type_verb;
    case 0:
    default:
      return AppLocalizations.of(context)!.voc_type_noun;
  }
}

String getVocabularyLevelLocalizationfromIndex(
    int index, BuildContext context) {
  switch (index) {
    case 5:
      return AppLocalizations.of(context)!.voc_level_elem;
    case 4:
      return AppLocalizations.of(context)!.voc_level_preInter;
    case 3:
      return AppLocalizations.of(context)!.voc_level_inter;
    case 2:
      return AppLocalizations.of(context)!.voc_level_upperInter;
    case 1:
      return AppLocalizations.of(context)!.voc_level_preadv;
    case 0:
    default:
      return AppLocalizations.of(context)!.voc_level_adv;
  }
}

String getVocabularyLevelCerfLocalizationfromIndex(
    int index, BuildContext context) {
  switch (index) {
    case 5:
      return AppLocalizations.of(context)!.voc_level_elem_cefr;
    case 4:
      return AppLocalizations.of(context)!.voc_level_preInter_cefr;
    case 3:
      return AppLocalizations.of(context)!.voc_level_inter_cefr;
    case 2:
      return AppLocalizations.of(context)!.voc_level_upperInter_cefr;
    case 1:
      return AppLocalizations.of(context)!.voc_level_preadv_cefr;
    case 0:
    default:
      return AppLocalizations.of(context)!.voc_level_adv_cefr;
  }
}

const duration_colors = [
  Colors.blueGrey,
  Colors.deepOrange,
  Colors.lightBlue,
  Colors.lime,
  Colors.red

];

const colorlabel_colors = [
  Colors.white,
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.purple,
  Colors.pink,
  Colors.lime,
  Colors.amber

];


String getDurationLocalizationfromIndex(
    int index, BuildContext context) {
  switch (index) {

    case 4:
      return AppLocalizations.of(context)!.duration_all;
    case 3:
      return AppLocalizations.of(context)!.duration_yearly;
    case 2:
      return AppLocalizations.of(context)!.duration_monthly;
    case 1:
      return AppLocalizations.of(context)!.duration_weekly;
    case 0:
    default:
      return AppLocalizations.of(context)!.duration_daily;
  }
}

String getDrawerModeLocalizationfromIndex(
    int index, BuildContext context) {
  switch (index) {
    case 3:
      return AppLocalizations.of(context)!.drawer_all;
    case 2:
      return AppLocalizations.of(context)!.drawer_wrong;
    case 1:
      return AppLocalizations.of(context)!.drawer_correct;
    case 0:
    default:
      return AppLocalizations.of(context)!.drawer_new;
  }
}




