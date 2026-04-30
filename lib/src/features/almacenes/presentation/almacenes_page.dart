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

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final direccionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo Almacén'),
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
                              await ref.read(almacenRepositoryProvider).createAlmacen({
                                'nombre': nombreController.text.trim(),
                                'descripcion': descripcionController.text.trim(),
                                'direccion': direccionController.text.trim(),
                                'activo': true,
                              });
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
                trailing: Switch(
                  value: almacen.activo,
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
