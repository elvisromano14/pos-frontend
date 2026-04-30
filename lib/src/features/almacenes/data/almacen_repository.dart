import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../domain/almacen.dart';

class AlmacenRepository {
  AlmacenRepository(this._dio);
  final Dio _dio;

  Future<List<Almacen>> fetchAlmacenes() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/almacenes');
    return response.data!
        .map((dynamic json) => Almacen.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Almacen> createAlmacen(Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/v1/almacenes', data: data);
    return Almacen.fromJson(response.data!);
  }

  Future<Almacen> updateAlmacen(int id, Map<String, dynamic> data) async {
    final response = await _dio.put<Map<String, dynamic>>('/api/v1/almacenes/$id', data: data);
    return Almacen.fromJson(response.data!);
  }

  Future<void> deleteAlmacen(int id) async {
    await _dio.delete<dynamic>('/api/v1/almacenes/$id');
  }
}

final almacenRepositoryProvider = Provider<AlmacenRepository>((ref) {
  return AlmacenRepository(ref.watch(dioProvider));
});
