import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info_handler.dart';
import '../widgets/history_design_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final appInfo = Provider.of<AppInfoHandler>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(localizations.tripsHistory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: appInfo.allTripsHistoryInformation.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 80, color: Colors.white24),
                  const SizedBox(height: 20),
                  Text(
                    localizations.noRecordExistsWithRecord,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                return Card(
                  color: Colors.white10,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: HistoryDesignUIWidget(
                    tripsHistoryModel: appInfo.allTripsHistoryInformation[i],
                  ),
                );
              },
              itemCount: appInfo.allTripsHistoryInformation.length,
              physics: const BouncingScrollPhysics(),
            ),
    );
  }
}
