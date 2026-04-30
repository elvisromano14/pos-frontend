class Almacen {
  const Almacen({
    required this.almacenId,
    required this.nombre,
    this.descripcion,
    this.direccion,
    required this.activo,
  });

  final int almacenId;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final bool activo;

  factory Almacen.fromJson(Map<String, dynamic> json) {
    return Almacen(
      almacenId: json['almacen_id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      direccion: json['direccion'] as String?,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'activo': activo,
    };
  }
}
