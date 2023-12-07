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
  print("Handling a background message: ${message.messageId}");
}

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
  var androidDetails = AndroidNotificationDetails(channelId, channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false);
  var platformDetails = NotificationDetails(android: androidDetails);

  // Use current timestamp as unique ID for each notification
  int notificationId = DateTime.now().millisecondsSinceEpoch;

  flutterLocalNotificationsPlugin.show(
      notificationId, notification?.title, notification?.body, platformDetails);
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
            '/communication': (context) =>
                CommunicationScreen(), // Ensure this route is defined
            // ... other routes ...
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
