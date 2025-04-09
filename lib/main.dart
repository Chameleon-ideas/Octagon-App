import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:octagon/screen/splash_screen.dart';
import 'package:octagon/screen/sport/sport_selection_screen.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/firebase_helper.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:resize/resize.dart';
import 'package:sizer/sizer.dart';

GetStorage storage = GetStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initFirebaseNotifications();
  await GetStorage.init();
  storage = GetStorage();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor, // status bar color
      statusBarIconBrightness: statusBarBrightness,
      statusBarBrightness: Brightness.dark // status bar icon color
      ));
  runApp(
      ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier(), child: Consumer<ThemeNotifier>(builder: (_, model, __) => MyApp(model))));
}

class MyApp extends StatefulWidget {
  final ThemeNotifier model;

  const MyApp(this.model, {Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin = false;
  bool isSportsSelected = false;

  @override
  void initState() {
    super.initState();
    isSportsSelected = storage.read(sportInfo) != null;
    if (storage.read("current_uid") != null && "${storage.read("current_uid")}".isNotEmpty) {
      setState(() {
        isLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, _, deviceType) {
      return Resize(builder: () {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          // navigatorKey: _navigatorKey,
          title: 'Octagon',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: isLogin
              ? isSportsSelected
                  ? TabScreen()
                  : SportSelection()
              : const SplashScreen(),
        );
      });
    });
  }
}
