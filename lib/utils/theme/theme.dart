import 'package:agent_lab/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../constants/pallete.dart';
import '../constants/style_constants.dart';

var lightTheme = ThemeData(
  // Define the default font family.
  fontFamily: 'sohne',
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColor: Pallete.dividerColor,
  scaffoldBackgroundColor: Colors.white,
  unselectedWidgetColor: Pallete.darkBg,
  drawerTheme: const DrawerThemeData(
    backgroundColor: Pallete.dividerColor,
    scrimColor: Pallete.transparent,
    elevation: 4.0,
  ),
  splashColor: Pallete.darkBg.withOpacity(0.1),
  // button splash color

  useMaterial3: true,

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  //
  // textTheme: Typography.material2021().englishLike.apply(
  //     fontFamily: 'Recoleta',
  //     bodyColor: secondaryColor,
  //     displayColor: onSecondaryColor,
  // fontSizeFactor: 1.sp,
  // ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 96.sp),
    displayMedium: TextStyle(fontSize: 72.sp),
    displaySmall: TextStyle(fontSize: 60.sp),
    headlineLarge: TextStyle(fontSize: 48.sp),
    headlineMedium: TextStyle(fontSize: 40.sp),
    headlineSmall: TextStyle(fontSize: 34.sp),
    titleLarge: TextStyle(fontSize: 38.sp),
    titleMedium: TextStyle(fontSize: 24.sp),
    titleSmall: TextStyle(fontSize: 20.sp),
    bodyLarge: TextStyle(fontSize: 18.sp),
    bodyMedium: TextStyle(fontSize: 16.sp),
    bodySmall: TextStyle(fontSize: 13.sp),
    labelSmall: TextStyle(fontSize: 10.sp),
  ).apply(
    fontFamily: 'sohne',
    bodyColor: Pallete.black,
    displayColor: Pallete.black,
    fontSizeFactor: 1.sp,
  ),
  datePickerTheme: DatePickerThemeData(
    weekdayStyle: StyleConstants.style14600.copyWith(color: Pallete.grey05),
    dayStyle: StyleConstants.style14600.copyWith(color: Pallete.white),
    yearStyle: StyleConstants.style14600.copyWith(color: Pallete.grey05),
    inputDecorationTheme: InputDecorationTheme(contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), floatingLabelStyle: const TextStyle(fontSize: 0.0)),
    yearForegroundColor: Pallete.white.asMaterialStateProperty,
    headerHeadlineStyle: StyleConstants.style18600.copyWith(color: Pallete.grey05),
    headerForegroundColor: Pallete.white,
    headerHelpStyle: StyleConstants.style14600.copyWith(color: Pallete.grey05),
  ),
  timePickerTheme: TimePickerThemeData(
      helpTextStyle: StyleConstants.style14500.copyWith(color: Pallete.white),
      hourMinuteColor: Pallete.backGround.withOpacity(.8),
      hourMinuteTextColor: Pallete.white,
      hourMinuteTextStyle: StyleConstants.style40700.copyWith(color: Pallete.white),
      dialBackgroundColor: Pallete.backGround.withOpacity(.8),
      dialTextColor: Pallete.white,
      dialTextStyle: StyleConstants.style14600.copyWith(color: Pallete.white),
      dayPeriodColor: Pallete.backGround.withOpacity(.8),
      dayPeriodTextColor: Pallete.white,
      dayPeriodTextStyle: StyleConstants.style14600.copyWith(color: Pallete.white)),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Pallete.dividerColor,
    onPrimary: Pallete.darkBg,
    primaryContainer: Pallete.dividerColor,
    onPrimaryContainer: Pallete.darkBg,
    secondary: Pallete.andyLightBG,
    onSecondary: Pallete.darkBg,
    secondaryContainer: Pallete.andyLightBG,
    onSecondaryContainer: Pallete.darkBg,
    tertiary: Pallete.andyLightBG,
    onTertiary: Pallete.darkBg,
    tertiaryContainer: Pallete.andyLightBG,
    onTertiaryContainer: Pallete.darkBg,
    error: Colors.red,
    onError: Colors.white,
    errorContainer: Colors.red,
    onErrorContainer: Colors.white,
    brightness: Brightness.dark,
    background: Colors.red,
    outline: Pallete.andyLightBG,
    // inverseSurface: onPrimaryColor,
    // surfaceTint: Color(0xFF000000),
    // onInverseSurface: primaryColor,
    // inversePrimary: onPrimaryColor,
    // shadow: Color(0xFF000000),
    // outlineVariant: Color(0xFF534341),
    // scrim: Color(0xFF000000),
    surface: Pallete.andyLightBG,
    onSurface: Pallete.darkBg,
    // surfaceVariant: Color(0xFF534341),
    // onSurfaceVariant: Color(0xFFD8C2BF),
  ),
  listTileTheme: ListTileThemeData(
    titleTextStyle: StyleConstants.style15500.copyWith(color: Pallete.darkBg),
  ),

  // BUTTON

  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.normal,
    buttonColor: Pallete.darkBg,
    splashColor: Pallete.darkBg.withOpacity(0.1),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      // primary: onPrimaryColor,
      // secondary: Colors.white,
      brightness: Brightness.dark,
      background: Colors.white,
      //background color for widgets like Card, BottomNavigationBar,btns etc
      surface: Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100.0),
    ),
    height: 60.h,
    padding: EdgeInsets.symmetric(
      vertical: 14.h,
      horizontal: 20.w,
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Pallete.darkBg,
  ),
  switchTheme: const SwitchThemeData(
    splashRadius: 15.0,
    trackColor: WidgetStatePropertyAll(Pallete.grey05),
    thumbColor: WidgetStatePropertyAll(Pallete.darkBg),
    trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
  ),
  cardTheme: CardThemeData(
    elevation: 0.6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  // alert dialog
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    shadowColor: Colors.black.withOpacity(0.8),
    actionsPadding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 28.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.r),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Pallete.blackBG,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0.0,
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Colors.white,
    ),
    actionsIconTheme: IconThemeData(
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Pallete.blackBG,
      size: 24,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Pallete.darkBg),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        StyleConstants.style14500.copyWith(color: Pallete.dividerColor),
      ),
    ),
  ),
  snackBarTheme: mySnackBarTheme(),
  checkboxTheme: lightCheckBoxTheme(),
  popupMenuTheme: PopupMenuThemeData(
    color: Pallete.darkBg,
    position: PopupMenuPosition.over,
    textStyle: StyleConstants.style15600.copyWith(color: Pallete.dividerColor),
  ),
  dividerTheme: DividerThemeData(
    color: Pallete.dividerColor.withOpacity(.1),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: lightInputDecoration(),
    textStyle: StyleConstants.style14600.copyWith(color: Pallete.darkBg),
  ),

  // TEXT FIELD THEME
  inputDecorationTheme: lightInputDecoration(),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Pallete.grey05,
    selectionColor: Pallete.grey50,
    selectionHandleColor: Pallete.darkBg,
  ),
);

