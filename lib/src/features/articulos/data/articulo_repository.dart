import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../domain/articulo.dart';

class ArticuloRepository {
  ArticuloRepository(this._dio);
  final Dio _dio;

  Future<List<Articulo>> fetchArticulos() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/articulos');
    return response.data!
        .map((dynamic json) => Articulo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Articulo> createArticulo(Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/v1/articulos', data: data);
    return Articulo.fromJson(response.data!);
  }
}

final articuloRepositoryProvider = Provider<ArticuloRepository>((ref) {
  return ArticuloRepository(ref.watch(dioProvider));
});
