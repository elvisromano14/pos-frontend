class Inventario {
  const Inventario({
    required this.inventarioId,
    required this.articuloId,
    required this.almacenId,
    required this.existencia,
    required this.ultimaActualizacion,
  });

  final int inventarioId;
  final int articuloId;
  final int almacenId;
  final double existencia;
  final DateTime ultimaActualizacion;

  factory Inventario.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Inventario(
      inventarioId: json['inventario_id'] as int,
      articuloId: json['articulo_id'] as int,
      almacenId: json['almacen_id'] as int,
      existencia: parseDouble(json['existencia']),
      ultimaActualizacion: json['ultima_actualizacion'] != null 
          ? DateTime.parse(json['ultima_actualizacion'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventario_id': inventarioId,
      'articulo_id': articuloId,
      'almacen_id': almacenId,
      'existencia': existencia,
    };
  }
}
