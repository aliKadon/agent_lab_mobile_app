import 'package:agent_lab/common/widgets/ui/app_snack.dart';
import 'package:agent_lab/screens/main_nav_screen.dart';
import 'package:agent_lab/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final designSize = _getDesignSize(constraints.maxWidth);
        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          builder: (context, child) {
            final theme = AppTheme.dark();
            return MaterialApp(
              title: 'Agent Lab',
              theme: theme,
              darkTheme: theme,
              themeMode: ThemeMode.dark,
              scaffoldMessengerKey: rootMessengerKey,
              home: const MainNavScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}

Size _getDesignSize(double maxWidth) {
  return maxWidth > 600 ? const Size(768, 1024) : const Size(430, 932);
}
