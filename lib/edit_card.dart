import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'common_helper.dart';
import 'db.dart';


/// For ListCard widget inform this widget which vocabulary user selected
class EditArguments {
  final String vocabulary;
  EditArguments(this.vocabulary);
}


class _NewCardTextFormField extends StatelessWidget {
  const _NewCardTextFormField({
    this.hintText,
    this.labelText,
    this.icon,
    this.validator,
    this.onchanged,
    this.controllers,
    this.enable=true,
    required this.state,
    required this.index,
  });
  final String? hintText;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final onchanged;
  final Widget? icon;
  final _EditCardStatefulWidgetState state;
  final int index;
  final List<TextEditingController>? controllers;
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 20.0),
      child: TextFormField(
        enabled: true,
        readOnly: !enable!,
        controller: controllers![index],
        decoration: InputDecoration(
          icon: icon,
          hintText: hintText,
          labelText: labelText,
          contentPadding: EdgeInsets.all(10.0),
        ),
        onSaved: (String? value) {
          // This optional block of code can be used to run
          // code when the user saves the form.
          if (value == null) return;
        },
        // The validator receives the text that the user has entered.
        validator: validator,
        onChanged: onchanged,
      ),
    );
  }
}

class _TypeListTile extends StatelessWidget {
  const _TypeListTile({
    required this.type,
    required this.state,
    this.title,
  });
  final VocabularyType type;
  final _EditCardStatefulWidgetState state;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      title: this.title != null
          ? this.title
          : Text(getVocabularyTypeLocalizationfromIndex(type.index, context)),
      leading: Radio<VocabularyType>(
        value: type,
        groupValue: state._selectedType,
        onChanged: (VocabularyType? value) {
          state.setState(() {
            state._selectedType = value;
          });
        },
      ),
    );
  }
}

class _LevelListTile extends StatelessWidget {
  const _LevelListTile({
    required this.state,
    required this.index,
  });

  final _EditCardStatefulWidgetState state;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      title: Row(children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 2, 3, 2),
          child: Text(getVocabularyLevelLocalizationfromIndex(index, context)),
        ),
        DecoratedBox(
            decoration: BoxDecoration(
                color: vocabularyLevelBackgroundColors[index],
                borderRadius: BorderRadius.circular(6)),
            child: Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                child: Text(
                  getVocabularyLevelCerfLocalizationfromIndex(index, context),
                  style: TextStyle(color: vocabularyLevelTextColor),
                ))),
      ]),
      leading: Radio<VocabularyLevel>(
        value: VocabularyLevel.values[index],
        groupValue: state._selectedLevel,
        onChanged: (VocabularyLevel? value) {
          state.setState(() {
            state._selectedLevel = value;
          });
        },
      ),
    );
  }
}

class EditCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: EditCardStatefulWidget());
  }
}

