import 'package:doctor_flutter/screen/languages_screen/languages_screen_controller.dart';
import 'package:doctor_flutter/screen/my_app/my_app.dart';
import 'package:doctor_flutter/service/firebase_notification_manager.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart';

String? messageId;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('🐦‍🔥🐦‍🔥🐦‍🔥🐦‍🔥 _firebaseMessagingBackgroundHandler ${message.toMap()}');
  FirebaseNotificationManager.shared.showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseNotificationManager.shared;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  initializeTimeZones();
  PrefService prefService = PrefService();
  await prefService.init();
  LanguagesScreenController.selectedLanguage = prefService.getString(key: kLanguageCode) ?? appLanguageCode;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(
      const RestartWidget(child: MyApp()),
    );
  });
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
