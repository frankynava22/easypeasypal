import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/theme_notifier.dart';
import 'screens/font_size_notifier.dart';
import 'screens/font_weight_notifier.dart'; // Add this line for the FontWeightNotifier
import 'screens/landing_screen.dart';
import 'screens/identify_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  double initialFontSize = await loadFontSize(); // Load the saved font size

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(ThemeData.light()),
        ),
        ChangeNotifierProvider<FontSizeNotifier>(
          create: (_) => FontSizeNotifier(initialFontSize),
        ),
        ChangeNotifierProvider<FontWeightNotifier>(
          // Add the FontWeightNotifier provider
          create: (_) => FontWeightNotifier(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

Future<double> loadFontSize() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('fontSize') ?? 16.0; // Default value if not set
}

class MyApp extends StatelessWidget {
  ThemeData _buildThemeData(double fontSize) {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        bodyText1: TextStyle(fontSize: fontSize),
        bodyText2: TextStyle(fontSize: fontSize),
        // Add other text styles as needed
        button: TextStyle(fontSize: fontSize), // Apply to buttons
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeNotifier>(
      builder: (context, fontSizeNotifier, child) {
        return MaterialApp(
          initialRoute: '/',
          theme: _buildThemeData(fontSizeNotifier.fontSize),
          routes: {
            '/': (context) => LandingScreen(),
            // Define other routes as needed
          },
        );
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
