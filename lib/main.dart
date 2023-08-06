
import 'package:background/presentation/control.dart';
import 'package:background/shared/network/local_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'counter_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqlDb().initialDb();
  await initializeService();
  await Geolocator.requestPermission();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async{
      if(notificationResponse.payload!="test") {
        await launchUrl(Uri.parse(notificationResponse.payload!),mode: LaunchMode.externalApplication);
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  runApp(const MyApp());
}
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async{
  // ignore: avoid_print
  if(notificationResponse.payload!="test") {
    await launchUrl(Uri.parse(notificationResponse.payload!),mode: LaunchMode.externalApplication);
  }
}
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> initializeService() async {

  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE',
    // importance: Importance.low, // importance must be at low or higher level
    importance: Importance.low,
  );
  const AndroidNotificationChannel channel2 = AndroidNotificationChannel(
    'notification', // id
    'MY notification',
    // importance: Importance.low, // importance must be at low or higher level
    importance: Importance.max,
  );

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel2);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}
// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final controller = Get.put(Controller());

  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      await controller.getLocations();
      await controller.getNotification();
      await flutterLocalNotificationsPlugin.show(
        888,
        'Location',
        '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'my_foreground',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            priority: Priority.min,
            importance: Importance.min,
            ongoing: true,
          ),
        ),
      );
      await controller.sm();
    } catch (e) {
      print(e);
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
        home: CounterPage());
  }
}
