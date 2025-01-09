import 'package:doctor_flutter/common/text_button_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/login_screen/login_screen_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginScreenController();
    return Scaffold(
      backgroundColor: ColorRes.havelockBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppBar().preferredSize.height * 2),
                const Text(
                  appName,
                  style: TextStyle(
                      fontFamily: FontRes.black,
                      fontSize: 25,
                      color: ColorRes.white),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(color: ColorRes.white),
                  child: const Text(
                    subAppName,
                    style: TextStyle(
                        fontFamily: FontRes.semiBold,
                        fontSize: 16,
                        color: ColorRes.havelockBlue),
                  ),
                ),
                Text(
                  S.of(context).signInToContinue,
                  style: const TextStyle(
                      fontFamily: FontRes.productSansMedium,
                      color: ColorRes.white,
                      fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  S
                      .of(context)
                      .manageYourAppointmentsWithPrecisionTransformingTheWayYouConnect,
                  style: const TextStyle(
                      fontFamily: FontRes.light,
                      color: ColorRes.white,
                      fontSize: 16),
                ),
                const SizedBox(height: 10),
                GetBuilder(
                  init: controller,
                  tag: '${DateTime.now().millisecondsSinceEpoch}',
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        buildLabel(S.of(context).emailAddress),
                        const SizedBox(height: 6),
                        BuildInputField(controller: controller.emailController),
                        const SizedBox(height: 20),
                        buildLabel(S.current.password),
                        const SizedBox(height: 6),
                        BuildInputField(
                          controller: controller.passwordController,
                          isHideVisible: true,
                        ),
                        const SizedBox(height: 25),
                        TextButtonCustom(
                          onPressed: controller.onLoginClick,
                          title: S.of(context).login,
                          titleColor: ColorRes.havelockBlue,
                          backgroundColor: ColorRes.white,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: Center(
                            child: InkWell(
                              onTap: controller.onRegistrationTap,
                              child: Text(S.of(context).newUserRegisterHere,
                                  style: _regularTextStyle()),
                            ),
                          ),
                        ),
                        Center(
                          child: InkWell(
                            onTap: controller.onForgotPasswordClick,
                            child: Text(
                              '${S.current.forgotPassword}?',
                              style: _regularTextStyle(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: AppBar().preferredSize.height / 3)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: ColorRes.white,
      fontSize: 16,
      fontFamily: FontRes.productSansLight,
    ),
  );
}

class BuildInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool isHideVisible;

  const BuildInputField(
      {super.key, required this.controller, this.isHideVisible = false});

  @override
  State<BuildInputField> createState() => _BuildInputFieldState();
}

class _BuildInputFieldState extends State<BuildInputField> {
  bool obSecureText = false;

  void onPassWordVisible() {
    obSecureText = !obSecureText;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorRes.white.withOpacity(.25)),
          color: ColorRes.white.withOpacity(.1)),
      width: double.infinity,
      child: TextField(
        controller: widget.controller,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            hintText: '${S.current.writeHere} ...',
            hintStyle: const TextStyle(
                color: ColorRes.white,
                fontFamily: FontRes.productSansLight,
                fontSize: 13),
            suffixIconConstraints:
                widget.isHideVisible ? const BoxConstraints() : null,
            suffixIcon: widget.isHideVisible
                ? InkWell(
                    onTap: onPassWordVisible,
                    child: Image.asset(
                        obSecureText ? AssetRes.ciNotHide : AssetRes.ciHide,
                        width: 35,
                        height: 20,
                        color: ColorRes.white),
                  )
                : null),
        obscureText: obSecureText,
        style: const TextStyle(
            fontFamily: FontRes.productSansLight, color: ColorRes.white),
        cursorColor: ColorRes.white,
      ),
    );
  }
}

TextStyle _regularTextStyle() {
  return const TextStyle(
      fontFamily: FontRes.productSansRegular,
      color: ColorRes.white,
      fontSize: 16);
}
