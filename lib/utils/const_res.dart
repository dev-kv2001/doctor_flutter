import 'package:flutter/foundation.dart';

class ConstRes {
  ///------------------------ Backend urls and key ------------------------///

  static const String base = 'https://africmed.org/';
  static const String baseURL = '${base}api/';
  static const String itemBaseURL = 'https://africmed-s3.s3.eu-north-1.amazonaws.com/';

  // static const String itemBaseURL = '${base}public/storage/';
  static const String privacyPolicy = '${base}privacypolicy';
  static const String termsOfUser = '${base}termsOfUse';
  // static const String apiKey = '123';
  static const String apiKey = 'ypTHf0sslNzFOr2qDNUg3zO9jqprIco0';

  ///------------------------ Notification token ------------------------///

  static const String subscribeTopic = 'doctor';

  ///------------------------ Agora app Id ------------------------///

  static const String agoraAppId = "37c90db738d841aaa41266040bd13acb";
}

// App Name
const String appName = 'Africmed Doctor';
const String subAppName = 'Africmed Doctor';

// App Default Language only use This code :-  ('ar', 'da','nl','en','fr','de','el','hi','id','it','ja','ko','nb','pl','pt','ru','zh','es','th','tr','vi')
// const appLanguageCode = 'en';
const appLanguageCode = kReleaseMode ? 'fr' : 'en';

// For Phone Number field
const countryName = 'France';
const countryCode = 'FR';
const phoneCode = '+33';

///------------------------ Image quality ------------------------///
const int imageQuality = 40;
const double maxWidth = 720;
const double maxHeight = 720;

//  Slot Limit
const int maxSlotLimit = 10;

// pagination count
const paginationLimit = 10;
