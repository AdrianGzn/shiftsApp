import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app/features/organization/presentation/viewmodels/organization_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrganizationTab extends StatefulWidget {
  final AuthViewModel authVM;
  final String role;

  const OrganizationTab({super.key, required this.authVM, required this.role});

  @override
  State<OrganizationTab> createState() => _OrganizationTabState();
}

class _OrganizationTabState extends State<OrganizationTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orgId = widget.authVM.user?.idOrganization;
      if (orgId != null) {
        Provider.of<OrganizationViewModel>(context, listen: false)
            .loadOrganization(orgId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.role == 'admin' && widget.authVM.user?.idOrganization == null) {
      return _CreateOrganizationForm(authVM: widget.authVM);
    }

    final orgId = widget.authVM.user?.idOrganization;
    if (orgId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Aún no tienes una organización asociada. Pídele al administrador de tu organización su código QR para asociarte.'),
        ),
      );
    }

    return Consumer<OrganizationViewModel>(
      builder: (context, orgVM, child) {
        if (orgVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orgVM.error != null) {
          return Center(child: Text(orgVM.error!));
        }

        final org = orgVM.organization;
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
                        org.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          org.type.toUpperCase(),
                          style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                      ),
                      const Divider(height: 32),
                      ListTile(
                        leading: const Icon(Icons.location_on_rounded),
                        title: const Text('Dirección'),
                        subtitle: Text(org.address),
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range_rounded),
                        title: const Text('Miembro desde'),
                        subtitle: Text(org.createdAt != null
                            ? org.createdAt.toString().split(' ')[0].split('T')[0]
                            : 'Desconocido'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.role == 'admin') ...[
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

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgVM = Provider.of<OrganizationViewModel>(context);

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
                    if (orgVM.isLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final created = await orgVM.createOrganization(
                                name: _nameController.text.trim(),
                                type: _selectedType,
                                address: _addressController.text.trim(),
                              );

                              if (created != null) {
                                await widget.authVM.updateOrganizationId(created.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Organización creada y asociada con éxito!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(orgVM.error ?? 'Servidor no disponible. Inténtelo más tarde.'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
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
