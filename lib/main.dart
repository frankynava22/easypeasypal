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
import 'screens/communication.dart';
import 'screens/chat_history.dart'; // Import ChatHistoryScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

const String channelId = 'chat_messages_channel';
const String channelName = 'Chat Messages';
const String channelDescription = 'Notifications for new chat messages';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showNotification(message.notification);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
    if (message != null &&
        message.data.containsKey('senderId') &&
        message.data.containsKey('recipientId')) {
      _navigateToChatHistoryScreen(message.data);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message.notification);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data.containsKey('senderId') &&
        message.data.containsKey('recipientId')) {
      _navigateToChatHistoryScreen(message.data);
    }
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

void _navigateToChatHistoryScreen(Map<String, dynamic> data) {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String chatPartnerId = _auth.currentUser!.uid == data['senderId']
      ? data['recipientId']
      : data['senderId'];

  MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
    builder: (context) => ChatHistoryScreen(
      contact: {'uid': chatPartnerId}, // Add other necessary details as needed
    ),
  ));
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
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    playSound: true,
    visibility: NotificationVisibility.public,
  );
  var platformDetails = NotificationDetails(android: androidDetails);
  flutterLocalNotificationsPlugin.show(
      0, notification?.title, notification?.body, platformDetails);
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          theme: themeNotifier.getTheme(),
          routes: {
            '/': (context) => SplashScreen(),
            '/landing': (context) => LandingScreen(),
            '/communication': (context) => CommunicationScreen(),
            '/chat_history': (context) => ChatHistoryScreen(contact: {}),
          },
        );
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
    _initializeApp().then((_) {
      Navigator.of(context).pushReplacement(_createRoute());
    });
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration(seconds: 2));
  }

  PageRouteBuilder _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LandingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
      backgroundColor: const Color.fromARGB(255, 30, 71, 104),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'EasyPeasyPal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
