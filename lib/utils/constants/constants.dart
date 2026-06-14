import 'package:flutter/material.dart';


@immutable
class Constants {
  const Constants._();
  static RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\.]+\.(com|pk)+",
  );
  static RegExp contactRegex = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
  static const invalidEmailError = 'Please enter a valid email address';
  static const emptyPasswordInputError = 'Please enter your password';
  static const emptyConfirmPasswordInputError = 'Please enter a confirm password';
  static const passwordgreaterthansix = 'Password must be greater than 8 character';
  static const emptyEmailInputError = 'Please enter your email';
  static const nameInputEmptyError = "Please enter your name";
  static const confirmPasswordNotMatched = "Confirm password do not match";
  static const couldNotAnalyzeImageError = "Couldn't analyze file !!";

  static const String hostUrlDev = 'https://agent-generated-api.onrender.com/';
  static const String hostUrl = 'https://agent-generated-api.onrender.com/';
  static const String agentsUrl = 'https://agent-generated-api.onrender.com/';

  static const String devBaseUrl = 'https://agent-generated-api.onrender.com/';
  static const String baseUrl = 'https://agent-generated-api.onrender.com/';

  static const String apiKey = '23VDzUEik7jr8nwnl8JGszBkjN6y8EsV';
  static String somethingWentWrong = 'Something went wrong';
  static String noInternet = 'No internet connection';
  static String userNotFoundError = "User not found";
  static String otpNotVerifiedCaseText = 'Your account is pending an OTP approval';
  static int listingChoice = 1;
  static String sessionApiLimit = "15";
  static String chatsApiLimit = "15";

  static String englishQuery = "Respond in English";
  static String arabicQuery = "Respond in Arabic";
  static String visionPlugin = "plugin-1712327325";
  static String internetPlugin = "plugin-1713924030";
  static String documentPlugin = "plugin-1713962163";
  static String perplexityPlugin = "plugin-1722260873";
  static String agentsCategoryEntityId = "plugin_category";

  static String privacyLink = "https://gitlab.com/__developer/privacypolicy/-/blob/master/amal_ios_privacy_policy.md";
  static String supportEmail = "info@schoolhack.com";
  static String discordLink = "https://discord.gg/rvTsuhaeZa";
  static String shareUserProfileLink = "https://app.schoolhack.ai/profile?user_id=";

  static String singlePlayerMCQsKey = "quiz_generation";
  static String singlePlayerShortAnswersKey = "short_answer_quiz_generation";
  static String singlePlayerFillInBlanksKey = "one_word_answer_quiz_generation";
  static String singlePlayerFlashCardsKey = "flashcard_generation";
  
  static String appStoreId = "1667172863";

}
