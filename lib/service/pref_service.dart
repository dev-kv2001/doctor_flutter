import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/countries/countries.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/global/global_setting.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  SharedPreferences? preferences;
  static int id = -1;

  Future init() async {
    preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  Future<void> saveString({required String key, required String value}) async {
    await preferences?.setString(key, value);
    id = getRegistrationData()?.id ?? -1;
    log('👉 USER ID : $id 👈');
  }

  String? getString({required String key}) {
    return preferences?.getString(key);
  }

  Future<void> setLogin({required String key, required bool value}) async {
    await preferences?.setBool(key, value);
  }

  bool getLogin({required String key}) {
    return preferences?.getBool(key) ?? false;
  }

  DoctorData? getRegistrationData() {
    if (getString(key: kRegistrationUser) == null || getString(key: kRegistrationUser) == 'null') return null;
    DoctorData data = DoctorData.fromJson(jsonDecode(getString(key: kRegistrationUser)!));
    return data;
  }

  GlobalSettingData? getSettingData() {
    if (getString(key: kGlobalSetting) == null) return null;
    return GlobalSettingData.fromJson(jsonDecode(getString(key: kGlobalSetting)!));
  }

  Countries? getCountries() {
    if (getString(key: kCountries) == null) return null;
    return Countries.fromJson(jsonDecode(getString(key: kCountries)!));
  }

  void updateFirebaseProfile() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DoctorData? doctorData = getRegistrationData();
    String doctorIdentity = CommonFun.setDoctorId(doctorId: doctorData?.id);
    db
        .collection(FirebaseRes.userChatList)
        .doc(doctorIdentity)
        .collection(FirebaseRes.userList)
        .withConverter(
          fromFirestore: Conversation.fromFirestore,
          toFirestore: (Conversation value, options) {
            return value.toFirestore();
          },
        )
        .get()
        .then((value) {
      for (var element in value.docs) {
        db
            .collection(FirebaseRes.userChatList)
            .doc(element.id)
            .collection(FirebaseRes.userList)
            .doc(doctorIdentity)
            .withConverter(
              fromFirestore: Conversation.fromFirestore,
              toFirestore: (Conversation value, options) {
                return value.toFirestore();
              },
            )
            .get()
            .then((value) {
          ChatUser? user = value.data()?.user;
          user?.username = doctorData?.name ?? S.current.unKnown;
          user?.image = doctorData?.image;
          user?.designation = doctorData?.designation;
          user?.userid = doctorData?.id;
          db
              .collection(FirebaseRes.userChatList)
              .doc(element.id)
              .collection(FirebaseRes.userList)
              .doc(doctorIdentity)
              .update({FirebaseRes.user: user?.toJson()});
        });
      }
    });
  }
}
