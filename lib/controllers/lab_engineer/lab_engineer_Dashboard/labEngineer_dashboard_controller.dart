// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:texops/Utiles/utiles.dart';
//
// import '../../../data/fireStoreDB/labEnginner/dashboard_data.dart';
// import '../../../services/notifiction_service.dart';
//
//
// class LabEngineerController extends GetxController {
//   var isLoading = true.obs;
//
//
//   var userName = 'Loading...'.obs;
//   var userRole = 'Lab Engineer'.obs;
//   var userProfilePic = ''.obs;
//   var userEmail = ''.obs;
//   var totalSystemValue = 0.0.obs;
//
//
//   var recentBales = <Map<String, dynamic>>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDashboardData();
//
//     NotificationServices ns = NotificationServices();
//     ns.initializeAll();
//   }
//
//   Future<void> fetchDashboardData() async {
//     isLoading.value = true;
//     try {
//
//       final userData = await LabEngineerFirebaseService.getUserProfile();
//       if (userData != null)
//       {
//         userName.value = userData['name'] ?? 'Unknown User';
//         userRole.value = userData['role'] ?? 'Lab Engineer';
//         userProfilePic.value = userData['profilePic'] ?? '';
//         userEmail.value=userData["generatedEmail"] ?? "";
//
//         totalSystemValue.value = (userData['totalBalesAmount'] ?? 0.0).toDouble();
//
//       }
//
//
//       final bales = await LabEngineerFirebaseService.getRecentBales();
//       recentBales.assignAll(bales);
//
//
//     } catch (e)
//     {
//       Utils.toastMesseges(e.toString());
//     } finally
//     {
//       isLoading.value = false;
//     }
//   }
//
//
//   String getCurrentQuarter()
//   {
//     int month = DateTime.now().month;
//     int year = DateTime.now().year;
//     int quarter = ((month - 1) / 3).floor() + 1;
//     return "This Quarter (Q$quarter $year)";
//   }
//
//   double calculateGatePassTotal(Map<String, dynamic> bale)
//   {
//     double price = double.tryParse(bale['price']?.toString() ?? '0') ?? 0.0;
//     return price;
//   }
//
//
// }