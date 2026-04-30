import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../almacenes/data/almacen_repository.dart';
import '../../almacenes/presentation/almacenes_page.dart';
import '../../articulos/data/articulo_repository.dart';
import '../../articulos/presentation/articulos_page.dart';
import '../data/inventario_repository.dart';
import '../domain/inventario.dart';

final inventariosFutureProvider = FutureProvider.autoDispose<List<Inventario>>((ref) {
  final repo = ref.watch(inventarioRepositoryProvider);
  return repo.fetchInventarios();
});

class InventariosPage extends ConsumerWidget {
  const InventariosPage({super.key});

  Future<void> _showFormDialog(BuildContext context, WidgetRef ref, [Inventario? inventario]) async {
    final isEditing = inventario != null;
    int? selectedArticuloId = inventario?.articuloId;
    int? selectedAlmacenId = inventario?.almacenId;
    final existenciaController = TextEditingController(text: inventario?.existencia.toString() ?? '0.0');
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    // Load articulos and almacenes for the dropdowns
    final articulos = await ref.read(articuloRepositoryProvider).fetchArticulos();
    final almacenes = await ref.read(almacenRepositoryProvider).fetchAlmacenes();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Ajustar Existencia' : 'Ajuste de Inventario'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Artículo *'),
                        value: selectedArticuloId,
                        items: articulos.map((art) {
                          return DropdownMenuItem(value: art.articuloId, child: Text(art.nombre));
                        }).toList(),
                        onChanged: isEditing ? null : (val) => setState(() => selectedArticuloId = val),
                        validator: (value) => value == null ? 'Requerido' : null,
                      ),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Almacén *'),
                        value: selectedAlmacenId,
                        items: almacenes.map((alm) {
                          return DropdownMenuItem(value: alm.almacenId, child: Text(alm.nombre));
                        }).toList(),
                        onChanged: isEditing ? null : (val) => setState(() => selectedAlmacenId = val),
                        validator: (value) => value == null ? 'Requerido' : null,
                      ),
                      TextFormField(
                        controller: existenciaController,
                        decoration: const InputDecoration(labelText: 'Existencia'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
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
                              if (isEditing) {
                                await ref.read(inventarioRepositoryProvider).updateInventario(
                                  inventario.inventarioId,
                                  {'existencia': double.tryParse(existenciaController.text) ?? 0.0},
                                );
                              } else {
                                await ref.read(inventarioRepositoryProvider).createInventario({
                                  'articulo_id': selectedArticuloId,
                                  'almacen_id': selectedAlmacenId,
                                  'existencia': double.tryParse(existenciaController.text) ?? 0.0,
                                });
                              }
                              ref.invalidate(inventariosFutureProvider);
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Inventario inventario, String artNombre, String almNombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: Text('¿Está seguro de que desea eliminar el inventario de "$artNombre" en el almacén "$almNombre"?'),
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
        await ref.read(inventarioRepositoryProvider).deleteInventario(inventario.inventarioId);
        ref.invalidate(inventariosFutureProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInventarios = ref.watch(inventariosFutureProvider);
    final asyncArticulos = ref.watch(articulosFutureProvider);
    final asyncAlmacenes = ref.watch(almacenesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(inventariosFutureProvider);
              ref.invalidate(articulosFutureProvider);
              ref.invalidate(almacenesFutureProvider);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: asyncInventarios.when(
        data: (inventarios) {
          if (inventarios.isEmpty) {
            return const Center(child: Text('No hay existencias registradas.'));
          }

          // We wait for articulos and almacenes to resolve to display names
          if (asyncArticulos.isLoading || asyncAlmacenes.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final articulos = asyncArticulos.valueOrNull ?? [];
          final almacenes = asyncAlmacenes.valueOrNull ?? [];

          return ListView.builder(
            itemCount: inventarios.length,
            itemBuilder: (context, index) {
              final inv = inventarios[index];
              
              final articulo = articulos.where((a) => a.articuloId == inv.articuloId).firstOrNull;
              final almacen = almacenes.where((a) => a.almacenId == inv.almacenId).firstOrNull;
              
              final artNombre = articulo?.nombre ?? 'Articulo #${inv.articuloId}';
              final almNombre = almacen?.nombre ?? 'Almacén #${inv.almacenId}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.all_inbox, color: Colors.white),
                  ),
                  title: Text(artNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('En: $almNombre'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: inv.existencia > 0 ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          inv.existencia.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: inv.existencia > 0 ? Colors.green.shade800 : Colors.red.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showFormDialog(context, ref, inv);
                          } else if (value == 'delete') {
                            _confirmDelete(context, ref, inv, artNombre, almNombre);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Ajustar')),
                          const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ajuste Inicial'),
      ),
    );
  }
}
