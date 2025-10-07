import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData get theme => AppTheme.theme;

double get flexSpacing => 16.0; // Default spacing

int get flexColumns => 12; // Default columns for responsive grid

class MaterialRadius {
  double xs, small, medium, large;

  MaterialRadius(
      {this.xs = 2, this.small = 4, this.medium = 6, this.large = 8});
}

class ColorGroup {
  final Color color, onColor;

  ColorGroup(this.color, this.onColor);
}

class AppTheme {
  static ThemeData theme = AppTheme.getThemeFromThemeMode();
  static TextDirection textDirection = TextDirection.ltr;

  static Color primaryColor = Color(0xff275AC5);

  static ThemeData getThemeFromThemeMode() {
    return lightTheme; // Default to light theme for now
  }

  /// -------------------------- Light Theme  -------------------------------------------- ///

  static final ThemeData lightTheme = ThemeData(
    /// Brightness
    brightness: Brightness.light,
    useMaterial3: false,

    /// Primary Color
    primaryColor: AppTheme.primaryColor,

    /// Scaffold and Background color
    scaffoldBackgroundColor: Color(0xffF5F5F5),
    canvasColor: Colors.transparent,

    /// AppBar Theme
    appBarTheme: AppBarTheme(
        backgroundColor: Color(0xffF5F5F5),
        iconTheme: IconThemeData(color: Color(0xff495057)),
        actionsIconTheme: IconThemeData(color: Color(0xff495057))),

    /// Card Theme
    cardTheme: CardThemeData(color: Color(0xffffffff)),
    cardColor: Color(0xffffffff),

    /// Colorscheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xff275AC5),
      brightness: Brightness.light,
    ),

    snackBarTheme: SnackBarThemeData(actionTextColor: Colors.white),

    /// Floating Action Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppTheme.primaryColor,
        splashColor: Color(0xffeeeeee).withAlpha(100),
        highlightElevation: 8,
        elevation: 4,
        focusColor: AppTheme.primaryColor,
        hoverColor: AppTheme.primaryColor,
        foregroundColor: Color(0xffeeeeee)),

    /// Divider Theme
    dividerTheme: DividerThemeData(color: Color(0xffdddddd), thickness: 1),
    dividerColor: Color(0xffdddddd),

    /// Bottom AppBar Theme
    bottomAppBarTheme:
        BottomAppBarThemeData(color: Color(0xffeeeeee), elevation: 2),

    /// Tab bar Theme
    tabBarTheme: TabBarThemeData(
      unselectedLabelColor: Color(0xff495057),
      labelColor: AppTheme.primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2.0),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(),

    /// Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppTheme.primaryColor,
      inactiveTrackColor: AppTheme.primaryColor.withAlpha(140),
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      thumbColor: AppTheme.primaryColor,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      inactiveTickMarkColor: Colors.red[100],
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: Color(0xffeeeeee),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      checkColor: WidgetStateProperty.all(Color(0xffffffff)),
      fillColor: WidgetStateProperty.all(AppTheme.primaryColor),
    ),
    switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppTheme.primaryColor
                : Colors.white)),

    /// Other Colors
    splashColor: Colors.white.withAlpha(100),
    indicatorColor: Color(0xffeeeeee),
    highlightColor: Color(0xffeeeeee),
  );

  /// -------------------------- Dark Theme  -------------------------------------------- ///
  static final ThemeData darkTheme = ThemeData.dark(
    useMaterial3: false,
  ).copyWith(
    /// Brightness

    /// Scaffold and Background color
    scaffoldBackgroundColor: Color(0xff262729),
    canvasColor: Colors.transparent,

    primaryColor: Color(0xff275AC5),

    /// AppBar Theme
    appBarTheme: AppBarTheme(backgroundColor: Color(0xff262729)),

    /// Card Theme
    cardTheme: CardThemeData(color: Color(0xff1b1b1c)),
    cardColor: Color(0xff1b1b1c),

    /// Colorscheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xff275AC5),
      surface: Color(0xff262729),
      onSurface: Color(0xFFD7D7D7),
      brightness: Brightness.dark,
    ),

    /// Input (Text-Field) Theme
    inputDecorationTheme: InputDecorationTheme(),

    /// Divider Color
    dividerTheme: DividerThemeData(color: Color(0xff393A41), thickness: 1),
    dividerColor: Color(0xff393A41),

    /// Floating Action Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppTheme.primaryColor,
        splashColor: Colors.white.withAlpha(100),
        highlightElevation: 8,
        elevation: 4,
        focusColor: AppTheme.primaryColor,
        hoverColor: AppTheme.primaryColor,
        foregroundColor: Colors.white),

    /// Bottom AppBar Theme
    bottomAppBarTheme:
        BottomAppBarThemeData(color: Color(0xff464c52), elevation: 2),

    /// Tab bar Theme
    tabBarTheme: TabBarThemeData(
      unselectedLabelColor: Color(0xff495057),
      labelColor: AppTheme.primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2.0),
      ),
    ),

    /// Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppTheme.primaryColor,
      inactiveTrackColor: AppTheme.primaryColor.withAlpha(100),
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      thumbColor: AppTheme.primaryColor,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      inactiveTickMarkColor: Colors.red[100],
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),

    ///Other Color
    indicatorColor: Colors.white,
    disabledColor: Color(0xffa3a3a3),
    highlightColor: Color(0xff47484b),
    splashColor: Colors.white.withAlpha(100),
  );

  static ThemeData createTheme(ThemeMode themeType, Color seedColor) {
    if (themeType == ThemeMode.light) {
      return lightTheme.copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor, brightness: Brightness.light));
    }
    return darkTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
            onSurface: Color(0xFFDAD9CA)));
  }
}

