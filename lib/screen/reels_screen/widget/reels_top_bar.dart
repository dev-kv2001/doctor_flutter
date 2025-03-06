import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/widget/report_sheet.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen_controller.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReelsTopBar extends StatelessWidget {
  final ProfileType profileType;
  final Reel? reelData;
  final ReelsScreenController controller;
  final bool isDataNotShow;

  const ReelsTopBar({
    super.key,
    required this.profileType,
    required this.reelData,
    required this.controller,
    required this.isDataNotShow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side Icon or Placeholder
                  _buildLeftIcon(),

                  // Middle Content: Dashboard Categories or Profile Title
                  if (profileType == ProfileType.dashboard)
                    _buildDashboardCategories()
                  else if (profileType == ProfileType.profile)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        S.of(context).reels,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorRes.white,
                          fontFamily: FontRes.medium,
                        ),
                      ),
                    ),

                  // Right Side Report Icon or Placeholder
                  _buildRightIcon(),
                ],
              ),
              SizeTransition(
                sizeFactor: controller.animation,
                axis: Axis.vertical,
                child: Column(
                  children: [
                    Center(
                      child: CustomPaint(
                        painter: TrianglePainter(
                          strokeColor: controller.reels.isEmpty ? ColorRes.charcoalGrey : ColorRes.white,
                          strokeWidth: 0,
                          paintingStyle: PaintingStyle.fill,
                        ),
                        child: const SizedBox(height: 9, width: 15),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: ShapeDecoration(
                        color: controller.reels.isEmpty ? ColorRes.charcoalGrey : ColorRes.white,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
                        ),
                      ),
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: controller.doctorCategories.length,
                        itemBuilder: (context, index) {
                          final category = controller.doctorCategories[index];
                          return Obx(() => _buildCategoryItem(category, index, controller, controller.reels.isEmpty));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Left Icon: Back Button or Placeholder
  Widget _buildLeftIcon() {
    if (profileType == ProfileType.dashboard) {
      return const SizedBox(width: 37, height: 37);
    } else if (profileType == ProfileType.profile) {
      return InkWell(
        onTap: () => Get.back(),
        child: Image.asset(AssetRes.icBackArrow, color: ColorRes.white, height: 37, width: 37),
      );
    }
    return const SizedBox(width: 37, height: 37);
  }

  // Dashboard Categories Dropdown
  Widget _buildDashboardCategories() {
    return InkWell(
      onTap: controller.toggleContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: ColorRes.white.withOpacity(0.5),
          ),
          color: ColorRes.white.withOpacity(0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.selectedCategory.value.id != 0)
              Image.network('${ConstRes.itemBaseURL}${controller.selectedCategory.value.image}',
                  height: 17, width: 17, fit: BoxFit.cover, color: ColorRes.white),
            const SizedBox(width: 5),
            Obx(
              () => Text(
                controller.selectedCategory.value.title ?? '',
                style: const TextStyle(fontSize: 14, fontFamily: FontRes.regular, color: ColorRes.white),
              ),
            ),
            const SizedBox(width: 5),
            Image.asset(AssetRes.icDownArrow, color: ColorRes.white, height: 10, width: 10),
          ],
        ),
      ),
    );
  }

  // Single Category Item
  Widget _buildCategoryItem(DoctorCategoryData category, int index, ReelsScreenController controller, bool isDataNotShow) {
    final isSelected = controller.selectedCategory.value.id == category.id;

    return Column(
      children: [
        InkWell(
          onTap: () => controller.onCategoryChanged(category: category),
          child: Container(
            height: 25,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.title?.capitalize ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontRes.bold,
                        color: isDataNotShow
                            ? (isSelected ? ColorRes.white : ColorRes.lightGrey)
                            : (isSelected ? ColorRes.charcoalGrey : ColorRes.battleshipGrey)),
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: isDataNotShow ? ColorRes.white : ColorRes.charcoalGrey, size: 20),
              ],
            ),
          ),
        ),
        if (index < controller.doctorCategories.length - 1) const Divider(height: 1, color: ColorRes.battleshipGrey),
      ],
    );
  }

  // Right Icon: Report Button or Placeholder
  Widget _buildRightIcon() {
    final shouldShowReport = reelData?.doctorId != PrefService.id && controller.reels.isNotEmpty;

    return shouldShowReport
        ? InkWell(
            onTap: () {
              Get.bottomSheet(ReportSheet(reel: reelData), isScrollControlled: true);
            },
            child: Image.asset(
              AssetRes.icReport,
              width: 37,
              height: 37,
            ),
          )
        : const SizedBox(width: 37, height: 37);
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(x / 2, 0)
      ..lineTo(x, y)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor || oldDelegate.paintingStyle != paintingStyle || oldDelegate.strokeWidth != strokeWidth;
  }
}
