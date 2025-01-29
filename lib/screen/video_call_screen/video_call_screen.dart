import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:doctor_flutter/model/chat/appointment_chat.dart';
import 'package:doctor_flutter/screen/video_call_screen/video_call_screen_controller.dart';
import 'package:doctor_flutter/screen/video_call_screen/widget/bottom_buttom_area.dart';
import 'package:doctor_flutter/screen/video_call_screen/widget/top_bar_name_card.dart';
import 'package:doctor_flutter/screen/video_call_screen/widget/video_call_placeholder.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoCallScreen extends StatefulWidget {
  final AppointmentChat appointmentChat;

  const VideoCallScreen({Key? key, required this.appointmentChat}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  void initState() {
    WakelockPlus.enable();

    super.initState();
  }

  @override
  void dispose() {
    WakelockPlus.disable();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoCallScreenController(widget.appointmentChat));
    return Scaffold(
      backgroundColor: ColorRes.black,
      body: PopScope(
        canPop: false,
        child: GetBuilder(
          init: controller,
          builder: (controller) {
            return Stack(
              children: [
                SizedBox(
                  width: Get.width,
                  height: Get.height,
                  child: controller.remoteUserId != null
                      ? Stack(
                          children: [
                            controller.isRemoteMutedVideo || controller.type == 1

                                /// If remote user mute video and left the meeting ///
                                ? Align(
                                    alignment: Alignment.center,
                                    child: RemotePlaceHolder(
                                        image: widget.appointmentChat.videoCall?.patientImage ?? '',
                                        name: widget.appointmentChat.videoCall?.patientName?[0] ?? '',
                                        widget: const SizedBox()),
                                  )

                                /// If Remote User enter ///
                                : AgoraVideoView(
                                    controller: VideoViewController.remote(
                                      rtcEngine: controller.agoraEngine,
                                      canvas: VideoCanvas(uid: controller.remoteUserId),
                                      connection: RtcConnection(channelId: widget.appointmentChat.videoCall?.channelId),
                                    ),
                                  ),

                            /// Remote user mute video, left meeting, and mute audio ///
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Row(),
                                controller.isRemoteMutedVideo
                                    ? ClipOval(
                                        child: Image.network(
                                          '${ConstRes.itemBaseURL}${widget.appointmentChat.videoCall?.patientImage}',
                                          width: 100,
                                          height: 100,
                                          errorBuilder: (context, error, stackTrace) {
                                            return BlurImageTextCard(
                                              name: widget.appointmentChat.videoCall?.patientName?[0] ?? '',
                                              size: 100,
                                            );
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 10,
                                ),
                                controller.type == 1
                                    ? BlurTextCard(name: '${widget.appointmentChat.videoCall?.patientName ?? ''} Left the meeting')
                                    : !controller.isRemoteMutedAudio
                                        ? const SizedBox()
                                        : BlurTextCard(name: '${widget.appointmentChat.videoCall?.patientName ?? ''} Mute the Audio'),
                              ],
                            )
                          ],
                        )

                      /// If remote user not enter the meeting ///
                      : RemotePlaceHolder(
                          image: widget.appointmentChat.videoCall?.patientImage ?? '',
                          name: widget.appointmentChat.videoCall?.patientName?[0] ?? '',
                          widget: BlurTextCard(name: 'Waiting for ${widget.appointmentChat.videoCall?.patientName ?? ''}')),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      TopBarNameCard(controller: controller),
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 105,
                              height: 138,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: controller.isJoined

                                  /// I am enter the meeting ///
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: controller.isVideo
                                          ? AgoraVideoView(
                                              controller: VideoViewController(
                                                rtcEngine: controller.agoraEngine,
                                                canvas: const VideoCanvas(uid: 0),
                                              ),
                                            )
                                          : LocalPlaceHolder(
                                              image: '${widget.appointmentChat.senderUser?.image}',
                                              name: widget.appointmentChat.senderUser?.name?.replaceAll('Dr.', '').trim()[0] ?? ''),
                                    )

                                  /// I am not enter the meeting ///
                                  : LocalPlaceHolder(
                                      image: '${widget.appointmentChat.senderUser?.image}',
                                      name: widget.appointmentChat.senderUser?.name?.replaceAll('Dr.', '').trim()[0] ?? '',
                                      size: double.infinity,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: 10,
                            child: IconButton(
                              onPressed: () async {
                                try {
                                  controller.switchCamera();
                                } catch (e) {
                                  log("Error switching camera: $e");
                                }
                              },
                              icon: const Icon(
                                Icons.flip_camera_ios,
                                color: ColorRes.fadedOrange,
                                size: 25,
                              ),
                              tooltip: 'Switch Camera',
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      BottomButtonArea(controller: controller)
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class BlurImageTextCard extends StatelessWidget {
  final String name;
  final Color? bg;
  final double? size;

  const BlurImageTextCard({super.key, required this.name, this.bg, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg ?? ColorRes.grey.withOpacity(0.5)),
      alignment: Alignment.center,
      child: Text(
        name,
        style: TextStyle(color: ColorRes.white, fontSize: ((size ?? 35) / 2), fontFamily: FontRes.black),
      ),
    );
  }
}

class BlurTextCard extends StatelessWidget {
  final String name;

  const BlurTextCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(color: ColorRes.grey.withOpacity(0.9)),
        child: Text(name, style: const TextStyle(fontFamily: FontRes.light, color: ColorRes.white, fontSize: 12)),
      ),
    );
  }
}
