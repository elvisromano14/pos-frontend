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

  Future<void> _showFormDialog(BuildContext context, WidgetRef ref, [Categoria? categoria]) async {
    final isEditing = categoria != null;
    final nombreController = TextEditingController(text: categoria?.nombre ?? '');
    final descripcionController = TextEditingController(text: categoria?.descripcion ?? '');
    bool isActivo = categoria?.activo ?? true;
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
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
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                      ),
                      SwitchListTile(
                        title: const Text('Activo'),
                        value: isActivo,
                        onChanged: (val) => setState(() => isActivo = val),
                        contentPadding: EdgeInsets.zero,
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
                              final data = {
                                'nombre': nombreController.text.trim(),
                                'descripcion': descripcionController.text.trim(),
                                'activo': isActivo,
                              };
                              if (isEditing) {
                                await ref.read(categoriaRepositoryProvider).updateCategoria(categoria.categoriaId, data);
                              } else {
                                await ref.read(categoriaRepositoryProvider).createCategoria(data);
                              }
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Categoria categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text('¿Está seguro de que desea eliminar "${categoria.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(categoriaRepositoryProvider).deleteCategoria(categoria.categoriaId);
        ref.invalidate(categoriasFutureProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: categoria.activo,
                      onChanged: null,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showFormDialog(context, ref, categoria);
                        } else if (value == 'delete') {
                          _confirmDelete(context, ref, categoria);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
