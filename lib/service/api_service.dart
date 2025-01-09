import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:doctor_flutter/model/appointment/appointment_detail.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/model/appointment_slot/add_slot.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/model/global/agora_token.dart';
import 'package:doctor_flutter/model/global/faq_cat.dart';
import 'package:doctor_flutter/model/global/get_path.dart';
import 'package:doctor_flutter/model/global/global_setting.dart';
import 'package:doctor_flutter/model/message/api_status.dart';
import 'package:doctor_flutter/model/notification/notification.dart'
    as notification;
import 'package:doctor_flutter/model/review/review.dart';
import 'package:doctor_flutter/model/user/fetch_user_detail.dart';
import 'package:doctor_flutter/model/wallet/earning_history.dart';
import 'package:doctor_flutter/model/wallet/payout_history.dart';
import 'package:doctor_flutter/model/wallet/wallet_statement.dart';
import 'package:doctor_flutter/service/pref_service.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static ApiService get instance {
    return ApiService();
  }

  Future<Registration> doctorRegistration({
    String? identity,
    String? deviceToken,
    String? name,
    int? isLogin,
  }) async {
    http.Response response = await http.post(
      Uri.parse(Urls.doctorRegistration),
      headers: {pApiKeyName: ConstRes.apiKey},
      body: {
        pIdentity: identity,
        pDeviceToken: deviceToken,
        pName: name,
        pIsLogin: '$isLogin',
        pDeviceType: Platform.isAndroid ? '1' : '2'
      },
    );
    debugPrint('${{
      pIdentity: identity,
      pDeviceToken: deviceToken,
      pName: name,
      pIsLogin: '$isLogin',
    }}');
    log(response.body);
    Registration registration =
        Registration.fromJson(jsonDecode(response.body));
    PrefService prefService = PrefService();
    await prefService.init();
    await prefService.saveString(
        key: kRegistrationUser, value: jsonEncode(registration.data?.toJson()));
    return registration;
  }

  Future<Registration> updateDoctorDetails(
      {String? name,
      String? countryCode,
      int? gender,
      int? categoryId,
      String? designation,
      String? savedReels,
      String? degrees,
      String? languagesSpoken,
      String? experienceYear,
      String? consultationFee,
      String? aboutYourself,
      String? educationalJourney,
      int? onlineConsultation,
      int? clinicConsultation,
      double? clinicLong,
      double? clinicLat,
      String? clinicAddress,
      String? clinicName,
      File? image,
      int? notification,
      int? vacationMode,
      String? mobileNumber}) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.updateDoctorDetails),
    );
    request.headers.addAll({
      pApiKeyName: ConstRes.apiKey,
    });
    request.fields[pDoctorId] = PrefService.id.toString();
    if (name != null) {
      request.fields[pName] = name;
    }
    if (savedReels != null) {
      request.fields[pSavedReel] = savedReels;
    }
    if (countryCode != null) {
      request.fields[pCountryCode] = countryCode;
    }
    if (gender != null) {
      request.fields[pGender] = '$gender';
    }
    if (categoryId != null) {
      request.fields[pCategoryId] = '$categoryId';
    }
    if (designation != null) {
      request.fields[pDesignation] = designation;
    }
    if (degrees != null) {
      request.fields[pDegrees] = degrees;
    }
    if (languagesSpoken != null) {
      request.fields[pLanguagesSpoken] = languagesSpoken;
    }
    if (experienceYear != null) {
      request.fields[pExperienceYear] = experienceYear;
    }
    if (consultationFee != null) {
      request.fields[pConsultationFee] = consultationFee;
    }
    if (aboutYourself != null) {
      request.fields[pAboutYourself] = aboutYourself;
    }
    if (educationalJourney != null) {
      request.fields[pEducationalJourney] = educationalJourney;
    }
    if (onlineConsultation != null) {
      request.fields[pOnlineConsultation] = '$onlineConsultation';
    }
    if (clinicConsultation != null) {
      request.fields[pClinicConsultation] = '$clinicConsultation';
    }
    if (clinicName != null) {
      request.fields[pClinicName] = clinicName;
    }
    if (clinicAddress != null) {
      request.fields[pClinicAddress] = clinicAddress;
    }
    if (clinicLat != null) {
      request.fields[pClinicLat] = '$clinicLat';
    }
    if (clinicLong != null) {
      request.fields[pClinicLong] = '$clinicLong';
    }
    if (notification != null) {
      request.fields[pIsNotification] = '$notification';
    }
    if (vacationMode != null) {
      request.fields[pOnVacation] = '$vacationMode';
    }
    if (mobileNumber != null && mobileNumber != 'null') {
      request.fields[pMobileNumber] = mobileNumber;
    }
    if (image != null) {
      request.files.add(http.MultipartFile(
          pImage, image.readAsBytes().asStream(), image.lengthSync(),
          filename: image.path.split("/").last));
    }
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    final responseJson = jsonDecode(respStr);
    Registration updateProfile = Registration.fromJson(responseJson);

    PrefService prefService = PrefService();
    await prefService.init();
    await prefService.saveString(
        key: kRegistrationUser,
        value: jsonEncode(updateProfile.data?.toJson()));
    return updateProfile;
  }

  Future<DoctorCategory> fetchDoctorCategories() async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchDoctorCategories),
      headers: {pApiKeyName: ConstRes.apiKey},
    );
    DoctorCategory doctorCategory =
        DoctorCategory.fromJson(jsonDecode(response.body));
    return doctorCategory;
  }

  Future<ApiStatus> suggestDoctorCategory(
      {String? title, String? about}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.suggestDoctorCategory),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: {
        pTitle: title,
        pAbout: about,
      },
    );
    ApiStatus message = ApiStatus.fromJson(jsonDecode(response.body));
    return message;
  }

  Future<notification.Notification> fetchDoctorNotifications(
      {int? start}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchDoctorNotifications),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: {
        pStart: start.toString(),
        pCount: '$paginationLimit',
      },
    );
    return notification.Notification.fromJson(jsonDecode(response.body));
  }

  Future<Registration> fetchMyDoctorProfile({int? doctorId}) async {
    http.Response response = await http.post(
        Uri.parse(Urls.fetchMyDoctorProfile(doctorId ?? PrefService.id)),
        headers: {pApiKeyName: ConstRes.apiKey},
        body: {pDoctorId: '${doctorId ?? PrefService.id}'});

    Registration data = Registration.fromJson(jsonDecode(response.body));
    PrefService prefService = PrefService();
    if (data.data?.id == PrefService.id) {
      await prefService.init();
      await prefService.saveString(
          key: kRegistrationUser, value: jsonEncode(data.data?.toJson()));
    }
    return data;
  }

  Future<Registration> addEditService(
      {String? title, int? apiType, int? serviceId}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pTitle] = title;
    map[pType] = apiType.toString();
    if (apiType != null) {
      map[pServiceId] = serviceId.toString();
    }

    http.Response response = await http.post(
      Uri.parse(Urls.addEditService),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return Registration.fromJson(jsonDecode(response.body));
  }

  Future<Registration> addEditExpertise(
      {String? title, int? apiType, int? expertiseId}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pTitle] = title;
    map[pType] = apiType.toString();
    if (apiType != null) {
      map[pExpertiseId] = expertiseId.toString();
    }

    http.Response response = await http.post(
      Uri.parse(Urls.addEditExpertise),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return Registration.fromJson(jsonDecode(response.body));
  }

  Future<Registration> addEditExperience(
      {String? title, int? apiType, int? experienceId}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pTitle] = title;
    map[pType] = apiType.toString();
    if (apiType != null) {
      map[pExperienceId] = experienceId.toString();
    }

    http.Response response = await http.post(
      Uri.parse(Urls.addEditExperience),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return Registration.fromJson(jsonDecode(response.body));
  }

  Future<Registration> addEditAwards(
      {String? title, int? apiType, int? awardId}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pTitle] = title;
    map[pType] = apiType.toString();
    if (apiType != null) {
      map[pAwardId] = awardId.toString();
    }

    http.Response response = await http.post(
      Uri.parse(Urls.addEditAwards),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return Registration.fromJson(jsonDecode(response.body));
  }

  Future<Registration> addEditServiceLocations(
      {String? hospitalTitle,
      String? hospitalAddress,
      int? type,
      int? serviceLocationId,
      double? hospitalLat,
      double? hospitalLong}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pHospitalTitle] = hospitalTitle;
    map[pHospitalAddress] = hospitalAddress;
    map[pType] = type.toString();
    map[pHospitalLat] = hospitalLat.toString();
    map[pHospitalLong] = hospitalLong.toString();
    if (type != null) {
      map[pServiceLCationId] = serviceLocationId.toString();
    }

    http.Response response = await http.post(
      Uri.parse(Urls.addEditServiceLocations),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return Registration.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> addHoliday({
    String? date,
  }) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pDate] = date;
    http.Response response = await http.post(
      Uri.parse(Urls.addHoliday),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> deleteHoliday({
    int? holidayId,
  }) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pHolidayId] = holidayId.toString();
    http.Response response = await http.post(
      Uri.parse(Urls.deleteHoliday),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<AddSlot> addAppointmentSlots(
      {required String time,
      required int weekday,
      required String bookingLimit}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pTime] = time;
    map[pWeekday] = weekday.toString();
    map[pBookingLimit] = bookingLimit;
    http.Response response = await http.post(
      Uri.parse(Urls.addAppointmentSlots),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return AddSlot.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> deleteAppointmentSlot({int? slotId}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pSlotId] = slotId.toString();
    http.Response response = await http.post(
      Uri.parse(Urls.deleteAppointmentSlot),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<Registration> manageDrBankAccount({
    File? chequePhoto,
    String? bankName,
    String? accountNumber,
    String? holderName,
    String? swiftCode,
  }) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.manageDrBankAccount),
    );
    request.headers.addAll({
      pApiKeyName: ConstRes.apiKey,
    });
    request.fields[pDoctorId] = '${PrefService.id}';
    if (bankName != null) {
      request.fields[pBankName] = bankName;
    }
    if (accountNumber != null) {
      request.fields[pAccountNumber] = accountNumber;
    }
    if (holderName != null) {
      request.fields[pHolder] = holderName;
    }
    if (swiftCode != null) {
      request.fields[pSwiftCode] = swiftCode;
    }
    if (chequePhoto != null) {
      request.files.add(http.MultipartFile(pChequePhoto,
          chequePhoto.readAsBytes().asStream(), chequePhoto.lengthSync(),
          filename: chequePhoto.path.split("/").last));
    }
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    final responseJson = jsonDecode(respStr);
    Registration userData = Registration.fromJson(responseJson);
    PrefService prefService = PrefService();
    await prefService.init();
    await prefService.saveString(
        key: kRegistrationUser, value: jsonEncode(userData.data?.toJson()));

    return userData;
  }

  Future<AppointmentRequest> fetchAppointmentRequests({int? start}) async {
    Map<String, dynamic> map = {};
    map[pDoctorId] = PrefService.id.toString();
    map[pStart] = start.toString();
    map[pCount] = '$paginationLimit';
    http.Response response = await http.post(
        Uri.parse(Urls.fetchAppointmentRequests),
        headers: {pApiKeyName: ConstRes.apiKey},
        body: map);

    return AppointmentRequest.fromJson(jsonDecode(response.body));
  }

  Future<AppointmentDetail> fetchAppointmentDetails(
      {int? appointmentId}) async {
    Map<String, dynamic> map = {};
    map[pAppointmentId] = '$appointmentId';
    http.Response response = await http.post(
      Uri.parse(Urls.fetchAppointmentDetails),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return AppointmentDetail.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> acceptAppointment(
      {int? appointmentId, int? doctorId}) async {
    Map<String, dynamic> map = {};
    map[pAppointmentId] = '$appointmentId';
    map[pDoctorId] = '$doctorId';
    http.Response response = await http.post(
      Uri.parse(Urls.acceptAppointment),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> declineAppointment(
      {int? appointmentId, int? doctorId}) async {
    Map<String, dynamic> map = {};
    map[pAppointmentId] = '$appointmentId';
    map[pDoctorId] = '$doctorId';
    http.Response response = await http.post(
      Uri.parse(Urls.declineAppointment),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: map,
    );
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<AppointmentRequest> fetchAcceptedAppointsByDate(
      {required String date}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchAcceptedAppointsByDate),
      headers: {pApiKeyName: ConstRes.apiKey},
      body: {pDate: date, pDoctorId: PrefService.id.toString()},
    );
    return AppointmentRequest.fromJson(jsonDecode(response.body));
  }

  Future<AppointmentRequest> fetchAppointmentHistory(
      {required int? start}) async {
    log(PrefService.id.toString());
    http.Response response =
        await http.post(Uri.parse(Urls.fetchAppointmentHistory), headers: {
      pApiKeyName: ConstRes.apiKey,
    }, body: {
      pDoctorId: PrefService.id.toString(),
      pStart: start.toString(),
      pCount: '$paginationLimit'
    });
    return AppointmentRequest.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> addPrescription(
      {required int? appointmentId,
      int? userId,
      required Map<String, dynamic>? medicine}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.addPrescription), headers: {
      pApiKeyName: ConstRes.apiKey,
    }, body: {
      pAppointmentId: appointmentId.toString(),
      pUserId: userId.toString(),
      pMedicine: jsonEncode(medicine)
    });
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> editPrescription(
      {int? prescriptionId, required Map<String, dynamic>? medicine}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.editPrescription), headers: {
      pApiKeyName: ConstRes.apiKey,
    }, body: {
      pPrescriptionId: prescriptionId.toString(),
      pMedicine: jsonEncode(medicine)
    });
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> completeAppointment(
      {int? appointmentId,
      int? doctorId,
      required String otp,
      required String diagnoseWith}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.completeAppointment), headers: {
      pApiKeyName: ConstRes.apiKey,
    }, body: {
      pAppointmentId: appointmentId.toString(),
      pDoctorId: doctorId.toString(),
      pCompletionOtp: otp,
      pDiagnosedWith: diagnoseWith,
    });
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<WalletStatement> fetchDoctorWalletStatement({int? start}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchDoctorWalletStatement),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: {
        pDoctorId: PrefService.id.toString(),
        pStart: start.toString(),
        pCount: '$paginationLimit'
      },
    );
    return WalletStatement.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> submitDoctorWithdrawRequest() async {
    http.Response response = await http.post(
      Uri.parse(Urls.submitDoctorWithdrawRequest),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: {
        pDoctorId: PrefService.id.toString(),
      },
    );
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<Review> fetchDoctorReviews({int? start}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchDoctorReviews),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: {
        pDoctorId: PrefService.id.toString(),
        pStart: start.toString(),
        pCount: '$paginationLimit'
      },
    );
    return Review.fromJson(jsonDecode(response.body));
  }

  Future<EarningHistory> fetchDoctorEarningHistory(
      {String? month, String? year}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchDoctorEarningHistory),
      headers: {
        pApiKeyName: ConstRes.apiKey,
      },
      body: {
        pDoctorId: PrefService.id.toString(),
        pMonth: month.toString(),
        pYear: year.toString()
      },
    );
    return EarningHistory.fromJson(jsonDecode(response.body));
  }

  Future<PayoutHistory> fetchDoctorPayoutHistory() async {
    http.Response response = await http.post(
        Uri.parse(Urls.fetchDoctorPayoutHistory),
        headers: {pApiKeyName: ConstRes.apiKey},
        body: {pDoctorId: PrefService.id.toString()});

    return PayoutHistory.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> checkMobileNumberExists(
      {required String mobileNumber}) async {
    http.Response response = await http.post(
        Uri.parse(Urls.checkMobileNumberExists),
        headers: {pApiKeyName: ConstRes.apiKey},
        body: {pMobileNumber: mobileNumber});

    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<FaqCat> fetchFaqCats() async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchFaqCats),
      headers: {pApiKeyName: ConstRes.apiKey},
    );
    return FaqCat.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> logOutDoctor() async {
    http.Response response =
        await http.post(Uri.parse(Urls.logOutDoctor), headers: {
      pApiKeyName: ConstRes.apiKey
    }, body: {
      pDoctorId: PrefService.id.toString(),
    });
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<ApiStatus> deleteDoctorAccount() async {
    http.Response response =
        await http.post(Uri.parse(Urls.deleteDoctorAccount), headers: {
      pApiKeyName: ConstRes.apiKey
    }, body: {
      pDoctorId: PrefService.id.toString(),
    });
    return ApiStatus.fromJson(jsonDecode(response.body));
  }

  Future<GlobalSetting> fetchGlobalSettings() async {
    http.Response response = await http.post(
        Uri.parse(Urls.fetchGlobalSettings),
        headers: {pApiKeyName: ConstRes.apiKey});
    GlobalSetting setting = GlobalSetting.fromJson(jsonDecode(response.body));
    PrefService prefService = PrefService();
    await prefService.init();
    await prefService.saveString(
        key: kGlobalSetting, value: jsonEncode(setting.data));
    return setting;
  }

  Future<GetPath> uploadFileGivePath(File? image) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.uploadFileGivePath),
    );
    request.headers.addAll({
      pApiKeyName: ConstRes.apiKey,
    });
    if (image != null) {
      request.files.add(
        http.MultipartFile(
            pFile, image.readAsBytes().asStream(), image.lengthSync(),
            filename: image.path.split("/").last),
      );
    }
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    final responseJson = jsonDecode(respStr);
    return GetPath.fromJson(responseJson);
  }

  Future<AgoraToken> getAgoraToken({required String channelName}) async {
    http.Response response = await http.post(Uri.parse(Urls.generateAgoraToken),
        headers: {pApiKeyName: ConstRes.apiKey},
        body: {pChannelName: channelName});
    return AgoraToken.fromJson(jsonDecode(response.body));
  }

  Future<FetchUserDetail> fetchUserDetails({required int userId}) async {
    http.Response response = await http.post(Uri.parse(Urls.fetchUserDetails),
        headers: {pApiKeyName: ConstRes.apiKey},
        body: {pUserId: userId.toString()});
    return FetchUserDetail.fromJson(jsonDecode(response.body));
  }

  Future pushNotification(
      {required Map<String, dynamic> data, required String token}) async {
    await http
        .post(
      Uri.parse(Urls.pushNotificationToSingleUser),
      headers: {
        pApiKeyName: ConstRes.apiKey,
        'content-type': 'application/json'
      },
      body: json.encode({
        'message': {'token': token, 'data': data}
      }),
    )
        .then(
      (value) {
        log('Notification Push :- ${value.body}');
      },
    );
  }

  void call(
      {required String url,
      Map<String, dynamic>? param,
      required Function(Object response) completion}) async {
    Map<String, String> params = {};
    param?.forEach((key, value) {
      params[key] = "$value";
    });

    debugPrint('👉 URL $url');
    debugPrint('👉 Parameters $param');
    try {
      await http
          .post(Uri.parse(url),
              headers: {
                pApiKeyName: ConstRes.apiKey,
              },
              body: params)
          .then((value) {
        debugPrint('👉 Response ${value.body}');
        debugPrint('👉 Status Code ${value.statusCode}');
        var response = jsonDecode(value.body);
        completion(response);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void multiPartCallApi(
      {required String url,
      Map<String, dynamic>? param,
      required Map<String, List<XFile?>> filesMap,
      required Function(Object response) completion}) {
    var request = MultipartRequest(
      pPost,
      Uri.parse(url),
      onProgress: (bytes, totalBytes) {
        final progress = bytes / totalBytes;
        debugPrint('progress: $progress ($bytes/$totalBytes)');
      },
    );

    Map<String, String> params = {};

    param?.forEach((key, value) {
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          params['$key[$i]'] = value[i];
        }
      } else {
        params[key] = "$value";
      }
    });

    request.fields.addAll(params);
    request.headers.addAll({pApiKeyName: ConstRes.apiKey});

    filesMap.forEach((keyName, files) {
      for (var xFile in files) {
        if (xFile != null && xFile.path.isNotEmpty) {
          File file = File(xFile.path);
          var multipartFile = http.MultipartFile(
              keyName, file.readAsBytes().asStream(), file.lengthSync(),
              filename: xFile.name);
          request.files.add(multipartFile);
        }
      }
    });
    debugPrint('Parameter ::${param.toString()}');
    debugPrint('Files :${request.files.toString()}');

    request.send().then((value) {
      debugPrint('Status Code : ${value.statusCode}');
      value.stream.bytesToString().then((respStr) {
        var response = jsonDecode(respStr);
        debugPrint('Response : $respStr');
        completion(response);
      });
    });
  }
}

class MultipartRequest extends http.MultipartRequest {
  /// Creates a new [MultipartRequest].
  MultipartRequest(
    super.method,
    super.url, {
    this.onProgress,
  });

  final void Function(int bytes, int totalBytes)? onProgress;

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    // if (onProgress == null) return byteStream;

    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        if (onProgress != null) {
          onProgress!(bytes, total);
        }
        if (total >= bytes) {
          sink.add(data);
        }
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
