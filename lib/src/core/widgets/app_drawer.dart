import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.inventory_2, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'GalaxyMovil ERP',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Almacenes'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/almacenes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () {
              Navigator.pop(context);
              context.go('/categorias');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Artículos'),
            onTap: () {
              Navigator.pop(context);
              context.go('/articulos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.all_inbox),
            title: const Text('Inventario'),
            onTap: () {
              Navigator.pop(context);
              context.go('/inventarios');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authTokenProvider.notifier).clearToken();
              context.go('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
