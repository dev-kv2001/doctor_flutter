import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/top_bar_tab.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/appointment_screen/appointment_screen_controller.dart';
import 'package:doctor_flutter/screen/appointment_screen/widget/appointment_card.dart';
import 'package:doctor_flutter/screen/appointment_screen/widget/qr_scanner.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentScreenController());
    return GetBuilder(
      init: controller,
      tag: '${DateTime.now().millisecondsSinceEpoch}',
      builder: (controller) => Scaffold(
        backgroundColor: ColorRes.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBarTab(title: S.current.appointments),
            _AppointmentHeader(controller: controller),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateSelector(controller: controller),
                  const SizedBox(height: 10),
                  _AppointmentCount(controller: controller),
                  const SizedBox(height: 10),
                  SearchTextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged),
                  const SizedBox(height: 10),
                  AppointmentCard(controller: controller),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            CommonFun.doctorBanned(() {
              Get.to(() => const QRViewExample());
            });
          },
          backgroundColor: ColorRes.tuftsBlue,
          child: Image.asset(AssetRes.scan, width: 25, color: ColorRes.white),
        ),
      ),
    );
  }
}

// Header with calendar button
class _AppointmentHeader extends StatelessWidget {
  final AppointmentScreenController controller;

  const _AppointmentHeader({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: controller.onAppointmentBoxTap,
      borderRadius: BorderRadius.circular(10),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FittedBox(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: ColorRes.battleshipGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 5),
                Image.asset(AssetRes.icCalender, width: 20, height: 20),
                const SizedBox(width: 10),
                Obx(
                  () => Text(
                    "${DateFormat.MMMM().format(controller.selectedDay.value)} ${controller.selectedDay.value.year}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontFamily: FontRes.semiBold,
                        color: ColorRes.tuftsBlue),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Date Selector Widget
class _DateSelector extends StatelessWidget {
  final AppointmentScreenController controller;

  const _DateSelector({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 63,
        child: ListView.builder(
          controller: controller.dateController,
          itemCount: controller.days.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (context, index) {
            final dateKey = GlobalKey();
            DateTime time = controller.days[index];
            return Obx(
              () {
                return DateView(
                    key: dateKey,
                    onTap: () {
                      controller.onSelectedDateClick(
                          dateTime: time, index: index);
                    },
                    isSelected: controller.selectedDay.value
                        .isSameDate(controller.days[index]),
                    time: time);
              },
            );
          },
        ),
      ),
    );
  }
}

// Appointment Count Text
class _AppointmentCount extends StatelessWidget {
  final AppointmentScreenController controller;

  const _AppointmentCount({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Obx(
        () => Text(
          "${controller.acceptAppointment.length} ${S.current.appointments}",
          style: const TextStyle(
            fontSize: 17,
            fontFamily: FontRes.medium,
            color: ColorRes.darkJungleGreen,
          ),
        ),
      ),
    );
  }
}

class DateView extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final DateTime time;

  const DateView(
      {super.key,
      required this.onTap,
      required this.isSelected,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 63,
        width: 63,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1)),
            shadows: !isSelected
                ? null
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(.15), blurRadius: 5.0)
                  ],
            color: isSelected ? ColorRes.havelockBlue : ColorRes.softPeach),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat.E().format(time).toUpperCase(),
              style: TextStyle(
                  color: isSelected ? ColorRes.white : ColorRes.charcoalGrey,
                  fontSize: 12,
                  fontFamily: FontRes.medium),
            ),
            const SizedBox(height: 1),
            Text(
              time.day.toString(),
              style: TextStyle(
                color: isSelected ? ColorRes.white : ColorRes.charcoalGrey,
                fontSize: 24,
                fontFamily: FontRes.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String value) onChanged;

  const SearchTextField(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: ColorRes.whiteSmoke, borderRadius: BorderRadius.circular(30)),
      alignment: Alignment.center,
      child: TextField(
          controller: controller,
          onChanged: onChanged,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            hintText: S.current.search,
            hintStyle: const TextStyle(color: ColorRes.nobel),
          ),
          style: const TextStyle(
              fontFamily: FontRes.medium,
              fontSize: 15,
              color: ColorRes.charcoalGrey),
          cursorHeight: 15,
          cursorColor: ColorRes.charcoalGrey),
    );
  }
}
