import 'package:flutter/material.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class HomeDashboardTab extends StatelessWidget {
  final AuthViewModel authVM;
  final String role;
  final Function(int) onTabSelected;
  final Function() onNavigateToAccessLogCreate;

  const HomeDashboardTab({
    super.key, 
    required this.authVM, 
    required this.role,
    required this.onTabSelected,
    required this.onNavigateToAccessLogCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primaryContainer, colorScheme.tertiaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido de nuevo!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authVM.user?.displayName ?? 'Usuario',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estás conectado como ${role == "admin" ? "Administradora" : role == "guardia" ? "Guardia de Seguridad" : "Empleado"}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          if (role == 'admin') ...[
            Text('Panel de Administración', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context: context,
                  icon: Icons.business_rounded,
                  title: 'Organización',
                  desc: 'Gestionar o ver QR',
                  color: Colors.blue,
                  onTap: () => onTabSelected(1),
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.people_rounded,
                  title: 'Trabajadores',
                  desc: 'Ver personal de la org',
                  color: Colors.purple,
                  onTap: () => onTabSelected(2),
                ),
              ],
            ),
          ] else if (role == 'guardia') ...[
            Text('Acciones Rápidas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context: context,
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Registrar Acceso',
                  desc: 'Escanear QR de Empleado',
                  color: Colors.teal,
                  onTap: onNavigateToAccessLogCreate,
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.history_rounded,
                  title: 'Ver Historial',
                  desc: 'Todos los accesos',
                  color: Colors.amber,
                  onTap: () => onTabSelected(3),
                ),
              ],
            ),
          ] else ...[
            Text('Mis Tareas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context: context,
                  icon: Icons.qr_code_2_rounded,
                  title: 'Mostrar mi QR',
                  desc: 'Para marcar entrada',
                  color: Colors.indigo,
                  onTap: () => onTabSelected(3), // Perfil tab for employee is 3
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.history_rounded,
                  title: 'Mis Registros',
                  desc: 'Entradas y salidas',
                  color: Colors.deepOrange,
                  onTap: () => onTabSelected(2), // Access logs tab for employee is 2
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
