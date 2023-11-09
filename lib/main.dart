import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatbot/screens/landing_screen.dart';
import 'package:provider/provider.dart';
import 'screens/theme_notifier.dart'; // Don't forget to create this file as described in the previous response


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    /*ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(ThemeData.light()),
      child: MyApp(),
    ),*/

    MultiProvider(providers: [
      
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(ThemeData.light()),
      ),

      ChangeNotifierProvider<FontSizeNotifier>(create: (_) => FontSizeNotifier(),),

      ChangeNotifierProvider<BoldTextNotifier>(create: (_) => BoldTextNotifier(),),

      
    ],
    child: MyApp(),

    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    //added for size 
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);

    //final bold
    final boldTextNotifier = Provider.of<BoldTextNotifier>(context); 


    //added 
    ThemeData appTheme = themeNotifier.getTheme();

    
    appTheme = appTheme.copyWith(
      textTheme: appTheme.textTheme.copyWith(
        // use bodyLarge to make text bigger 
        bodyLarge: appTheme.textTheme.bodyLarge?.copyWith(
          fontSize: fontSizeNotifier.primaryTextSize,
        ),

        // use bodySmall for cases like subtext 
        bodySmall: appTheme.textTheme.bodySmall?.copyWith(
          fontSize: fontSizeNotifier.fontSize,
        )
      )
    );
    

    

    if (boldTextNotifier.isBold) {
      appTheme = appTheme.copyWith(
        textTheme: appTheme.textTheme.copyWith(

          bodyLarge: appTheme.textTheme.bodyLarge?.copyWith(
            
            fontWeight: FontWeight.bold,
          ),
          bodySmall: appTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold, 
          )

          
        ),
      );
    } else {
       appTheme = appTheme.copyWith(
        textTheme: appTheme.textTheme.copyWith(
          bodyLarge: appTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.normal,
          ),
          //bodySmall: appTheme.text

          
        ),
      );

    }

    //end of added code 

    return MaterialApp(
      initialRoute: '/',
      //theme: themeNotifier.getTheme(),
      
      //added
      theme: appTheme,
      
      routes: {
        '/': (context) => LandingScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
