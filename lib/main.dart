import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app_states/app_settings.dart';
import 'constants/app_colors.dart';
import 'navigation/navigation_manager.dart';
import 'navigation/navigation_route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Get.put(AppSettings(), permanent: true);
  await AppSettings.instance.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<NavigationService>(create: (_) => NavigationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme baseTextTheme = GoogleFonts.beVietnamProTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface);
    final TextTheme textTheme = baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.beVietnamPro(
        color: AppColors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.beVietnamPro(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: GoogleFonts.beVietnamPro(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: GoogleFonts.beVietnamPro(
        color: AppColors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: GoogleFonts.beVietnamPro(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: GoogleFonts.beVietnamPro(
        color: AppColors.outline,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Native Live Interpreter',
          debugShowCheckedModeBanner: false,
          navigatorKey: AppSettings.instance.navigatorKey,
          onGenerateRoute: NavigationRoute().generateRoute,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme(
              brightness: Brightness.dark,
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              secondary: AppColors.primaryContainer,
              onSecondary: AppColors.onPrimary,
              error: AppColors.error,
              onError: AppColors.onError,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
            textTheme: textTheme,
            iconTheme: IconThemeData(color: AppColors.onSurface),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                foregroundColor: AppColors.onPrimary,
                textStyle: textTheme.labelLarge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                textStyle: textTheme.labelLarge,
                side: BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(foregroundColor: AppColors.onSurface),
            ),
          ),
        );
      },
    );
  }
}
