import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_one/doctor_profile_screen_one.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_three/doctor_profile_screen_three.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_two/doctor_profile_screen_two.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/select_category_screen/select_category_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/starting_profile_screen.dart';
import 'package:doctor_flutter/screen/registration_successful_screen.dart/registration_successful_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/firebase_notification_manager.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationScreenController extends GetxController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reTypePasswordController = TextEditingController();

  bool fullNameError = false;
  bool emailError = false;
  bool passwordError = false;
  bool reTypePasswordError = false;
  bool isPasswordVisible = true;
  bool isReTypePasswordVisible = true;

  String deviceToken = '';

  DoctorData? doctorData;
  UserCredential? userCredential;

  PrefService prefService = PrefService();

  @override
  void onInit() {
    initPrefService();
    super.onInit();
  }

  void onRegisterClick() async {
    fullNameError = false;
    emailError = false;
    passwordError = false;
    reTypePasswordError = false;
    if (fullNameController.text.trim().isEmpty) {
      fullNameError = true;
    }
    if (emailController.text.trim().isEmpty) {
      emailError = true;
    }

    if (passwordController.text.trim().isEmpty) {
      passwordError = true;
    }
    if (reTypePasswordController.text.trim().isEmpty) {
      reTypePasswordError = true;
    }
    update();
    if (fullNameError || emailError || passwordError || reTypePasswordError) {
      return;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomUi.snackBar(message: S.current.pleaseEnterValidEmail);
      return;
    }
    if (passwordController.text.trim() != reTypePasswordController.text.trim()) {
      CustomUi.snackBar(message: S.current.passwordDosentMatchEnterSamePassword);
      return;
    }

    createUserWithEmailAndPassword();
  }

  Future<void> createUserWithEmailAndPassword() async {
    CustomUi.loader();
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());

      if (credential.user == null) return;
      FirebaseNotificationManager.shared.getNotificationToken(
        (token) async {
          deviceToken = token;
          Registration registration = await ApiService.instance
              .doctorRegistration(identity: emailController.text.trim(), name: fullNameController.text.trim(), deviceToken: deviceToken, isLogin: 0);
          await credential.user?.sendEmailVerification();
          doctorData = registration.data;
          Get.back();
          if (registration.status == true) {
            Get.back();
            return CustomUi.snackBar(message: S.current.verifyTheLinkSentToYourEmailThenCompleteThe);
          } else {
            return CustomUi.snackBar(message: registration.message);
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      Get.back();
      if (e.code == 'weak-password') {
        CustomUi.snackBar(message: S.current.thePasswordProvidedIsTooWeak);
      } else if (e.code == 'email-already-in-use') {
        CustomUi.snackBar(message: theEmailIsAlreadyInUseInThePatientApp);
      } else {
        CustomUi.snackBar(message: S.current.somethingWentWrong);
      }
    } catch (e) {
      Get.back();
      CustomUi.snackBar(message: S.current.somethingWentWrong);
    }
  }

  void initPrefService() async {
    await prefService.init();
  }

  void navigatePage(DoctorData? data) {
    if (data?.mobileNumber == null || data?.gender == null) {
      Get.offAll(() => StartingProfileScreen(doctorData: data));
    } else if (data?.categoryId == null) {
      Get.offAll(() => const SelectCategoryScreen(screenType: 0));
    } else if (data?.image == null ||
        data?.designation == null ||
        data?.degrees == null ||
        data?.experienceYear == null ||
        data?.consultationFee == null) {
      Get.offAll(() => const DoctorProfileScreenOne());
    } else if (data?.aboutYouself == null || data?.educationalJourney == null) {
      Get.offAll(() => const DoctorProfileScreenTwo());
    } else if (data?.onlineConsultation == 0 && data?.clinicConsultation == 0) {
      Get.offAll(() => const DoctorProfileScreenThree());
    } else {
      Get.offAll(() => const RegistrationSuccessfulScreen());
    }
  }

  void onChangePassword() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  void onChangedReTypePassword() {
    isReTypePasswordVisible = !isReTypePasswordVisible;
    update();
  }
}
