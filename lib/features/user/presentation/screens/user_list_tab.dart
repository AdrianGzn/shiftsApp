import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/core/config/api_config.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class UserListTab extends StatelessWidget {
  final AuthViewModel authVM;
  final String role;

  const UserListTab({super.key, required this.authVM, required this.role});

  @override
  Widget build(BuildContext context) {
    final orgId = authVM.user?.idOrganization;

    if (orgId == null) {
      return const Center(child: Text('Debes tener una organización asociada para ver los empleados.'));
    }

    return FutureBuilder<List<dynamic>>(
      future: _fetchEmployees(orgId, authVM.user!.idToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar personal: ${snapshot.error}'));
        }

        final employees = snapshot.data;
        if (employees == null || employees.isEmpty) {
          return const Center(child: Text('No hay empleados registrados en tu organización todavía.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final emp = employees[index];
            final empRole = (emp['role'] ?? 'empleado').toString();
            final empMail = emp['mail'];

            IconData badgeIcon = Icons.badge_rounded;
            Color badgeColor = Colors.grey;

            if (empRole == 'admin') {
              badgeIcon = Icons.admin_panel_settings_rounded;
              badgeColor = Colors.purple;
            } else if (empRole == 'guardia') {
              badgeIcon = Icons.security_rounded;
              badgeColor = Colors.teal;
            } else if (empRole == 'supervisor') {
              badgeIcon = Icons.supervisor_account_rounded;
              badgeColor = Colors.indigo;
            } else {
              badgeIcon = Icons.person_rounded;
              badgeColor = Colors.blue;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: badgeColor.withOpacity(0.1),
                  child: Icon(badgeIcon, color: badgeColor),
                ),
                title: Text(
                  emp['name'] ?? 'Sin Nombre',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(empMail == null || empMail.isEmpty ? 'Sin cuenta de correo registrada' : empMail),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.fingerprint, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('ID: ${emp['id']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    empRole.toUpperCase(),
                    style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchEmployees(int orgId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/');
    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode == 200) {
      final List<dynamic> allUsers = jsonDecode(res.body);
      return allUsers.where((u) => u['idOrganization'] == orgId).toList();
    } else {
      throw Exception('Error al obtener catálogo de personal: ${res.body}');
    }
  }
}
