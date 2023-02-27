import 'package:drivers_app/mainScreens/trips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';

class EarningsTabPage extends StatefulWidget
{
  const EarningsTabPage({Key? key}) : super(key: key);

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage>
{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child:Column(
        children: [

          //guadagno totale in itestazione
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  
                  const Text(
                    "I tuoi guadagni",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10,),
                  
                  Text(
                    "\€ " + Provider.of<AppInfo>(context,listen: false).driverTotalEarnings,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                ],
              ),
            ),
          ),
          
          //totale numero corse
          ElevatedButton(
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryScreen()));
              },
            style: ElevatedButton.styleFrom(
              primary: Colors.white54,
            ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                child: Row(
                  children: [

                    Image.asset(
                        "images/car_logo.png",
                      width: 100,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    const Text(
                      "Corse Completate",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                    ),

                    Expanded(
                      child: Container(
                        child: Text(
                            Provider.of<AppInfo>(context,listen: false).allTripsHistoryInformationList.length.toString(),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
          ),
          
          

        ],

      ),
    );
  }
}
