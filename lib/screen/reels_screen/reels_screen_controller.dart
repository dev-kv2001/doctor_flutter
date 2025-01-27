import 'dart:async';

import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/model/message/api_status.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelsScreenController extends GetxController with GetTickerProviderStateMixin {
  final RxList<Reel> reels = <Reel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxMap<int, VideoPlayerController> controllers = <int, VideoPlayerController>{}.obs;

  bool initialVisible = true;
  Rx<DoctorCategoryData> selectedCategory = (DoctorCategoryData(id: 0, title: 'Mix')).obs;
  List<DoctorCategoryData> doctorCategories = [];
  PageController pageController = PageController();

  late AnimationController _controller;
  late Animation<double> animation;
  ProfileType profileType = ProfileType.dashboard;
  final dashBoardController = Get.find<DashboardScreenController>();

  ReelsScreenController(List<Reel> initialReels, int initialIndex, List<DoctorCategoryData> categories, ProfileType type) {
    reels.addAll(initialReels);
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    doctorCategories = categories;
    profileType = type;
    DashboardScreenController.isPlayController = true;
  }

  @override
  void onInit() {
    super.onInit();
    _controller = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  @override
  void onReady() {
    super.onReady();
    if (reels.isNotEmpty) {
      initVideoPlayer();
    } else {
      fetchDoctorReels(onComplete: (data) {
        initVideoPlayer();
      });
    }
    _loadMoreData();
  }

  void initVideoPlayer() async {
    /// Initialize 1st video
    await _initializeControllerAtIndex(currentIndex.value);

    /// Play 1st video
    _playControllerAtIndex(currentIndex.value);

    /// Initialize 2nd vide
    if (currentIndex.value >= 0) {
      await _initializeControllerAtIndex(currentIndex.value - 1);
    }
    await _initializeControllerAtIndex(currentIndex.value + 1);
  }

  void _playNextReel(int index) {
    _stopControllerAtIndex(index - 1); // Ensure previous reel is stopped
    _disposeControllerAtIndex(index - 2); // Dispose the older controller
    _playControllerAtIndex(index); // Play the new reel
    _initializeControllerAtIndex(index + 1); // Preload the next reel
  }

  void _playPreviousReel(int index) {
    _stopControllerAtIndex(index + 1); // Ensure next reel is stopped
    _disposeControllerAtIndex(index + 2); // Dispose the older controller
    _playControllerAtIndex(index); // Play the previous reel
    _initializeControllerAtIndex(index - 1); // Preload the previous reel
  }

  Future _initializeControllerAtIndex(int index) async {
    if (reels.length > index && index >= 0) {
      /// Create new controller
      final VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(ConstRes.itemBaseURL + (reels[index].video ?? '')));

      /// Add to [controllers] list
      controllers[index] = controller;

      /// Initialize
      await controller.initialize().then((value) {
        update();
      });

      debugPrint('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (DashboardScreenController.isPlayController && reels.length > index && index >= 0) {
      VideoPlayerController? controller = controllers[index];
      if (controller != null && controller.value.isInitialized) {
        controller.play();
        controller.setLooping(true);
        increaseReelViewCount(index);

        debugPrint('🚀🚀🚀 PLAYING $index');
      }
    }
  }

  void _stopControllerAtIndex(int index) {
    if (reels.length > index && index >= 0) {
      final controller = controllers[index];
      if (controller != null) {
        controller.pause();
        controller.seekTo(const Duration()); // Reset position
        debugPrint('🚀🚀🚀 STOPPED $index');
      }
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (reels.length > index && index >= 0) {
      final VideoPlayerController? controller = controllers[index];
      if (controller != null) {
        _stopControllerAtIndex(index); // Ensure the video is stopped before disposal
        controller.dispose();
        controllers.remove(index);
        debugPrint('🚀🚀🚀 DISPOSED $index');
      }
    }
  }

  void increaseReelViewCount(int index) {
    int? reelId = reels[index].id?.toInt();
    if (reelId == null) return;
    ApiService.instance.call(
      url: Urls.increaseReelViewCount,
      param: {pReelId: reelId},
      completion: (response) {
        ApiStatus data = ApiStatus.fromJson(response);
        if (data.status == true) {
          for (var element in reels) {
            if (element.id == reelId) {
              element.views = (element.views ?? 0) + 1;
            }
          }
        }
      },
    );
  }

  void onPageChanged(int index) {
    if (index == currentIndex.value) return;

    if (index > currentIndex.value) {
      Debounce.debounce(
        'debounce',
        const Duration(milliseconds: 200),
        () {
          _playNextReel(index);
        },
      );
    } else {
      Debounce.debounce(
        'debounce',
        const Duration(milliseconds: 200),
        () {
          _playPreviousReel(index);
        },
      );
    }
    currentIndex.value = index;
    _loadMoreData();
  }

  _loadMoreData() {
    if (profileType != ProfileType.dashboard) return;
    if (currentIndex.value >= reels.length - 3) {
      fetchDoctorReels();
    }
  }

  void onVisibilityChanged(VisibilityInfo info) {
    if (DashboardScreenController.isPlayController) return;
    if (info.visibleFraction == 0.0) {
      initialVisible = false;
      controllers[currentIndex.value]?.pause();
      print('Not Visible');
    } else if (info.visibleFraction >= 1.0) {
      controllers[currentIndex.value]?.play();
      pageController.jumpToPage(currentIndex.value);
      print('Visible data');
    }
  }

  Future<void> onRefresh() async {
    currentIndex.value = 0;
    fetchDoctorReels(
        onComplete: (data) {
          for (final controller in controllers.values) {
            controller.dispose();
          }
          controllers.clear();
          initVideoPlayer();
        },
        isEmptyData: true);
  }

  void fetchDoctorReels({Function(List<Reel> data)? onComplete, bool isEmptyData = false}) {
    ApiService.instance.call(
      url: Urls.fetchReelsDoctorApp,
      param: {pDoctorId: PrefService.id, if (selectedCategory.value.id != 0) pCategoryId: selectedCategory.value.id},
      completion: (response) {
        if (isEmptyData) {
          reels.value = [];
        }
        Reels data = Reels.fromJson(response);
        if (data.status == true) {
          reels.addAll(data.data ?? []);
        }
        onComplete?.call(reels);
      },
    );
  }

  RxBool isDropdownVisible = false.obs;

  toggleContainer() {
    if (animation.status != AnimationStatus.completed) {
      _controller.forward();
      isDropdownVisible.value = true;
    } else {
      _controller.animateBack(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
      );
      isDropdownVisible.value = false;
    }
  }

  void onCategoryChanged({required DoctorCategoryData category}) {
    selectedCategory.value = category;
    toggleContainer();
    currentIndex.value = 0;
    fetchDoctorReels(
        onComplete: (data) {
          for (final controller in controllers.values) {
            controller.dispose();
          }
          controllers.clear();
          if (data.isNotEmpty) {
            initVideoPlayer();
          }
        },
        isEmptyData: true);
  }

  @override
  void onClose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    _controller.dispose();
    super.onClose();
  }
}

class Debounce {
  static final Map<String, _EasyDebounceOperation> _operations = {};

  static void debounce(String tag, Duration duration, EasyDebounceCallback onExecute) {
    if (duration == Duration.zero) {
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);
      onExecute();
    } else {
      _operations[tag]?.timer.cancel();
      _operations[tag] = _EasyDebounceOperation(
          onExecute,
          Timer(duration, () {
            _operations[tag]?.timer.cancel();
            _operations.remove(tag);

            onExecute();
          }));
    }
  }
}

typedef EasyDebounceCallback = void Function();

class _EasyDebounceOperation {
  EasyDebounceCallback callback;
  Timer timer;

  _EasyDebounceOperation(this.callback, this.timer);
}
