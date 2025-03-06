import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/appointment_screen/appointment_screen.dart';
import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:doctor_flutter/screen/dashboard_screen/widget/custom_animated_bottom_bar.dart';
import 'package:doctor_flutter/screen/notification_screen/notification_screen.dart';
import 'package:doctor_flutter/screen/profile_screen/profile_screen.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen.dart';
import 'package:doctor_flutter/screen/request_screen/request_screen.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardScreenController());

    return GetBuilder(
      init: controller,
      builder: (context) => Scaffold(
        backgroundColor: ColorRes.white,
        bottomNavigationBar: _buildBottomBar(controller),
        body: Obx(
          () => controller.currentIndex.value == 0
              ? const AppointmentScreen()
              : controller.currentIndex.value == 1
                  ? const RequestScreen()
                  : controller.currentIndex.value == 2
                      ? ReelsScreen(
                          reels: controller.reels,
                          initialIndex: 0,
                          profileType: ProfileType.dashboard,
                          categoryData: controller.doctorCategoryData,
                        )
                      : controller.currentIndex.value == 3
                          ? const NotificationScreen()
                          : const ProfileScreen(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(DashboardScreenController controller) {
    return Obx(
      () => CustomAnimatedBottomBar(
        containerHeight: 60,
        selectedIndex: controller.currentIndex.value,
        curve: Curves.easeIn,
        onItemSelected: controller.onItemSelected,
        items: [
          BottomNavyBarItem(image: AssetRes.icCheckList, title: S.current.appointments),
          BottomNavyBarItem(image: AssetRes.listMinus, title: S.current.requests),
          BottomNavyBarItem(image: AssetRes.icReel, title: S.current.medReels),
          BottomNavyBarItem(image: AssetRes.icNotification, title: S.current.notifications),
          BottomNavyBarItem(image: AssetRes.icProfile, title: S.current.profile),
        ],
      ),
    );
  }
}