var darkTheme = ThemeData(
  // Define the default font family.
  fontFamily: 'sohne',
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColor: Pallete.darkBg,
  scaffoldBackgroundColor: Pallete.darkBg,
  drawerTheme: const DrawerThemeData(
    backgroundColor: Pallete.darkBg,
    scrimColor: Pallete.transparent,
    elevation: 4.0,
  ),

  unselectedWidgetColor: Pallete.dividerColor,

  splashColor: Pallete.darkBg.withOpacity(0.1),

  useMaterial3: true,
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 96.sp),
    displayMedium: TextStyle(fontSize: 72.sp),
    displaySmall: TextStyle(fontSize: 60.sp),
    headlineLarge: TextStyle(fontSize: 48.sp),
    headlineMedium: TextStyle(fontSize: 40.sp),
    headlineSmall: TextStyle(fontSize: 34.sp),
    titleLarge: TextStyle(fontSize: 38.sp),
    titleMedium: TextStyle(fontSize: 24.sp),
    titleSmall: TextStyle(fontSize: 20.sp),
    bodyLarge: TextStyle(fontSize: 18.sp),
    bodyMedium: TextStyle(fontSize: 16.sp),
    bodySmall: TextStyle(fontSize: 13.sp),
    labelSmall: TextStyle(fontSize: 10.sp),
  ).apply(
    fontFamily: 'sohne',
    bodyColor: Pallete.dividerColor,
    displayColor: Pallete.dividerColor,
    fontSizeFactor: 1.sp,
  ),

  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Pallete.dividerColor,
    onPrimary: Pallete.darkBg,
    primaryContainer: Pallete.grey05,
    onPrimaryContainer: Pallete.dividerColor,
    secondary: Pallete.grey05,
    onSecondary: Colors.white,
    secondaryContainer: Pallete.grey05,
    onSecondaryContainer: Colors.white,
    tertiary: Pallete.grey05,
    onTertiary: Colors.white,
    tertiaryContainer: Pallete.grey05,
    onTertiaryContainer: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    errorContainer: Colors.red,
    onErrorContainer: Colors.white,
    brightness: Brightness.dark,
    background: Colors.red,
    outline: Pallete.dividerColor,
    surface: Pallete.grey05,
    onSurface: Colors.white,
  ),

  listTileTheme: ListTileThemeData(
    titleTextStyle: StyleConstants.style15500.copyWith(color: Pallete.dividerColor),
  ),

  // BUTTON
  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.normal,
    buttonColor: Pallete.dividerColor,
    splashColor: Pallete.dividerColor.withOpacity(0.1),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      brightness: Brightness.dark,
      background: Colors.white,
      surface: Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100.0),
    ),
    height: 60.h,
    padding: EdgeInsets.symmetric(
      vertical: 14.h,
      horizontal: 20.w,
    ),
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Pallete.dividerColor,
  ),

  switchTheme: const SwitchThemeData(
    splashRadius: 15.0,
    trackColor: WidgetStatePropertyAll(Pallete.grey05),
    thumbColor: WidgetStatePropertyAll(Pallete.dividerColor),
    trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
  ),

  cardTheme: CardThemeData(
    elevation: 0.6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  // alert dialog
  dialogTheme: DialogThemeData(
    backgroundColor: Pallete.blackBG,
    shadowColor: Colors.black.withOpacity(0.8),
    actionsPadding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 28.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.r),
    ),
  ),

  iconTheme: const IconThemeData(
    color: Pallete.dividerColor,
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Pallete.darkBg,
  ),

  appBarTheme: const AppBarTheme(
    elevation: 0.0,
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Pallete.dividerColor,
    ),
    actionsIconTheme: IconThemeData(
      color: Pallete.dividerColor,
    ),
    iconTheme: IconThemeData(
      color: Pallete.dividerColor,
      size: 24,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Pallete.dividerColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        StyleConstants.style14500.copyWith(color: Pallete.darkBg),
      ),
    ),
  ),

  snackBarTheme: mySnackBarTheme(),
  checkboxTheme: darkCheckBoxTheme(),

  popupMenuTheme: PopupMenuThemeData(
    color: Pallete.dividerColor,
    position: PopupMenuPosition.over,
    textStyle: StyleConstants.style15600.copyWith(color: Pallete.darkBg),
  ),

  dividerTheme: const DividerThemeData(
    color: Pallete.grey05,
  ),

  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: darkInputDecoration(),
    textStyle: StyleConstants.style14600.copyWith(color: Pallete.dividerColor),
  ),

  // TEXT FIELD THEME
  inputDecorationTheme: darkInputDecoration(),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Pallete.grey05,
    selectionColor: Pallete.grey50,
    selectionHandleColor: Pallete.dividerColor,
  ),
);

