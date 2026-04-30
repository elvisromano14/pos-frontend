import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';

class AuthTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String token) => state = token;
  void clearToken() => state = null;
}

final authTokenProvider = NotifierProvider<AuthTokenNotifier, String?>(AuthTokenNotifier.new);

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<String> login({
    required String username,
    required String password,
    required String tenantSchema,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: <String, dynamic>{
        'username': username,
        'password': password,
        'tenant_schema': tenantSchema,
      },
    );
    return response.data?['access_token'] as String? ?? '';
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);
