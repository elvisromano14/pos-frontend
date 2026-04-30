class Articulo {
  const Articulo({
    required this.articuloId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.categoriaId,
    required this.unidadMedida,
    required this.costoPromedio,
    required this.precioBase,
    required this.aplicaIva,
    required this.aplicaIgtf,
    required this.activo,
  });

  final int articuloId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int categoriaId;
  final String unidadMedida;
  final double costoPromedio;
  final double precioBase;
  final bool aplicaIva;
  final bool aplicaIgtf;
  final bool activo;

  factory Articulo.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Articulo(
      articuloId: json['articulo_id'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      categoriaId: json['categoria_id'] as int,
      unidadMedida: json['unidad_medida'] as String,
      costoPromedio: parseDouble(json['costo_promedio']),
      precioBase: parseDouble(json['precio_base']),
      aplicaIva: json['aplica_iva'] as bool,
      aplicaIgtf: json['aplica_igtf'] as bool,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articulo_id': articuloId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'unidad_medida': unidadMedida,
      'costo_promedio': costoPromedio,
      'precio_base': precioBase,
      'aplica_iva': aplicaIva,
      'aplica_igtf': aplicaIgtf,
      'activo': activo,
    };
  }
}
