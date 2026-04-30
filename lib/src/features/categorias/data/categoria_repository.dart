import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../domain/categoria.dart';

class CategoriaRepository {
  CategoriaRepository(this._dio);
  final Dio _dio;

  Future<List<Categoria>> fetchCategorias() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/categorias');
    return response.data!
        .map((dynamic json) => Categoria.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Categoria> createCategoria(Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/v1/categorias', data: data);
    return Categoria.fromJson(response.data!);
  }

  Future<Categoria> updateCategoria(int id, Map<String, dynamic> data) async {
    final response = await _dio.put<Map<String, dynamic>>('/api/v1/categorias/$id', data: data);
    return Categoria.fromJson(response.data!);
  }

  Future<void> deleteCategoria(int id) async {
    await _dio.delete<dynamic>('/api/v1/categorias/$id');
  }
}

final categoriaRepositoryProvider = Provider<CategoriaRepository>((ref) {
  return CategoriaRepository(ref.watch(dioProvider));
});
