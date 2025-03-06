import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/reel_screen.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen_controller.dart';
import 'package:doctor_flutter/screen/reels_screen/widget/reels_top_bar.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum ProfileType { dashboard, profile }

class ReelsScreen extends StatelessWidget {
  final List<Reel> reels;
  final int initialIndex;
  final ProfileType profileType;
  final List<DoctorCategoryData>? categoryData;

  const ReelsScreen({
    super.key,
    required this.reels,
    required this.initialIndex,
    required this.profileType,
    this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ReelsScreenController(reels, initialIndex, categoryData ?? [], profileType);
    return GetBuilder(
        init: controller,
        tag: '${DateTime.now().millisecondsSinceEpoch}',
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorRes.black,
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Obx(
                  () => controller.reels.isEmpty
                      ? Center(child: CustomUi.noDataImage(message: S.of(context).noReels))
                      : RefreshIndicator(
                          onRefresh: controller.onRefresh,
                          color: ColorRes.whiteSmoke,
                          backgroundColor: ColorRes.transparent,
                          notificationPredicate: profileType == ProfileType.dashboard ? (_) => true : (_) => false,
                          child: PageView.builder(
                            controller: controller.pageController,
                            scrollDirection: Axis.vertical,
                            itemCount: controller.reels.length,
                            onPageChanged: controller.onPageChanged,
                            itemBuilder: (context, index) {
                              return Obx(() {
                                final videoController = controller.controllers[index];
                                videoController?.setLooping(true);
                                return ClipRRect(
                                  child: VisibilityDetector(
                                    key: const Key('reels'),
                                    onVisibilityChanged: controller.onVisibilityChanged,
                                    child: ReelScreen(reelData: controller.reels[index], videoPlayerController: videoController),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                ),
                Obx(
                  () => ReelsTopBar(
                      profileType: profileType,
                      reelData: controller.reels.isNotEmpty ? controller.reels[controller.currentIndex.value] : null,
                      controller: controller,
                      isDataNotShow: controller.reels.isEmpty),
                ),
                // Dropdown Content
              ],
            ),
          );
        });
  }
}