class AppColors {
  static final Color star = Color(0xffFFC233);
  static Color ratingStarColor = Color(0xFFF9A825);
  static Color success = Color(0xff1abc9c);

  static ColorGroup pink = ColorGroup(Color(0xffFFC2D9), Color(0xffF5005E));
  static ColorGroup violet = ColorGroup(Color(0xffD0BADE), Color(0xff4E2E60));

  static ColorGroup blue = ColorGroup(Color(0xffADD8FF), Color(0xff004A8F));
  static ColorGroup green = ColorGroup(Color(0xffAFE9DA), Color(0xff165041));
  static ColorGroup orange = ColorGroup(Color(0xffFFCEC2), Color(0xffFF3B0A));
  static ColorGroup skyBlue = ColorGroup(Color(0xffC2F0FF), Color(0xff0099CC));
  static ColorGroup lavender = ColorGroup(Color(0xffEAE2F3), Color(0xff7748AD));
  static ColorGroup queenPink =
      ColorGroup(Color(0xffE8D9DC), Color(0xff804D57));
  static ColorGroup blueViolet =
      ColorGroup(Color(0xffC5C6E7), Color(0xff3B3E91));
  static ColorGroup rosePink = ColorGroup(Color(0xffFCB1E0), Color(0xffEC0999));

  static ColorGroup rubinRed = ColorGroup(Color(0x98f6a8bd), Color(0xffd03760));
  static ColorGroup favorite = rubinRed;
  static ColorGroup redOrange =
      ColorGroup(Color(0xffFFAD99), Color(0xffF53100));

  static Color notificationSuccessBGColor = Color(0xff117E68);
  static Color notificationSuccessTextColor = Color(0xffffffff);
  static Color notificationSuccessActionColor = Color(0xffFFE815);

  static Color notificationErrorBGColor = Color(0xfffcd9df);
  static Color notificationErrorTextColor = Color(0xffFF3B0A);
  static Color notificationErrorActionColor = Color(0xff006784);

  static List<ColorGroup> list = [
    redOrange,
    violet,
    blue,
    green,
    orange,
    skyBlue,
    lavender,
    blueViolet
  ];

  static ColorGroup get random => list[Random().nextInt(list.length)];

  static ColorGroup get(int index) {
    return list[index % list.length];
  }

  static Color getColorByRating(int rating) {
    var colors = {
      1: Color(0xfff0323c),
      2: Color(0xcdf0323c),
      3: star,
      4: Color(0xcd3cd278),
      5: Color(0xff3cd278)
    };

    return colors[rating] ?? colors[1]!;
  }

  AppColors() {
    list.addAll([pink, violet, blue, green, orange]);
  }
}

// Content theme for various UI states
class ContentTheme {
  static const Color primary = Color(0xff275AC5);
  static const Color secondary = Color(0xff6c757d);
  static const Color success = Color(0xff198754);
  static const Color danger = Color(0xffdc3545);
  static const Color warning = Color(0xffffc107);
  static const Color info = Color(0xff0dcaf0);
  static const Color light = Color(0xfff8f9fa);
  static const Color dark = Color(0xff212529);

  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onSuccess = Colors.white;
  static const Color onDanger = Colors.white;
  static const Color onWarning = Color(0xff212529);
  static const Color onInfo = Colors.white;
  static const Color onLight = Color(0xff212529);
  static const Color onDark = Colors.white;
}

ContentTheme get contentTheme => ContentTheme();