//font weights
var thin = FontWeight.w100;
var extraLight = FontWeight.w200;
var light = FontWeight.w300;
var regular = FontWeight.w400;
var medium = FontWeight.w500;
var semiBold = FontWeight.w600;
var bold = FontWeight.w700;
var extraBold = FontWeight.w800;
var black = FontWeight.w900;

InputDecorationTheme lightInputDecoration([bool? isFocused]) {
  return InputDecorationTheme(
    // 28.w
    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
    fillColor: Pallete.grey9,
    filled: true,
    hintStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: Pallete.grey50,
    ),
    errorStyle: const TextStyle(color: Colors.red),
    labelStyle: const TextStyle(color: Colors.red),
    prefixStyle:
        // isFocused == true
        // ? TextStyle(color: primaryColor)
        // :
        const TextStyle(color: Colors.white),
    suffixStyle: const TextStyle(color: Colors.white),
    border: lightInputBorder(),
    enabledBorder: lightInputBorder(),
    focusedBorder: lightInputBorder(),
    errorBorder: myerrorborder(),
    focusedErrorBorder: lightFocusedErrorBorder(),
    disabledBorder: mydisabledborder(),
  );
}

InputDecorationTheme darkInputDecoration() {
  return InputDecorationTheme(
    // 28.w
    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
    fillColor: Pallete.grey05,
    filled: true,
    hintStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: Pallete.grey50,
    ),
    errorStyle: const TextStyle(color: Colors.red),
    labelStyle: const TextStyle(color: Colors.red),
    prefixStyle:
        // isFocused == true
        // ? TextStyle(color: primaryColor)
        // :
        const TextStyle(color: Colors.white),
    suffixStyle: const TextStyle(color: Colors.white),
    border: mydisabledborder(),

    enabledBorder: darkInputBorder(),
    focusedBorder: darkInputBorder(),
    errorBorder: myerrorborder(),
    focusedErrorBorder: darkFocusedErrorBorder(),
    disabledBorder: mydisabledborder(),
  );
}

