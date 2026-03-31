import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'app_states/app_settings.dart';
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
            fontFamily: 'SF Pro Display',
            scaffoldBackgroundColor: AppSettings.instance.appearance.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppSettings.instance.appearance.primary,
              brightness: Brightness.dark,
            ),
          ),
        );
      },
    );
  }
}
