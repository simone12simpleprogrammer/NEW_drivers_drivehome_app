
import 'package:drivers_app/push_notifications/notification_repository.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'infoHandler/app_info.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
      MyApp(
        child: ChangeNotifierProvider(
          create: (context) => AppInfo(),
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Drivehome',
            theme: ThemeData(
              primarySwatch: Colors.grey,
              fontFamily:'Montserrat',
            ),
            home: const MySplashScreen(),
            debugShowCheckedModeBanner: false,
          ),
        )
      ),
  );
}



class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context)
  {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();


}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
 Key key = UniqueKey();

   void restartApp(){
     setState((){
      key = UniqueKey();
     });
   }


   @override
   void initState() {
    WidgetsBinding.instance.removeObserver(this);
    super.initState();

   }

   @override
   void dispose() {
     WidgetsBinding.instance.removeObserver(this);
     super.dispose();

   }

   @override
   void didChangeAppLifecycleState(AppLifecycleState state) {

   }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key:key,
      child:widget.child!,


    );
  }
}


