import 'package:get/get.dart';
import 'package:sawari/resources/route/routes_names.dart';

import '../../screens/alerts/alertScreen.dart';
import '../../screens/authentication/loginScreen.dart';
import '../../screens/authentication/registerScreen.dart';
import '../../screens/homeBottomBarScreen/homeBottomBarScreen.dart';
import '../../screens/intro/intro_screen.dart';


class AppRoutes {
  static List<GetPage> appRoutes() => [
    GetPage(
      name: RoutesNames.introScreen,
      page: () => const IntroScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: RoutesNames.loginScreen,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: RoutesNames.registerScreen,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: RoutesNames.homeBottomBarScreen,
      page: () => const HomeBottomBarScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RoutesNames.alertScreen, // Fixed typo!
      page: () => const AlertScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}