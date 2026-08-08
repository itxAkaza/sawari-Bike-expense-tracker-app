import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  final Dio _dio = Dio();

  final String cloudName = "lpbilldt";
  final String uploadPreset = "mabdullah-sawari";

  Future<String?> uploadImage(File file) async {
    try {
      String url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      FormData data = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
        "upload_preset": uploadPreset,
      });

      final response = await _dio.post(
        url,
        data: data,
        // Add a timeout so it doesn't hang forever if the internet is weak
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }

      return null;
    } on DioException catch (e) {
      // Dio successfully detects if this is an internet/connection issue
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception("network_error");
      }
      // If it's a different Dio error (e.g., Cloudinary rejected the request)
      throw Exception("upload_failed");
    } catch (e) {
      // Catch any other unexpected formatting or system errors
      throw Exception("upload_failed");
    }
  }
}