import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/reel_screen_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class ReelScreen extends StatelessWidget {
  final Reel reelData;
  final VideoPlayerController? videoPlayerController;

  const ReelScreen(
      {super.key, required this.reelData, required this.videoPlayerController});

  @override
  Widget build(BuildContext context) {
    final isControllerInitialized =
        videoPlayerController?.value.isInitialized ?? false;

    final controller =
        Get.put(ReelScreenController(reelData.obs), tag: '${reelData.id}');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Video Display
        isControllerInitialized
            ? Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => controller.onLongPress(videoPlayerController),
                  child: SizedBox.expand(
                      child: FittedBox(
                    fit: (videoPlayerController?.value.size.width ?? 0) <
                            (videoPlayerController?.value.size.height ?? 0)
                        ? BoxFit.cover
                        : BoxFit.fitWidth,
                    child: SizedBox(
                        width: videoPlayerController?.value.size.width,
                        height: videoPlayerController?.value.size.height,
                        child: VideoPlayer(videoPlayerController!)),
                  )),
                ))
            : ImageBuilderCustom(
                reelData.thumb,
                size: Get.height,
                radius: 0,
                name: reelData.doctor?.name,
                bgColor: ColorRes.whiteSmoke,
              ),
        // Overlay UI
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
                onTap: () => controller.onLongPress(videoPlayerController),
                child: Image.asset(AssetRes.icBlackShadow_1,
                    width: double.infinity, fit: BoxFit.fitWidth)),
            UserInformation(reelData: controller.reel.value),
            SideBarList(reelData: reelData),
          ],
        ),
      ],
    );
  }
}

class UserInformation extends StatelessWidget {
  final Reel reelData;

  const UserInformation({super.key, required this.reelData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserInfoHeader(reel: reelData),
            UserDescription(reel: reelData),
            UserStats(reel: reelData),
          ],
        ),
      ),
    );
  }
}

class UserInfoHeader extends StatelessWidget {
  final Reel reel;

  const UserInfoHeader({required this.reel, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                '${ConstRes.itemBaseURL}${reel.doctor?.image}',
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CustomUi.doctorPlaceHolder(
                      height: 45, male: reel.doctor?.gender ?? 1);
                },
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reel.doctor?.name ?? '',
                      style: const TextStyle(
                          color: ColorRes.white,
                          fontFamily: FontRes.extraBold,
                          fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(reel.doctor?.designation ?? '',
                      style: const TextStyle(
                          color: ColorRes.white,
                          fontFamily: FontRes.light,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class UserDescription extends StatelessWidget {
  final Reel reel;

  const UserDescription({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return (reel.description ?? '').isNotEmpty
        ? Column(
            children: [
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: 150, maxWidth: Get.width - 70),
                child: SingleChildScrollView(
                  child: DetectableText(
                      text: reel.description ?? '',
                      detectionRegExp: RegExp(r"\B#\w\w+"),
                      basicStyle: TextStyle(
                          color: ColorRes.white.withOpacity(.8), fontSize: 14),
                      trimMode: TrimMode.Line,
                      trimLines: 3,
                      trimCollapsedText: ' more',
                      trimExpandedText: '   less',
                      moreStyle: TextStyle(
                          color: ColorRes.white.withOpacity(.8),
                          fontSize: 14,
                          fontFamily: FontRes.semiBold),
                      lessStyle: TextStyle(
                          color: ColorRes.white.withOpacity(.8),
                          fontSize: 14,
                          fontFamily: FontRes.semiBold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          )
        : const SizedBox();
  }
}

class UserStats extends StatelessWidget {
  final Reel reel;

  const UserStats({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReelScreenController>(tag: '${reel.id}');
    return Row(
      children: [
        Text(
          DateFormat('dd MMM yyyy')
              .format(DateTime.parse(reel.createdAt ?? '')),
          style: const TextStyle(
              color: ColorRes.white, fontSize: 12, fontFamily: FontRes.light),
        ),
        if ((reel.views ?? 0) > 0)
          Container(
            height: 10,
            width: .5,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: const BoxDecoration(color: ColorRes.white),
          ),
        Obx(
          () => (controller.reel.value.views ?? 0) > 0
              ? Text(
                  '${(controller.reel.value.views ?? 0).formatCurrency} ${S.of(context).views}',
                  style: const TextStyle(
                      color: ColorRes.white,
                      fontSize: 12,
                      fontFamily: FontRes.light),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}

class SideBarList extends StatelessWidget {
  final Reel reelData;

  const SideBarList({
    super.key,
    required this.reelData,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReelScreenController>(tag: '${reelData.id}');
    return Positioned(
      right: 0,
      bottom: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 7.5),
            Obx(() {
              return IconWithLabel(
                onTap: () {
                  if (reelData.id == null) return;
                  controller.onLikeTap();
                },
                image: controller.reel.value.isLiked ?? false
                    ? AssetRes.icFillHeart
                    : AssetRes.icHeart,
                text: (controller.reel.value.likesCount ?? 0).formatCurrency,
              );
            }),
            Obx(
              () => IconWithLabel(
                onTap: () {
                  if (reelData.id == null) return;
                  controller.onCommentTap();
                },
                image: AssetRes.icComment,
                text: (controller.reel.value.commentsCount ?? 0).formatCurrency,
              ),
            ),
            Obx(
              () => IconWithLabel(
                onTap: () {
                  if (reelData.id == null) return;
                  controller.onBookmarkTap();
                },
                image: controller.isSaved.value
                    ? AssetRes.icFillBookmark
                    : AssetRes.icBookmark,
                text: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconWithLabel extends StatelessWidget {
  final VoidCallback onTap;
  final String image;
  final String text;

  const IconWithLabel({
    super.key,
    required this.onTap,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: Column(
        children: [
          InkWell(
              onTap: onTap, child: Image.asset(image, width: 34, height: 34)),
          if (text.isNotEmpty)
            Text(
              text,
              style: const TextStyle(
                fontFamily: FontRes.medium,
                fontSize: 13,
                color: ColorRes.white,
                shadows: <Shadow>[
                  Shadow(
                      offset: Offset(0.0, 1.0),
                      blurRadius: 3.0,
                      color: ColorRes.smokeyGrey)
                ],
              ),
            ),
        ],
      ),
    );
  }
}