class EditCardStatefulWidget extends StatefulWidget {
  EditCardStatefulWidget({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _EditCardStatefulWidgetState createState() => _EditCardStatefulWidgetState();
}

class _EditCardStatefulWidgetState extends State<EditCardStatefulWidget> {
  final _formKey = GlobalKey<FormState>();

  /// true - new mode, false - edit mode
  bool _isNew = true;

  /// true when this widge have been called from the listcard
  bool _fromlist = false;

  VocabularyType? _selectedType = VocabularyType.Noun;
  VocabularyType? _otherSelectedType = VocabularyType.Prep;

  VocabularyLevel? _selectedLevel = VocabularyLevel.A1;

  List<TextEditingController>? _textEditingControllers =
      List.generate(3, (index) => TextEditingController(text: ""));

  int _colorlabel = 0;

  /// For temporary storage new vocabulary user input for reteive from edit vocabulary mode
  VocCard? _tempNewTextStatus;

  void _resetAllfield() {
    setState(() {
      _selectedType = VocabularyType.Noun;
      _otherSelectedType = VocabularyType.Prep;
      _selectedLevel = VocabularyLevel.A1;
      _colorlabel = 0;
    });

    _resetAllTextfield();
  }

  void _resetAllTextfield() {
    setState(() {
      for (int i = 0; i < 3; i++) _textEditingControllers![i].clear();
    });
  }

  /// Call every vocabulary field changed for mode (new or edit) switch
  ///
  /// Storage the existing user input and get data from db when the vocabulary existed,
  /// retrieve user input when vocabulary can't be found in database.
  _modeSwitch(String value) async {
    List<VocCard> list = await Db.getCards(value);

    bool isNew = list.isEmpty;

    setState(() {

      if (_isNew != isNew) {
        VocCard? card;
        if (!isNew) {
          _tempNewTextStatus = VocCard(
              vocabulary: "",
              type: _selectedType!,
              level: _selectedLevel!,
              mean: _textEditingControllers![1].text,
              note: _textEditingControllers![2].text,
              colorlabel: _colorlabel);
          card = list[0];
        } else {
          card = _tempNewTextStatus;
        }

        if (card != null) {
          _selectedLevel = card.level!;
          _selectedType = card.type!;
          _textEditingControllers![1].text = card.mean!;
          _textEditingControllers![2].text = card.note!;
          _colorlabel = card.colorlabel!;
        }
      }
    });
    _isNew = isNew;
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      EditArguments args =
          ModalRoute.of(context)!.settings.arguments as EditArguments;

      _textEditingControllers![0].text = args.vocabulary;

      _modeSwitch(_textEditingControllers![0].text);

      setState(() {
        _fromlist = true;
      });
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text(
                  _isNew
                      ? AppLocalizations.of(context)!.editcard_newcard_title
                      : AppLocalizations.of(context)!.editcard_editcard_title,
                  style: appbarTitleStyle),
              backgroundColor: appbarBackgroundColor,
              foregroundColor: appbarForegroundColor,
              iconTheme: IconThemeData(color: appbarForegroundColor),
            ),
            _NewCardTextFormField(
              hintText: AppLocalizations.of(context)!.editcard_voc_hint_text,
              labelText: AppLocalizations.of(context)!.editcard_voc_label_text,
              state: this,
              controllers: _textEditingControllers,
              index: 0,
              enable: !_fromlist,
              icon: IconButton(
                icon: Icon(
                  _colorlabel == 0 ? Icons.star_outline_rounded : Icons.star_rounded,
                  color: _colorlabel == 0
                      ? Colors.black
                      : colorlabel_colors[_colorlabel],
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _colorlabel = _colorlabel + 1;
                    if (_colorlabel >= colorlabel_colors.length)
                      _colorlabel = 0;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .editcard_voc_field_invalid_noinput;
                }
                if (value.indexOf(' ') != -1) {
                  return AppLocalizations.of(context)!
                      .editcard_voc_field_invalid_withspace;
                }

                return null;
              },
              onchanged: (value) async {
                if (_formKey.currentState!.validate()) {

                }
                _modeSwitch(value);
                return null;
              },
            ),
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.blueGrey)),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 5, top: 2),
                    child: Text(
                      AppLocalizations.of(context)!.editcard_type_label,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _TypeListTile(
                    type: VocabularyType.Noun,
                    state: this,
                  ),
                  _TypeListTile(
                    type: VocabularyType.Verb,
                    state: this,
                  ),
                  _TypeListTile(
                    type: VocabularyType.Adj,
                    state: this,
                  ),
                  _TypeListTile(
                    type: VocabularyType.Adv,
                    state: this,
                  ),
                  _TypeListTile(
                    type: _otherSelectedType!,
                    state: this,
                    title: DropdownButton<VocabularyType>(
                      value: _otherSelectedType,
                      isDense: true,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 16,
                      elevation: 16,
                      style: const TextStyle(color: Colors.blueGrey),
                      underline: Container(
                        height: 2,
                        color: Colors.blueGrey,
                      ),
                      onChanged: (VocabularyType? newValue) {
                        setState(() {
                          _otherSelectedType = newValue!;
                          _selectedType = newValue;
                        });
                      },
                      items: <VocabularyType>[
                        VocabularyType.Prep,
                        VocabularyType.Pron,
                        VocabularyType.Deter,
                        VocabularyType.Conj
                      ].map<DropdownMenuItem<VocabularyType>>(
                          (VocabularyType value) {
                        return DropdownMenuItem<VocabularyType>(
                          value: value,
                          child: Text(getVocabularyTypeLocalizationfromIndex(
                              value.index, context)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black)),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.editcard_level_label,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (int i = 5; i >= 0; i--)
                    _LevelListTile(state: this, index: i),
                ],
              ),
            ),
            _NewCardTextFormField(
              hintText:
                  AppLocalizations.of(context)!.editcard_voc_meaning_hint_text,
              labelText:
                  AppLocalizations.of(context)!.editcard_voc_meaning_label_text,
              icon: Icon(Icons.question_answer, size: 24),
              controllers: _textEditingControllers,
              index: 1,
              state: this,
            ),
            _NewCardTextFormField(
              hintText:
                  AppLocalizations.of(context)!.editcard_voc_note_hint_text,
              labelText:
                  AppLocalizations.of(context)!.editcard_voc_note_label_text,
              icon: Icon(Icons.notes, size: 24),
              controllers: _textEditingControllers,
              index: 2,
              state: this,
            ),
            Row(children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      if (!kReleaseMode &&
                          _textEditingControllers![0].text == '%%fake%%') {
                        await Db.buildFakeData();
                        return;
                      }

                      VocCard card = VocCard(
                          vocabulary: _textEditingControllers![0].text,
                          type: _selectedType!,
                          level: _selectedLevel!,
                          mean: _textEditingControllers![1].text,
                          note: _textEditingControllers![2].text,
                          colorlabel: _colorlabel);

                      if (_isNew) {
                        int result = await Db.insertCard(card);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result > 0
                                ? AppLocalizations.of(context)!
                                    .editcard_submit_message_sucessful(
                                        card.vocabulary!)
                                : AppLocalizations.of(context)!
                                    .editcard_submit_message_failure(
                                        card.vocabulary!))));
                        if (result > 0) _resetAllTextfield();
                      } else {
                        int result = await Db.updateCard(card);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result > 0
                                ? AppLocalizations.of(context)!
                                    .editcard_change_message_sucessful(
                                        card.vocabulary!)
                                : AppLocalizations.of(context)!
                                    .editcard_change_message_failure(
                                        card.vocabulary!))));
                      }

                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.

                    }
                  },
                  child: Text(_isNew
                      ? AppLocalizations.of(context)!.editcard_submit
                      : AppLocalizations.of(context)!.editcard_change),
                ),
              ),
              if (!_isNew)
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        String vocabulary = _textEditingControllers![0].text;

                        int result = await Db.deleteCard(vocabulary);

                        // Db.closeDB();
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result > 0
                                ? AppLocalizations.of(context)!
                                    .editcard_delete_message_sucessful(
                                        vocabulary)
                                : AppLocalizations.of(context)!
                                    .editcard_delete_message_failure(
                                        vocabulary))));
                        if (_fromlist) Navigator.pop(context);
                        _resetAllfield();
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.editcard_delete),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}
