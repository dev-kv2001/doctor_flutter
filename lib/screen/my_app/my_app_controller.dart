import 'dart:developer';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class MyAppController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  PrefService prefService = PrefService();
  String languageCode = Platform.localeName.split('_')[0];

  @override
  void onInit() {
    log('onInit');
    fetchSettingData();
    AppBadgePlus.updateBadge(0);
    super.onInit();
  }

  void fetchSettingData() {
    ApiService.instance.fetchGlobalSettings().then((value) {
      dollar = value.data?.currency == null || value.data!.currency!.isEmpty ? '\$' : (value.data?.currency ?? '\$');
    });
  }
}
