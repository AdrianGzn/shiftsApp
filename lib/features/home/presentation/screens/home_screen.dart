import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';

import 'package:app/features/home/presentation/screens/home_dashboard_tab.dart';
import 'package:app/features/organization/presentation/screens/organization_tab.dart';
import 'package:app/features/user/presentation/screens/user_list_tab.dart';
import 'package:app/features/shifts/presentation/screens/access_logs_tab.dart';
import 'package:app/features/user/presentation/screens/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDrawerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessLogViewModel>(context, listen: false).loadLogs();
    });
  }

  List<Map<String, dynamic>> _getDrawerItems(String role) {
    if (role == 'admin') {
      return [
        {'title': 'Inicio', 'icon': Icons.dashboard_rounded},
        {'title': 'Organización', 'icon': Icons.business_rounded},
        {'title': 'Empleados y Guardias', 'icon': Icons.people_rounded},
        {'title': 'Perfil', 'icon': Icons.person_rounded},
      ];
    } else if (role == 'guardia') {
      return [
        {'title': 'Inicio', 'icon': Icons.dashboard_rounded},
        {'title': 'Organización', 'icon': Icons.business_rounded},
        {'title': 'Empleados', 'icon': Icons.people_rounded},
        {'title': 'Registros de Acceso', 'icon': Icons.history_rounded},
        {'title': 'Perfil', 'icon': Icons.person_rounded},
      ];
    } else {
      return [
        {'title': 'Inicio', 'icon': Icons.dashboard_rounded},
        {'title': 'Organización', 'icon': Icons.business_rounded},
        {'title': 'Mis Entradas/Salidas', 'icon': Icons.history_rounded},
        {'title': 'Perfil', 'icon': Icons.person_rounded},
      ];
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              authVM.signOut();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authVM = Provider.of<AuthViewModel>(context);
    final role = authVM.user?.role ?? 'empleado';
    final drawerItems = _getDrawerItems(role);

    if (_selectedDrawerIndex >= drawerItems.length) {
      _selectedDrawerIndex = 0;
    }

    final currentTitle = drawerItems[_selectedDrawerIndex]['title'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: () => _showLogoutDialog(context, authVM),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: colorScheme.onPrimary,
                child: Text(
                  authVM.user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
              accountName: Text(authVM.user?.displayName ?? 'Usuario'),
              accountEmail: Text(
                authVM.user?.email == null || authVM.user!.email!.isEmpty
                    ? 'Sin correo (cuenta local)'
                    : authVM.user!.email!,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: drawerItems.length,
                itemBuilder: (context, index) {
                  final item = drawerItems[index];
                  final isSelected = index == _selectedDrawerIndex;
                  return ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      _onTabSelected(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield, size: 16, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Rol: ${role.toUpperCase()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _buildBody(role, currentTitle, authVM),
      ),
    );
  }

  Widget _buildBody(String role, String title, AuthViewModel authVM) {
    switch (title) {
      case 'Inicio':
        return HomeDashboardTab(
          authVM: authVM,
          role: role,
          onTabSelected: _onTabSelected,
          onNavigateToAccessLogCreate: () => Navigator.pushNamed(context, '/access-logs/create'),
        );
      case 'Organización':
        return OrganizationTab(authVM: authVM, role: role);
      case 'Empleados y Guardias':
      case 'Empleados':
        return UserListTab(authVM: authVM, role: role);
      case 'Registros de Acceso':
      case 'Mis Entradas/Salidas':
        return AccessLogsTab(authVM: authVM, role: role);
      case 'Perfil':
        return ProfileTab(authVM: authVM, role: role);
      default:
        return const Center(child: Text('Vista no disponible'));
    }
  }
}
