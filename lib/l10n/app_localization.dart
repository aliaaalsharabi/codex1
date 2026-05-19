import 'package:flutter/material.dart';

abstract class AppLocalization {
  static AppLocalization of(context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  String get appName;
  String get welcome;
  String get toProgrammersWorld;

  // Onboarding
  String get skip;
  String get next;
  String get getStarted;
  String get onboardingTitle1;
  String get onboardingDesc1;
  String get onboardingTitle2;
  String get onboardingDesc2;
  String get onboardingTitle3;
  String get onboardingDesc3;
  String get onboardingTitle4;
  String get onboardingDesc4;

  // Auth
  String get welcomeToCodex;
  String get authSubtitle;
  String get login;
  String get register;
  String get codexPlatform;
  String get welcomeBack;
  String get loginSubtitle;
  String get email;
  String get password;
  String get forgetPassword;
  String get noAccount;
  String get createAccount;
  String get createNewAccount;
  String get registerSubtitle;
  String get name;
  String get fullName;
  String get phone;
  String get phoneOptional;
  String get userType;
  String get coder;
  String get company;
  String get vendor;
  String get consultant;
  String get confirmPassword;
  String get alreadyHaveAccount;
  String get loginNow;
  String get rememberPassword;


  // Errors
  String get errorInvalidEmail;
  String get errorUserDisabled;
  String get errorUserNotFound;
  String get errorWrongPassword;
  String get errorTooManyRequests;
  String get errorNetwork;
  String get errorInvalidCredential;
  String get errorUnexpected;
  String get errorEmailInUse;
  String get errorWeakPassword;
  String get pleaseEnterEmail;
  String get pleaseEnterPassword;
  String get loginFailed;
  String get passwordsNotMatch;
  String get passwordMinLength;
  String get enterValidEmail;
  String get registrationFailed;
  String get registrationSuccess;

  // Forget Password
  String get forgetPasswordTitle;
  String get forgetPasswordSubtitle;
  String get sendResetLink;
  String get resetLinkSent;
  String get emailNote;

  // Navigation
  String get navAds;
  String get navStore;
  String get navConsultation;
  String get navProfile;

  // Home
  String get search;
  String get noInternet;
  String get sampleDataAdded;
  String get noJobsAvailable;
  String get addJobHint;
  String get errorOccurred;
  String get retry;
  String get noImage;
  String get locationUnknown;
  String get typeUnknown;
  String get deadlineLabel;
  String get noDeadline;
  String get open;
  String get closed;
  String get addSampleData;

  // Store
  String get searchProduct;
  String get noProducts;
  String get sar;
  String get noResults;
  String get cart;

  // Cart
  String get cartTitle;
  String get priceLabel;
  String get currency;
  String get checkout;
  String get total;
  String get pay;
  String get emptyCart;
  String get emptyCartSub;
  String get confirmDelete;
  String get confirmDeleteMsg;
  String get cancel;
  String get delete;

  // Product Details
  String get productDetails;
  String get productNotFound;
  String get description;
  String get category;
  String get quantity;
  String get noDescription;
  String get addedToCart;
  String get addToCart;
  String get noProductImage;
  String get imageLoadFailed;
  String get outOfStock;
  String get available;
  String get price;

  // Jobs Ads
  String get jobAdsTitle;
  String get noJobs;

  // Comments
  String get comments;
  String get noComments;
  String get beFirstComment;
  String get writeComment;

  // Consultations
  String get consultationWith;
  String get pleaseLogin;
  String get startConversation;
  String get writeMessage;

  // AI Chat
  String get aiAssistant;
  String get aiSmartAssistant;
  String get you;
  String get aiLlama;
  String get askAi;
  String get analyzing;
  String get loginRequired;

  // Chat
  String get chatWithConsultant;
  String get noMessages;

  // New Message
  String get newMessage;
  String get createConsultation;
  String get contacts;
  String get newConsultationTitle;
  String get consultationTitle;
  String get consultationDesc;
  String get create;
  String get searchContacts;

  // Profile
  String get editProfile;
  String get myAddresses;
  String get myOrders;
  String get settings;
  String get language;
  String get logout;
  String get areYouSure;
  String get exit;
  String get username;
  String get editProfileTitle;
  String get editInfo;
  String get editInfoSubtitle;
  String get personalData;
  String get saveChanges;
  String get noChanges;
  String get updatedSuccessfully;
  String get updateError;

  // Add Post
  String get addPost;
  String get addImage;
  String get imageFormat;
  String get postType;
  String get job;
  String get product;
  String get title;
  String get location;
  String get jobType;
  String get deadline;

  String get fullTime;
  String get submitPost;
  String get postSuccess;
  String get postSuccessWithImage;
  String get selectType;
  String get enterTitle;
  String get enterDescription;
  String get loginFirst;
  String get uploadFailed;

  // No Internet
  String get noInternetTitle;
  String get noInternetSubtitle;

  // Language Settings
  String get systemDefault;
  String get arabic;
  String get english;
  String get selectLanguage;
}
