import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/core/config/api_config.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrganizationTab extends StatelessWidget {
  final AuthViewModel authVM;
  final String role;

  const OrganizationTab({super.key, required this.authVM, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (role == 'admin' && authVM.user?.idOrganization == null) {
      return _CreateOrganizationForm(authVM: authVM);
    }

    final orgId = authVM.user?.idOrganization;
    if (orgId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Aún no tienes una organización asociada. Pídele al administrador de tu organización su código QR para asociarte.'),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchOrgDetails(orgId, authVM.user!.idToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar la organización: ${snapshot.error}'));
        }

        final org = snapshot.data;
        if (org == null) {
          return const Center(child: Text('No se encontraron detalles de la organización.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.business_rounded, size: 60, color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        org['name'] ?? 'Nombre no disponible',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          (org['type'] ?? 'otro').toString().toUpperCase(),
                          style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                      ),
                      const Divider(height: 32),
                      ListTile(
                        leading: const Icon(Icons.location_on_rounded),
                        title: const Text('Dirección'),
                        subtitle: Text(org['address'] ?? 'Sin dirección'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range_rounded),
                        title: const Text('Miembro desde'),
                        subtitle: Text(org['created_at'] != null ? org['created_at'].toString().split('T')[0] : 'Desconocido'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (role == 'admin') ...[
                Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Código QR de la Organización',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Muestra este código QR a tus guardias y empleados para que puedan unirse a esta organización durante su registro.',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        QrImageView(
                          data: orgId.toString(),
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ID: $orgId',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchOrgDetails(int orgId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/organizations/$orgId');
    final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error al obtener organización: ${res.body}');
    }
  }
}

class _CreateOrganizationForm extends StatefulWidget {
  final AuthViewModel authVM;

  const _CreateOrganizationForm({required this.authVM});

  @override
  State<_CreateOrganizationForm> createState() => _CreateOrganizationFormState();
}

class _CreateOrganizationFormState extends State<_CreateOrganizationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedType = 'empresa';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Organización',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Como administradora, necesitas crear una organización antes de invitar a tus empleados y guardias.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Organización',
                        prefixIcon: Icon(Icons.business_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Organización',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'empresa', child: Text('Empresa')),
                        DropdownMenuItem(value: 'oficina', child: Text('Oficina')),
                        DropdownMenuItem(value: 'planta', child: Text('Planta')),
                        DropdownMenuItem(value: 'comercial', child: Text('Comercial')),
                        DropdownMenuItem(value: 'otro', child: Text('Otro')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedType = val ?? 'empresa';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección física',
                        prefixIcon: Icon(Icons.location_on_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    if (_isSaving)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isSaving = true;
                              });
                              try {
                                final orgUrl = Uri.parse('${ApiConfig.baseUrl}/organizations/');
                                final res = await http.post(
                                  orgUrl,
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer ${widget.authVM.user!.idToken}',
                                  },
                                  body: jsonEncode({
                                    'name': _nameController.text.trim(),
                                    'type': _selectedType,
                                    'address': _addressController.text.trim(),
                                  }),
                                );

                                if (res.statusCode == 200 || res.statusCode == 201) {
                                  final createdOrg = jsonDecode(res.body);
                                  final orgId = createdOrg['id'] as int;
                                  await widget.authVM.updateOrganizationId(orgId);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Organización creada y asociada con éxito!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } else {
                                  throw Exception('Error en respuesta de servidor: ${res.body}');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al crear organización: $e'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.create_rounded),
                          label: const Text('Crear Organización'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
