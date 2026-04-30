import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _tenantController = TextEditingController(text: 'tenant_demo');
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');

  bool _loading = false;
  String? _result;

  @override
  void dispose() {
    _tenantController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final token = await ref.read(authRepositoryProvider).login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            tenantSchema: _tenantController.text.trim(),
          );
      setState(() {
        _result = token.isEmpty ? 'Login sin token' : 'Login exitoso';
      });
    } catch (_) {
      setState(() {
        _result = 'No se pudo autenticar contra el backend';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GalaxyMovil ERP - Acceso')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _tenantController,
                      decoration: const InputDecoration(labelText: 'Tenant'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Usuario'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Clave'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: Text(_loading ? 'Validando...' : 'Ingresar'),
                      ),
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 12),
                      Text(_result!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
