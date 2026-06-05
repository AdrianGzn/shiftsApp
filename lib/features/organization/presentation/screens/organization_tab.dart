import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/organization/presentation/providers/organization_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _CreateOrganizationFormProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  String selectedType = 'empresa';

  void setType(String type) {
    selectedType = type;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

class OrganizationTab extends StatelessWidget {
  final AuthProvider authVM;
  final String role;

  const OrganizationTab({super.key, required this.authVM, required this.role});

  @override
  Widget build(BuildContext context) {
    print('OrganizationTab: build. Role: $role, user: ${authVM.user?.displayName}, idOrganization: ${authVM.user?.idOrganization}');
    return ChangeNotifierProvider(
      create: (_) => _CreateOrganizationFormProvider(),
      child: _OrganizationTabView(authVM: authVM, role: role),
    );
  }
}

class _OrganizationTabView extends StatelessWidget {
  final AuthProvider authVM;
  final String role;

  const _OrganizationTabView({required this.authVM, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orgId = authVM.user?.idOrganization;

    print('_OrganizationTabView: build. Role: $role, orgId: $orgId');

    if (role == 'admin' && orgId == null) {
      print('_OrganizationTabView: Admin without org -> show create form');
      return _CreateOrganizationForm(authVM: authVM);
    }

    if (orgId == null) {
      print('_OrganizationTabView: No orgId -> show placeholder');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Aún no tienes una organización asociada. Pídele al administrador de tu organización su código QR para asociarte.'),
        ),
      );
    }

    return Consumer<OrganizationProvider>(
      builder: (context, orgVM, child) {
        print('_OrganizationTabView Consumer: isLoading=${orgVM.isLoading}, error=${orgVM.error}, org=${orgVM.organization?.name}');

        // Reactively trigger load if we have an orgId but the provider hasn't loaded anything yet
        if (!orgVM.isLoading && orgVM.organization == null && orgVM.error == null) {
          print('_OrganizationTabView: Provider is idle with no data. Triggering loadOrganization($orgId)');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            orgVM.loadOrganization(orgId);
          });
          return const Center(child: CircularProgressIndicator());
        }

        if (orgVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orgVM.error != null) {
          print('_OrganizationTabView: Error -> "${orgVM.error}"');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(orgVM.error!),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => orgVM.loadOrganization(orgId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final org = orgVM.organization;
        if (org == null) {
          return const Center(child: Text('No se encontraron detalles de la organización.'));
        }

        print('_OrganizationTabView: Org loaded -> "${org.name}" (ID: ${org.id})');
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
}

class _CreateOrganizationForm extends StatelessWidget {
  final AuthProvider authVM;

  const _CreateOrganizationForm({required this.authVM});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgVM = Provider.of<OrganizationProvider>(context);
    final formProvider = Provider.of<_CreateOrganizationFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formProvider.formKey,
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
                      controller: formProvider.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Organización',
                        prefixIcon: Icon(Icons.business_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: formProvider.selectedType,
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
                        formProvider.setType(val ?? 'empresa');
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: formProvider.addressController,
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
                            if (formProvider.formKey.currentState!.validate()) {
                              final created = await orgVM.createOrganization(
                                name: formProvider.nameController.text.trim(),
                                type: formProvider.selectedType,
                                address: formProvider.addressController.text.trim(),
                              );

                              if (created != null) {
                                await authVM.updateOrganizationId(created.id);
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
