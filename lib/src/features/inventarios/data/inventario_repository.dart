import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../domain/inventario.dart';

class InventarioRepository {
  InventarioRepository(this._dio);
  final Dio _dio;

  Future<List<Inventario>> fetchInventarios() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/inventarios');
    return response.data!
        .map((dynamic json) => Inventario.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Inventario> createInventario(Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/v1/inventarios', data: data);
    return Inventario.fromJson(response.data!);
  }
}

final inventarioRepositoryProvider = Provider<InventarioRepository>((ref) {
  return InventarioRepository(ref.watch(dioProvider));
});
