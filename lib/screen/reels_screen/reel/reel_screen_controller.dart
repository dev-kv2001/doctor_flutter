import 'dart:async';

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/model/message/api_status.dart';
import 'package:doctor_flutter/model/reel/add_comment.dart';
import 'package:doctor_flutter/model/reel/fetch_comment.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/widget/comment_sheet.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ReelScreenController extends GetxController {
  Rx<Reel> reel;
  RxBool isSaved = false.obs;
  PrefService prefService = PrefService();
  Timer? _debounce;
  RxList<Comment> comments = <Comment>[].obs;
  RxBool isCommentLoading = false.obs;
  bool hasNoMoreComment = false;
  RxBool isPause = false.obs;

  ReelScreenController(this.reel) {
    isPause.value = false;
  }

  @override
  void onReady() async {
    super.onReady();
    isSaved.value = (await reel.value.isSaved());
  }

  void onLikeTap() {
    // Toggle the like state and update count
    reel.update((reel) {
      if (reel != null) {
        final isCurrentlyLiked = reel.isLiked ?? false;
        reel.isLiked = !isCurrentlyLiked;
        reel.likesCount = (isCurrentlyLiked ? (reel.likesCount ?? 0).clamp(1, double.infinity).toInt() - 1 : (reel.likesCount ?? 0) + 1);
      }
    });

    // Debounced API update
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      // If already liked or disliked, match it with the initial like status, return if it matches
      ApiService.instance.call(
        url: Urls.likeReelDoctorApp,
        param: {pReelId: reel.value.id, pDoctorId: reel.value.doctorId},
        completion: (response) {
          final data = ApiStatus.fromJson(response);
          if (data.status == false) {
            // Revert state if the API call fails
            reel.update((reel) {
              if (reel != null) {
                final isCurrentlyLiked = reel.isLiked ?? false;
                reel.isLiked = !isCurrentlyLiked;
                reel.likesCount = isCurrentlyLiked ? (reel.likesCount ?? 0).clamp(1, double.infinity).toInt() - 1 : (reel.likesCount ?? 0) + 1;
              }
            });
          }
        },
      );
    });
  }

  void onCommentTap() {
    fetchComment();
    Get.bottomSheet(Obx(() => CommentSheet(reelData: reel.value)), isScrollControlled: true);
  }

  onSendComment(String comment) {
    CustomUi.loader();
    ApiService.instance.call(
        url: Urls.addCommentOnReelDoctorApp,
        param: {
          pDoctorId: reel.value.doctorId,
          pReelId: reel.value.id,
          pComment: comment,
        },
        completion: (response) {
          Get.back();
          AddComment data = AddComment.fromJson(response);
          if (data.status == true) {
            if (data.data != null) {
              comments.insert(0, data.data!);
              reel.update(
                (val) {
                  if (val != null) {
                    val.increaseCommentCount(1);
                  }
                },
              );
            }
          }
        });
  }

  void onBookmarkTap() async {
    try {
      if (isSaved.value) {
        isSaved.value = false;
      } else {
        isSaved.value = true;
      }

      // Debounced API update
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 1000), () async {
        await prefService.init();

        // Parse saved reels from preferences
        final savedList = <String>{
          if (prefService.getRegistrationData()?.savedReels?.isNotEmpty ?? false)
            ...prefService.getRegistrationData()!.savedReels!.split(',').where((e) => e.isNotEmpty)
        };

        debugPrint('Current saved list: $savedList');

        // Update the reel's saved status
        reel.update((val) async {
          if (val == null || val.id == null) return;

          final reelId = '${val.id}';

          // Update saved list based on the isSaved state
          if (isSaved.value) {
            debugPrint('Adding $reelId to saved list');
            savedList.add(reelId);
          } else {
            debugPrint('Removing $reelId from saved list');
            savedList.remove(reelId);
          }

          debugPrint('Sending updated saved list to API');

          // Make a single API call after updating the list
          await ApiService().updateDoctorDetails(savedReels: savedList.join(','));
          debugPrint('Updated saved list sent to API: ${savedList.join(',')}');
        });
      });
    } catch (e) {
      debugPrint('Error in onBookmarkTap: $e');
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void fetchComment() {
    if (hasNoMoreComment) return;
    isCommentLoading.value = true;
    ApiService.instance.call(
        url: Urls.fetchReelComments,
        param: {pReelId: reel.value.id, pStart: comments.length, pCount: paginationLimit},
        completion: (response) {
          FetchComment data = FetchComment.fromJson(response);
          if (data.status == true) {
            comments.addAll(data.data ?? []);
          }
          if ((data.data?.length ?? 0) < paginationLimit) {
            hasNoMoreComment = true;
          }
          reel.update((val) {
            if (val != null) {
              val.commentsCount = comments.length;
            }
          });
          isCommentLoading.value = false;
        });
  }

  void onLongPress(VideoPlayerController? videoPlayerController) {
    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController.pause();
      isPause.value = true;
    } else {
      videoPlayerController.play();
      isPause.value = false;
    }
  }

  void onLongPressEnd(VideoPlayerController? videoPlayerController) {}
}
