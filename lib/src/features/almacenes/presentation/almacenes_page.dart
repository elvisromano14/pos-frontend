import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/almacen_repository.dart';
import '../domain/almacen.dart';

final almacenesFutureProvider = FutureProvider.autoDispose<List<Almacen>>((ref) {
  final repo = ref.watch(almacenRepositoryProvider);
  return repo.fetchAlmacenes();
});

class AlmacenesPage extends ConsumerWidget {
  const AlmacenesPage({super.key});

  Future<void> _showFormDialog(BuildContext context, WidgetRef ref, [Almacen? almacen]) async {
    final isEditing = almacen != null;
    final nombreController = TextEditingController(text: almacen?.nombre ?? '');
    final descripcionController = TextEditingController(text: almacen?.descripcion ?? '');
    final direccionController = TextEditingController(text: almacen?.direccion ?? '');
    bool isActivo = almacen?.activo ?? true;
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Almacén' : 'Nuevo Almacén'),
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
                        controller: direccionController,
                        decoration: const InputDecoration(labelText: 'Dirección'),
                      ),
                      TextFormField(
                        controller: direccionController,
                        decoration: const InputDecoration(labelText: 'Dirección'),
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
                                'direccion': direccionController.text.trim(),
                                'activo': isActivo,
                              };
                              if (isEditing) {
                                await ref.read(almacenRepositoryProvider).updateAlmacen(almacen.almacenId, data);
                              } else {
                                await ref.read(almacenRepositoryProvider).createAlmacen(data);
                              }
                              ref.invalidate(almacenesFutureProvider);
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Almacen almacen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Almacén'),
        content: Text('¿Está seguro de que desea eliminar "${almacen.nombre}"?'),
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
        await ref.read(almacenRepositoryProvider).deleteAlmacen(almacen.almacenId);
        ref.invalidate(almacenesFutureProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAlmacenes = ref.watch(almacenesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(almacenesFutureProvider),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: asyncAlmacenes.when(
        data: (almacenes) {
          if (almacenes.isEmpty) {
            return const Center(child: Text('No hay almacenes registrados.'));
          }
          return ListView.builder(
            itemCount: almacenes.length,
            itemBuilder: (context, index) {
              final almacen = almacenes[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.store)),
                title: Text(almacen.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(almacen.descripcion ?? 'Sin descripción'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: almacen.activo,
                      onChanged: null,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showFormDialog(context, ref, almacen);
                        } else if (value == 'delete') {
                          _confirmDelete(context, ref, almacen);
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
