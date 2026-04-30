class Categoria {
  const Categoria({
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final bool activo;

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      categoriaId: json['categoria_id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
