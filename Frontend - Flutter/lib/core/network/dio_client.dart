import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:services_ai_app/global_constant.dart';
import '../storage/secure_storage.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: '${GlobalConstant.backendUrl}/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String message = 'An unexpected error occurred';
        if (e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('message')) {
            message = data['message'].toString();
          } else {
            message = e.response?.statusMessage ?? message;
          }
        } else {
          message = e.message ?? message;
        }

        Fluttertoast.showToast(msg: message);
        return handler.next(e);
      },
    ),
  );

  return dio;
}
