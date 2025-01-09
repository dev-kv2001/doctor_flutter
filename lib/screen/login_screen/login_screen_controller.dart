import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_one/doctor_profile_screen_one.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_three/doctor_profile_screen_three.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_two/doctor_profile_screen_two.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/select_category_screen/select_category_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/starting_profile_screen.dart';
import 'package:doctor_flutter/screen/login_screen/widget/forgot_password_sheet.dart';
import 'package:doctor_flutter/screen/registration_screen/registration_screen.dart';
import 'package:doctor_flutter/screen/registration_successful_screen.dart/registration_successful_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/firebase_notification_manager.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreenController extends GetxController {
  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  TextEditingController forgotController = TextEditingController();
  bool emailError = false;
  bool passwordError = false;
  String deviceToken = '';
  PrefService prefService = PrefService();

  @override
  void onInit() {
    getPref();
    super.onInit();
  }

  void onLoginClick() async {
    if (emailController.text.trim().isEmpty) {
      return viewSnackBar(S.current.pleaseEnterMail);
    }
    if (passwordController.text.trim().isEmpty) {
      viewSnackBar(S.current.pleaseEnterPassword);
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      viewSnackBar(S.current.pleaseEnterValidEmail);
    }

    UserCredential? user = await signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim());

    if (user == null) return;

    FirebaseNotificationManager.shared.getNotificationToken(
      (token) async {
        deviceToken = token;
        CustomUi.loader();
        if (user.user?.emailVerified == true) {
          ApiService.instance
              .doctorRegistration(
                  identity: emailController.text.trim(),
                  deviceToken: deviceToken,
                  name: emailController.text.split('@')[0],
                  isLogin: 1)
              .then((value) async {
            Get.back();
            if (value.status == true) {
              PrefService.id = value.data?.id ?? -1;
              await prefService.setLogin(key: kLogin, value: true);
              await prefService.saveString(
                  key: kPassword, value: passwordController.text);
              if (value.data?.status == 0) {
                navigatePage(value.data!);
              } else {
                Get.offAll(() => const DashboardScreen());
              }
            } else {
              CustomUi.snackBar(
                  message: value.message.toString(),
                  textColor: ColorRes.havelockBlue,
                  bgColor: ColorRes.white);
            }
          });
        } else {
          Get.back();
          CustomUi.snackBar(
              message: S.current.pleaseVerifiedYourEmail,
              textColor: ColorRes.havelockBlue,
              bgColor: ColorRes.white);
          return;
        }
      },
    );
  }

  ///-------------- SIGN IN METHOD --------------///
  Future<UserCredential?> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.back();
      if (e.code == 'user-not-found') {
        viewSnackBar(S.current.noUserFoundForThisEmail);
      } else if (e.code == 'wrong-password') {
        viewSnackBar(S.current.wrongPasswordYouEnter);
      } else {
        viewSnackBar(S.current.somethingWentWrong);
      }
    } catch (e) {
      Get.back();
      viewSnackBar(S.current.somethingWentWrong);
    }
    return null;
  }

  void getPref() async {
    await prefService.init();
  }

  void navigatePage(DoctorData data) {
    if (data.mobileNumber == null || data.gender == null) {
      Get.offAll(() => StartingProfileScreen(doctorData: data));
    } else if (data.categoryId == null) {
      Get.offAll(() => const SelectCategoryScreen(screenType: 0));
    } else if ([
      data.image,
      data.designation,
      data.degrees,
      data.experienceYear,
      data.consultationFee
    ].any((element) => element == null)) {
      Get.offAll(() => const DoctorProfileScreenOne());
    } else if (data.aboutYouself == null || data.educationalJourney == null) {
      Get.offAll(() => const DoctorProfileScreenTwo());
    } else if (data.onlineConsultation == 0 && data.clinicConsultation == 0) {
      Get.offAll(() => const DoctorProfileScreenThree());
    } else {
      Get.offAll(() => const RegistrationSuccessfulScreen());
    }
  }

  void onForgotPasswordClick() {
    Get.bottomSheet(
      ForgotPasswordSheet(
        onPressed: () async {
          String email = forgotController.text.trim();
          if (email.isEmpty) {
            viewSnackBar(S.current.pleaseEnterMail);
            return;
          }
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
            Get.back();
            forgotController.clear();
            viewSnackBar(S.current.emailSentSuccessfullySentYourMail);
          } on FirebaseAuthException catch (e) {
            viewSnackBar(e.message);
          }
        },
        forgotController: forgotController,
      ),
    );
  }

  void onRegistrationTap() {
    Get.to(() => const RegistrationScreen());
  }

  void viewSnackBar(String? title) {
    CustomUi.snackBar(
        message: title,
        textColor: ColorRes.havelockBlue,
        bgColor: ColorRes.white);
  }
}
