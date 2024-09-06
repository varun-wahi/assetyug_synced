import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:flutter/material.dart';

ThemeData lightThemeData = ThemeData(
        // primarySwatch: Colors.indigo,

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: tBlack,
          onPrimary: tWhite,
          secondary:tPrimary,
          onSecondary: tWhite,
          error: tRed,
          onError: tRed,
          // : ,
          // surface: Color.fromARGB(255, 0, 19, 29),
          surface: tWhite,
          onSurface: tPrimary,
        ),

        //Bottom Navigation Bar ThemeData
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 2,
          showUnselectedLabels: true,
          backgroundColor: darkGrey,
          selectedIconTheme: IconThemeData(color: tBlack, size: 30),
          selectedLabelStyle: TextStyle(color: tBlack),
          unselectedIconTheme: IconThemeData(color: lighterGrey),
          unselectedLabelStyle: TextStyle(color: lighterGrey),
        ),

        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(dBorderRadius),
        radius: const Radius.circular(dBorderRadius),
        
        interactive: true,
        ),

        //Divider Theme
        dividerTheme:
            const DividerThemeData(color: lighterGrey, space: 5, thickness: 2),

        //AppBar Theme'
        appBarTheme: AppBarTheme(
          titleTextStyle: boldHeading(),
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 60,
          iconTheme: const IconThemeData(color: tBlack),
          actionsIconTheme: const IconThemeData(color: tBlack),
          backgroundColor: tBackground,
          scrolledUnderElevation: 0
        ),

        //TextTheme
        textTheme: const TextTheme(
          bodySmall:
              TextStyle(color: tBlack), // Default text color for bodyText1
          bodyMedium:
              TextStyle(color: tBlack), // Default text color for bodyText2
          // You can define other text styles here as well
          displayLarge: TextStyle(color: Colors.green),
          displayMedium: TextStyle(color: Colors.green),
          // Continue for other text styles...
        ),

        //ElevatedButton Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: tPrimary,
                foregroundColor: tWhite,
                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dBorderRadius))
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(dBorderRadius * 2)))),
      );
  
