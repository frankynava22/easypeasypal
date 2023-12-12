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
import 'package:animated_text_kit/animated_text_kit.dart';

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

class DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Draw the top half
    paint.color = Color.fromARGB(255, 30, 71, 104);
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Draw the bottom half
    paint.color = Colors.white;
    path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );

    _animationController!.forward();
    Future.delayed(Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(_createRoute());
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  PageRouteBuilder _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LandingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = 0.0;
        var end = 1.0;
        var curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);
        return FadeTransition(opacity: opacityAnimation, child: child);
      },
      transitionDuration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: DiagonalPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: Image.asset('assets/logo.png', width: 275),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 1.0), // Added left padding
                child: SizedBox(
                  width: 250.0,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.bold, // Added font weight
                      color: Color(0xFF1f2e42),
                      fontFamily: 'Sacramento',
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'EasyPeasyPal',
                          speed: Duration(milliseconds: 300),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
