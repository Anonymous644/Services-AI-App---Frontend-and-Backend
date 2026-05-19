import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/user.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() async {
    return await ref.read(authRepositoryProvider).getMe();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email, password);
      if (user == null) {
        throw Exception('Login failed. Invalid credentials.');
      }
      return user;
    });
  }

  Future<void> signup(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).signup(data);
      if (user == null) {
        throw Exception('Signup failed. Please try again.');
      }
      return user;
    });
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    bool? isActive,
  }) async {
    state = await AsyncValue.guard(() async {
      final updated = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            bio: bio,
            isActive: isActive,
          );
      if (updated == null) throw Exception('Update failed');
      return updated;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}
