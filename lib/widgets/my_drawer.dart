import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_user/infoHandler/app_info_handler.dart';
import 'package:uber_user/l10n/app_localizations.dart';
import '../global/global.dart';
import '../mainScreens/about_screen.dart';
import '../mainScreens/profile_screen.dart';
import '../mainScreens/trips_history_screen.dart';
import '../models/language_model.dart';
import '../splashScreen/splash_screen.dart';

class MyDrawer extends StatefulWidget {
  final String? name;
  final String? email;

  const MyDrawer({super.key, this.name, this.email});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  LanguageModel? chosenModel;
  final List<LanguageModel> languages = [
    LanguageModel(code: "en", name: "English"),
    LanguageModel(code: "de", name: "German"),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appInfo = Provider.of<AppInfoHandler>(context, listen: false);

    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.name ?? "User",
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.email ?? "email@example.com",
                  style: const TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Drawer Body
          _buildDrawerItem(
            icon: Icons.history,
            title: localizations.history,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const TripsHistoryScreen()));
            },
          ),

          _buildDrawerItem(
            icon: Icons.person_outline,
            title: localizations.visitProfile,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen()));
            },
          ),

          _buildDrawerItem(
            icon: Icons.info_outline,
            title: localizations.about,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const AboutScreen()));
            },
          ),

          const Divider(color: Colors.white12, height: 40),

          _buildDrawerItem(
            icon: Icons.logout,
            title: localizations.signOut,
            onTap: () async {
              await fAuth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()),
                  (route) => false,
                );
              }
            },
          ),

          // Language Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<LanguageModel>(
                  dropdownColor: Colors.black87,
                  isExpanded: true,
                  icon: const Icon(Icons.language, color: Colors.white70),
                  value: chosenModel,
                  hint: const Text("Language", style: TextStyle(color: Colors.white70)),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        chosenModel = newValue;
                        appInfo.setLocale(Locale(newValue.code!));
                      });
                    }
                  },
                  items: languages.map((lang) {
                    return DropdownMenuItem<LanguageModel>(
                      value: lang,
                      child: Text(lang.name!, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      onTap: onTap,
    );
  }
}
