import 'package:flutter/material.dart';


class AppTheme {

  AppTheme._();



  static const Color seed =
      Color(0xFF7C4DFF);



  static final ThemeData dark =
      ThemeData(

    useMaterial3: true,

    brightness:
        Brightness.dark,



    colorScheme:
        ColorScheme.fromSeed(

      seedColor:
          seed,

      brightness:
          Brightness.dark,

    ),



    scaffoldBackgroundColor:
        const Color(0xFF0F0F0F),




    appBarTheme:
        const AppBarTheme(

      elevation:
          0,

      backgroundColor:
          Colors.transparent,

      foregroundColor:
          Colors.white,

      centerTitle:
          false,

      titleTextStyle:
          TextStyle(

        fontSize:
            26,

        fontWeight:
            FontWeight.w700,

        color:
            Colors.white,

      ),

    ),




    cardTheme:
        CardThemeData(

      elevation:
          0,

      color:
          const Color(0xFF1A1A1A),

      margin:
          EdgeInsets.zero,

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
              22,
            ),

      ),

    ),




    listTileTheme:
        const ListTileThemeData(

      iconColor:
          Colors.white70,

      textColor:
          Colors.white,

      contentPadding:
          EdgeInsets.symmetric(
            horizontal: 16,
          ),

    ),





    navigationBarTheme:
        NavigationBarThemeData(

      height:
          72,

      backgroundColor:
          const Color(0xFF151515),


      indicatorColor:
          seed.withValues(
            alpha: 0.25,
          ),



      labelTextStyle:
          const WidgetStatePropertyAll(

        TextStyle(

          fontWeight:
              FontWeight.w600,

          fontSize:
              12,

        ),

      ),

    ),




    filledButtonTheme:
        FilledButtonThemeData(

      style:
          FilledButton.styleFrom(

        padding:
            const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 14,
            ),

        shape:
            RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(
                30,
              ),

        ),

      ),

    ),




    inputDecorationTheme:
        InputDecorationTheme(

      filled:
          true,


      fillColor:
          const Color(0xFF202020),



      border:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
              18,
            ),

        borderSide:
            BorderSide.none,

      ),

    ),




    snackBarTheme:
        SnackBarThemeData(

      behavior:
          SnackBarBehavior.floating,


      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
              18,
            ),

      ),

    ),


  );

}