import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/almacenes/presentation/almacenes_page.dart';
import 'features/articulos/presentation/articulos_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/categorias/presentation/categorias_page.dart';
import 'features/inventarios/presentation/inventarios_page.dart';

final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/almacenes',
      builder: (context, state) => const AlmacenesPage(),
    ),
    GoRoute(
      path: '/categorias',
      builder: (context, state) => const CategoriasPage(),
    ),
    GoRoute(
      path: '/articulos',
      builder: (context, state) => const ArticulosPage(),
    ),
    GoRoute(
      path: '/inventarios',
      builder: (context, state) => const InventariosPage(),
    ),
  ],
);

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GalaxyMovil ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      routerConfig: _router,
    );
  }
}
