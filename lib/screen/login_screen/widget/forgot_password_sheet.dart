import 'package:doctor_flutter/common/custom_round_btn.dart';
import 'package:doctor_flutter/common/text_button_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/login_screen/login_screen.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';

class ForgotPasswordSheet extends StatelessWidget {
  final VoidCallback onPressed;
  final TextEditingController forgotController;

  const ForgotPasswordSheet({super.key, required this.onPressed, required this.forgotController});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: ColorRes.havelockBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).forgotPassword,
                    style: const TextStyle(fontSize: 24, fontFamily: FontRes.medium, color: ColorRes.white),
                  ),
                  const CustomRoundBtn()
                ],
              ),
              const SizedBox(height: 20),
              buildLabel(S.current.emailAddress),
              const SizedBox(height: 6),
              BuildInputField(controller: forgotController),
              const SizedBox(height: 30),
              TextButtonCustom(onPressed: onPressed, title: S.of(context).send, titleColor: ColorRes.havelockBlue, backgroundColor: ColorRes.white),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
