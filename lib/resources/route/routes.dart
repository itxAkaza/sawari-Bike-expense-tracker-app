import 'package:get/get.dart';
import 'package:sawari/resources/route/routes_names.dart';

import '../../screens/authentication/loginScreen.dart';
import '../../screens/authentication/registerScreen.dart';
import '../../screens/homeBottomBarScreen/homeBottomBarScreen.dart';




class AppRoutes {
  static List<GetPage> appRoutes() => [
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
      name: RoutesNames.homeBottomBarScreen,
      page: () => const HomeBottomBarScreen(),
      transition: Transition.fadeIn,
    ),

  ];
}