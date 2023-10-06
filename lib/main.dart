// import 'package:chat_app/pages/chat.dart';
import 'package:chat_app/pages/navigation.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/instances/UserStateInstance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/chatterScreen.dart';
import 'package:provider/provider.dart';
import 'pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/pages/splash.dart';
import 'package:chat_app/pages/settings.dart';
import 'package:chat_app/pages/profile.dart';
import 'package:chat_app/widgets/Company.dart';
import 'package:chat_app/widgets/dynamicLink.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 用於傳遞context
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
  enableVibration: true,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  loadFCM();
  listenFCM();

  await FirebaseMessaging.instance.getToken().then((token) {
    print(token);
  });

  // 監聽邀請連結
  DynamicLinkService().fetchLinkData(navigatorKey);

  // 存取主題設定
  AdaptiveThemeMode savedThemeMode = await AdaptiveTheme.getThemeMode();
  print('savedThemeMode: $savedThemeMode');

  runApp(
    ChangeNotifierProvider<UserState>(
      create: (_) => UserState(savedThemeMode),
      child: ChatterApp(savedThemeMode),
    ),
  );
}

void loadFCM() async {
  if (!kIsWeb) {
    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

void listenFCM() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
  });
}

class ChatterApp extends StatelessWidget {
  final AdaptiveThemeMode savedThemeMode;
  ChatterApp(this.savedThemeMode);
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Chatter',
              navigatorKey: navigatorKey,
              theme: theme,
              // home: ChatterHome(),
              initialRoute: '/',
              routes: {
                '/': (context) => ChatterSplash(),
                '/login': (context) => ChatterLogin(),
                '/chat': (context) => ChatterScreen(),
                '/navigation': (context) => ChatterNavigation(),
                '/settings': (context) => ChatterSettings(),
                '/profile': (context) => ChatterProfile(),
              },
            ));
  }
}
