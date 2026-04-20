import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uber_user/main.dart';

import '../infoHandler/app_info_handler.dart';
import '../widgets/history_design_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TripsHistoryScreen extends StatefulWidget {
  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          AppLocalizations.of(context)!.tripsHistory,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            MyApp.restartApp(context);
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, i) => const Divider(
          color: Colors.grey,
          thickness: 2,
          height: 2,
        ),
        itemBuilder: (context, i) {
          if (Provider.of<AppInfoHandler>(context, listen: false)
              .allTripsHistoryInformation
              .isNotEmpty) {
            return Card(
              color: Colors.white54,
              child: HistoryDesignUIWidget(
                tripsHistoryModel:
                    Provider.of<AppInfoHandler>(context, listen: false)
                        .allTripsHistoryInformation[i],
              ),
            );
          } else {
            return const Center(
              child: Text(
                "No trips.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }
        },
        itemCount: Provider.of<AppInfoHandler>(context, listen: false)
            .allTripsHistoryInformation
            .length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
