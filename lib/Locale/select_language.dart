import 'package:driver/Components/custom_button.dart';
import 'package:driver/Locale/language_cubit.dart';
import 'package:driver/Locale/locales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class ChooseLanguage extends StatefulWidget {
  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  LanguageCubit _languageCubit;
  List<int> radioButtons = [0, -1, -1, -1, -1];
  String selectedLanguage;

  @override
  void initState() {
    super.initState();
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    List<String> languages = [
      locale.englishh,
      locale.hindi,
      locale.spanish,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.languages,style: TextStyle(color:Theme.of(context). backgroundColor,),),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 20.0, left: 16, right: 16, bottom: 16),
            child: Text(
              locale.selectPreferredLanguage,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          RadioButtonGroup(
            activeColor: Theme.of(context).primaryColor,
            labelStyle: Theme.of(context).textTheme.caption,
            onSelected: (selectedLocale) {
              setState(() {
                selectedLanguage = selectedLocale;
              });
            },
            labels: languages,
            itemBuilder: (Radio radioButton, Text title, int i) {
              return Column(
                children: <Widget>[
                  Container(
                    height: 56.7,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        leading: radioButton,
                        title: Text(
                          languages[i],
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontSize: 19),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0)
                ],
              );
            },
          ),
          Spacer(),
          CustomButton(
            label: locale.save,
            onTap: () {
              if (selectedLanguage == locale.englishh) {
                _languageCubit.selectLanguage('en');
              } else if (selectedLanguage == locale.hindi) {
                _languageCubit.selectLanguage('hi');
              } else if (selectedLanguage == locale.spanish) {
                _languageCubit.selectLanguage('es');
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
