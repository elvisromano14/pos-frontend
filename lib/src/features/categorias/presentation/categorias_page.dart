import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/categoria_repository.dart';
import '../domain/categoria.dart';

final categoriasFutureProvider = FutureProvider.autoDispose<List<Categoria>>((ref) {
  final repo = ref.watch(categoriaRepositoryProvider);
  return repo.fetchCategorias();
});

class CategoriasPage extends ConsumerWidget {
  const CategoriasPage({super.key});

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Categoría'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre *'),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
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
                              await ref.read(categoriaRepositoryProvider).createCategoria({
                                'nombre': nombreController.text.trim(),
                                'descripcion': descripcionController.text.trim(),
                                'activo': true,
                              });
                              ref.invalidate(categoriasFutureProvider);
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
    final asyncCategorias = ref.watch(categoriasFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(categoriasFutureProvider),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: asyncCategorias.when(
        data: (categorias) {
          if (categorias.isEmpty) {
            return const Center(child: Text('No hay categorías registradas.'));
          }
          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.category, color: Colors.white),
                ),
                title: Text(categoria.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(categoria.descripcion ?? 'Sin descripción'),
                trailing: Switch(
                  value: categoria.activo,
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
