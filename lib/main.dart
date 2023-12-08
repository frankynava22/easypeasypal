import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'screens/theme_notifier.dart';
import 'screens/font_size_notifier.dart';
import 'screens/font_weight_notifier.dart';
import 'screens/landing_screen.dart';
import 'screens/identify_user.dart';
import 'screens/communication.dart'; // Add this import for CommunicationScreen
import 'package:shared_preferences/shared_preferences.dart';

const String channelId = 'chat_messages_channel';
const String channelName = 'Chat Messages';
const String channelDescription = 'Notifications for new chat messages';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showNotification(message.notification);
}

import 'screens/theme_notifier.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize local notifications
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  messaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _navigateToCommunicationScreen();
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message.notification);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _navigateToCommunicationScreen();
  });

  double initialFontSize = await loadFontSize();

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
          create: (_) => FontWeightNotifier(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

void _navigateToCommunicationScreen() {
  MyApp()
      .navigatorKey
      .currentState
      ?.push(MaterialPageRoute(builder: (context) => CommunicationScreen()));
}

Future<double> loadFontSize() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('fontSize') ?? 16.0;
}

void showNotification(RemoteNotification? notification) {
  var androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.high, // Set importance to high
    priority: Priority.high, // Set priority to high
    showWhen: true, // Change this to true
    playSound: true, // Enable sound to enhance visibility
    visibility: NotificationVisibility.public, // Ensure visibility is public
    // Optionally, you can add more properties like vibration pattern, light color etc.
  );
  var platformDetails = NotificationDetails(android: androidDetails);
  flutterLocalNotificationsPlugin.show(
      0, notification?.title, notification?.body, platformDetails);
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ThemeData _buildThemeData(double fontSize) {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        bodyText1: TextStyle(fontSize: fontSize),
        bodyText2: TextStyle(fontSize: fontSize),
        button: TextStyle(fontSize: fontSize),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<FontSizeNotifier>(
      builder: (context, fontSizeNotifier, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          theme: _buildThemeData(fontSizeNotifier.fontSize),
          routes: {
            '/': (context) => LandingScreen(),
            '/communication': (context) => CommunicationScreen(),
          },
        );

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      home: SplashScreen(), // Show SplashScreen initially
      theme: themeNotifier.getTheme(),
      routes: {
        '/landing': (context) => LandingScreen(),

      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a time-consuming task (e.g., initializing Firebase, loading data)
    _initializeApp().then((_) {
      // After the task is complete, navigate to the LandingScreen with a fade-out effect
      Navigator.of(context).pushReplacement(_createRoute());
    });
  }

  Future<void> _initializeApp() async {
    // Simulate initializing Firebase or other time-consuming tasks
    await Future.delayed(Duration(seconds: 2));
  }

  PageRouteBuilder _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LandingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: child,
        );
      },
      transitionDuration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),
=======
      backgroundColor:  const Color.fromARGB(255, 30, 71, 104), // Navy blue background

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EasyPeasyPal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                
              ),
            ),
            SizedBox(height: 8),
            Text(

              '$_counter',

              'Welcome',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),

            ),
          ],
        ),
      ),
    );
  }
}
