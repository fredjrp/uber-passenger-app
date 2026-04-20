import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:uber_user/infoHandler/app_info_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../global/global.dart';
import '../mainScreens/about_screen.dart';
import '../mainScreens/profile_screen.dart';
import '../mainScreens/trips_history_screen.dart';
import '../models/language_model.dart';
import '../splashScreen/splash_screen.dart';

class MyDrawer extends StatefulWidget {
  String? name;
  String? email;

  MyDrawer({this.name, this.email});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  LanguageModel? chosenModel;
  List<LanguageModel> languages = List.empty(growable: true);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    languages.add(LanguageModel(code: "en", name: "English"));
    languages.add(LanguageModel(code: "de", name: "German"));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 12.0,
          ),

          //drawer body
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            },
            child: ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.white54,
              ),
              title: Text(
                AppLocalizations.of(context)!.history,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => ProfileScreen()));
            },
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.white54,
              ),
              title: Text(
                AppLocalizations.of(context)!.visitProfile,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => AboutScreen()));
            },
            child: ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.white54,
              ),
              title: Text(
                AppLocalizations.of(context)!.about,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              await fAuth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()));
            },
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.white54,
              ),
              title: Text(
                AppLocalizations.of(context)!.signOut,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: DropdownButton<LanguageModel>(
              dropdownColor: PRIMARY_COLOR,
              icon: Icon(
                Icons.arrow_drop_down_circle_rounded,
                color: Colors.white,
              ),
              underline: Container(),
              items: languages
                  .map<DropdownMenuItem<LanguageModel>>((LanguageModel value) {
                return DropdownMenuItem<LanguageModel>(
                  value: value,
                  child: Text(
                    value.name!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
              value: chosenModel,
              hint: Text(
                "Language",
                style: textMediumStyle.copyWith(fontWeight: FontWeight.w400),
              ),
              onChanged: (LanguageModel? newValue) {
                setState(() {
                  chosenModel = newValue;
                  Provider.of<AppInfoHandler>(context, listen: false)
                      .setLocale(Locale(newValue!.code!));
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