//snackbar theme
SnackBarThemeData mySnackBarTheme() {
  return SnackBarThemeData(
    backgroundColor: Colors.white,
    contentTextStyle: const TextStyle(color: Colors.white),
    actionTextColor: Pallete.darkBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
  );
}

CheckboxThemeData lightCheckBoxTheme() {
  return CheckboxThemeData(
    fillColor: MaterialStateProperty.all(Pallete.grey4),
    checkColor: MaterialStateProperty.all(Pallete.darkBg),
    overlayColor: MaterialStateProperty.all(Pallete.backGround.withOpacity(0.1)),
    side: BorderSide.none,
    splashRadius: 15,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  );
}

CheckboxThemeData darkCheckBoxTheme() {
  return CheckboxThemeData(
    fillColor: MaterialStateProperty.all(Pallete.grey4),
    checkColor: MaterialStateProperty.all(Pallete.dividerColor),
    overlayColor: MaterialStateProperty.all(Pallete.backGround.withOpacity(0.1)),
    side: BorderSide.none,
    splashRadius: 15,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  );
}

// normal and enabled
OutlineInputBorder darkInputBorder() {
  //return type is OutlineInputBorder
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.r),
    borderSide: BorderSide(color: Pallete.white.withOpacity(.1), width: 1),
  );
}

OutlineInputBorder lightInputBorder() {
  //return type is OutlineInputBorder
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.r),
    borderSide: const BorderSide(color: Pallete.navBarGrey, width: 1),
  );
}

OutlineInputBorder mydisabledborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.r),
    borderSide: const BorderSide(color: Pallete.navBarGrey, width: 1),
  );
}

OutlineInputBorder myfocusborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.r),
    borderSide: const BorderSide(color: Pallete.navBarGrey, width: 1),
  );
}

OutlineInputBorder myerrorborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.r),
    borderSide: const BorderSide(color: Colors.red, width: 1),
  );
}

OutlineInputBorder darkFocusedErrorBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.r),
    borderSide: const BorderSide(color: Pallete.navBarGrey, width: 1),
  );
}

OutlineInputBorder lightFocusedErrorBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.r),
    borderSide: const BorderSide(color: Pallete.navBarGrey, width: 1),
  );
}
