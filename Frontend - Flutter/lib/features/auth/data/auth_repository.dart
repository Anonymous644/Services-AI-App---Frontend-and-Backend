import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorage _secureStorage;

  AuthRepository(this._dio, this._secureStorage);

  Future<User?> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      await _secureStorage.saveToken(data['accessToken']);
      return User.fromJson(data['user']);
    }
    return null;
  }

  Future<User?> signup(Map<String, dynamic> signupData) async {
    final response = await _dio.post('/auth/signup', data: signupData);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = response.data;
      await _secureStorage.saveToken(data['accessToken']);
      return User.fromJson(data['user']);
    }
    return null;
  }

  Future<User?> getMe() async {
    final token = await _secureStorage.getToken();
    if (token == null) return null;

    try {
      final response = await _dio.get('/auth/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
    } catch (e) {
      // Dio interceptor handles errors globally
      return null;
    }
    return null;
  }

  Future<User?> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await _dio.patch('/auth/me', data: body);
    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, secureStorage);
}
