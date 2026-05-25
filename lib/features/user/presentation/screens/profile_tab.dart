import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/core/config/api_config.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileTab extends StatelessWidget {
  final AuthViewModel authVM;
  final String role;

  const ProfileTab({super.key, required this.authVM, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                authVM.user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildProfileRow('Nombre', authVM.user?.displayName ?? 'Sin Nombre'),
                    const Divider(height: 24),
                    _buildProfileRow(
                      'Correo',
                      authVM.user?.email == null || authVM.user!.email!.isEmpty
                          ? 'Sin cuenta de correo'
                          : authVM.user!.email!,
                    ),
                    const Divider(height: 24),
                    _buildProfileRow('Rol de Cuenta', role.toUpperCase()),
                    const Divider(height: 24),
                    _buildProfileRow('ID de Usuario', authVM.user?.id ?? 'Desconocido'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (role == 'empleado') ...[
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Mi Código QR de Empleado',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xDD000000)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Muestra este código QR al guardia de seguridad al momento de ingresar o salir de las instalaciones.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      QrImageView(
                        data: authVM.user!.id,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ID Empleado: ${authVM.user!.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xDD000000)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showDeleteAccountDialog(context, authVM),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Borrar mi cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar cuenta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta permanentemente? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final url = Uri.parse('${ApiConfig.baseUrl}/users/${authVM.user!.id}');
                final res = await http.delete(
                  url,
                  headers: {'Authorization': 'Bearer ${authVM.user!.idToken}'},
                );
                if (res.statusCode == 200) {
                  await authVM.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tu cuenta ha sido eliminada.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar cuenta: ${res.body}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
