import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../categorias/data/categoria_repository.dart';
import '../data/articulo_repository.dart';
import '../domain/articulo.dart';

final articulosFutureProvider = FutureProvider.autoDispose<List<Articulo>>((ref) {
  final repo = ref.watch(articuloRepositoryProvider);
  return repo.fetchArticulos();
});

class ArticulosPage extends ConsumerWidget {
  const ArticulosPage({super.key});

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final codigoController = TextEditingController();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioController = TextEditingController(text: '0.0');
    int? selectedCategoriaId;
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    // Load categories for the dropdown
    final categorias = await ref.read(categoriaRepositoryProvider).fetchCategorias();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo Artículo'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: codigoController,
                        decoration: const InputDecoration(labelText: 'Código *'),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre *'),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Categoría *'),
                        value: selectedCategoriaId,
                        items: categorias.map((cat) {
                          return DropdownMenuItem(value: cat.categoriaId, child: Text(cat.nombre));
                        }).toList(),
                        onChanged: (val) => setState(() => selectedCategoriaId = val),
                        validator: (value) => value == null ? 'Seleccione una categoría' : null,
                      ),
                      TextFormField(
                        controller: precioController,
                        decoration: const InputDecoration(labelText: 'Precio Base'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            try {
                              await ref.read(articuloRepositoryProvider).createArticulo({
                                'codigo': codigoController.text.trim(),
                                'nombre': nombreController.text.trim(),
                                'descripcion': descripcionController.text.trim(),
                                'categoria_id': selectedCategoriaId,
                                'precio_base': double.tryParse(precioController.text) ?? 0.0,
                                'costo_promedio': 0.0,
                                'unidad_medida': 'UNIDAD',
                                'aplica_iva': true,
                                'aplica_igtf': false,
                                'activo': true,
                              });
                              ref.invalidate(articulosFutureProvider);
                              if (context.mounted) Navigator.of(context).pop();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            } finally {
                              if (context.mounted) setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncArticulos = ref.watch(articulosFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(articulosFutureProvider),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: asyncArticulos.when(
        data: (articulos) {
          if (articulos.isEmpty) {
            return const Center(child: Text('No hay artículos registrados.'));
          }
          return ListView.builder(
            itemCount: articulos.length,
            itemBuilder: (context, index) {
              final articulo = articulos[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.inventory, color: Colors.white),
                ),
                title: Text('${articulo.codigo} - ${articulo.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Precio: \$${articulo.precioBase.toStringAsFixed(2)}'),
                trailing: Switch(
                  value: articulo.activo,
                  onChanged: null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
