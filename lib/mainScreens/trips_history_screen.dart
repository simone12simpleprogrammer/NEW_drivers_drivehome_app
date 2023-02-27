import 'package:drivers_app/models/trips_history_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../infoHandler/app_info.dart';
import '../widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget
{

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen>
{
  @override
  Widget build(BuildContext context)
  {
    // Trova tutti i trip duplicati
    var tripsHistoryList = Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList;

    // Trasforma l'elenco in un dizionario
    var tripsHistoryMap = {};
    for (TripsHistoryModel model in tripsHistoryList) {
      // Si escludono i viaggi con stato diverso da "ended"
      if (model.status != 'ended') {
        continue;
      }

      // Crea una stringa unica per identificare il viaggio
      var uniqueTripId = '${model.originAddress}-${model.destinationAddress}-${model.userName}-${model.time}';
      tripsHistoryMap[uniqueTripId] = model;
    }

    // Crea una nuova lista unica
    var uniqueTripsHistoryList = tripsHistoryMap.values.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Storico Corse",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white,
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body:ListView.separated(
        separatorBuilder: (context, i) => const Divider(
          color: Colors.grey,
          thickness: 2,
          height: 2,
        ),
        itemBuilder: (context, i)
        {
          return Card(
            color: Colors.white54,
            child: HistoryDesignUIWidget(
              tripsHistoryModel: uniqueTripsHistoryList[i],
            ),
          );
        },
        itemCount: uniqueTripsHistoryList.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,

      ),
    );
  }
}
