import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parkirta/bloc/auth_bloc.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/ui/arrive_page.dart';
import 'package:parkirta/ui/auth/login_page.dart';
import 'package:parkirta/ui/auth/pre_login_page.dart';
import 'package:parkirta/ui/auth/register_page.dart';
import 'package:parkirta/ui/auth/splash_page.dart';
import 'package:parkirta/ui/home_page.dart';
import 'package:parkirta/ui/main_page.dart';
import 'package:parkirta/ui/payment/payment_page.dart';
import 'package:parkirta/ui/payment/payment_success_page.dart';
import 'package:parkirta/utils/contsant/authentication.dart';
import 'package:sp_util/sp_util.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  Bloc.observer = AppBlocObserver();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: 'AIzaSyCRlojuTRtBCNauwVM9a7nWvoeFpt_yUkA',
    appId: '1:498872125018:android:3dec57b31c03211a363a63',
    messagingSenderId: '498872125018',
    projectId: 'parkirta',
  ));
  await setupFlutterNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(App());
}

/// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) debugPrint(change.toString());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(transition.toString());
  }
}

class App extends StatelessWidget {
  /// {@macro app}
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => AuthenticationBloc(),
        child: const AppView()
    );
  }
}

class AppView extends StatelessWidget {

  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Parkirta',
        theme: ThemeData(
          fontFamily: 'Inter',
          primaryColor: Red50,
        ),
        initialRoute: "/",
        routes: {
          '/': (context) => AppRoute(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/pre_login': (context) => const PreLoginPage(),
          '/home': (context) => HomePage(),
          '/arrive': (context) => ArrivePage(),
          '/payment': (context) => PaymentPage(),
          '/payment_success': (context) => PaymentSuccessPage(),
        }
    );
  }
}

class AppRoute extends StatelessWidget {
  const AppRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, Authentication>(
          builder: (context, state) {
            debugPrint("state change $state");
            switch (state) {
              case Authentication.Authenticated:
                return MainPage();
              case Authentication.Unauthenticated:
                return LoginPage();
              default:
                return const SplashPage();
            }
          },
    );

  }
}


// ---------- Firebase & Push Notify Configuration
late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(options: Platform.isAndroid ? const FirebaseOptions(
  //   apiKey: 'AIzaSyC3R_H1r6CHMkJC_re5-62Fn9wmtSULBKQ',
  //   appId: '1:504569686711:android:2a7a345f5ba2bc2255fb32',
  //   messagingSenderId: '504569686711',
  //   projectId: 'smart-dmi',
  // ): const FirebaseOptions(
  //   apiKey: 'AIzaSyC3R_H1r6CHMkJC_re5-62Fn9wmtSULBKQ',
  //   appId: '1:504569686711:android:2a7a345f5ba2bc2255fb32',
  //   messagingSenderId: '504569686711',
  //   projectId: 'smart-dmi',
  //   androidClientId: '504569686711-nlpk1c0435om21kgg21sb5glel2747kd.apps.googleusercontent.com',
  //   iosClientId: '504569686711-nlpk1c0435om21kgg21sb5glel2747kd.apps.googleusercontent.com',
  //   iosBundleId: 'io.flutter.plugins.firebase.messaging',
  // ));
  // await setupFlutterNotifications();
  // showFlutterNotification(message);


  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  if(Platform.isIOS){
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  print("notification masuk ${message.notification?.title} ${message.notification?.body}");
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/logo',
          ),
          iOS: const IOSNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true)
      ),
    );
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;