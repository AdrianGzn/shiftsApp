import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class RegisterFormProvider extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool initialized = false;
  String selectedRole = 'admin';
  int? selectedOrgId;

  void initialize(Map<String, dynamic>? args) {
    if (!initialized) {
      if (args != null) {
        emailController.text = args['email'] ?? '';
        nameController.text = args['name'] ?? '';
      }
      initialized = true;
    }
  }

  void setRole(String role) {
    selectedRole = role;
    if (role == 'admin') {
      selectedOrgId = null;
    }
    notifyListeners();
  }

  void setOrgId(int? orgId) {
    selectedOrgId = orgId;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<AuthProvider>(context, listen: false).fetchOrganizations();
        });
        return RegisterFormProvider();
      },
      child: const _RegisterScreenView(),
    );
  }
}

class _RegisterScreenView extends StatelessWidget {
  const _RegisterScreenView();

  void _scanOrganizationQr(BuildContext context, List<Map<String, dynamic>> organizations, RegisterFormProvider formProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppBar(
                title: const Text('Escanear QR de Organización'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final String? rawValue = barcode.rawValue;
                          if (rawValue != null) {
                            final int? orgId = int.tryParse(rawValue);
                            if (orgId != null) {
                              final bool exists = organizations.any((org) => org['id'] == orgId);
                              if (exists) {
                                formProvider.setOrgId(orgId);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Organización escaneada con éxito: ID $orgId'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('La organización con ID $orgId no está en el catálogo'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              return;
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
                child: Text(
                  'Coloca el código QR de la organización dentro del recuadro para escanearlo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formProvider = Provider.of<RegisterFormProvider>(context);
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    formProvider.initialize(args);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta'), backgroundColor: Colors.transparent),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [colorScheme.surface, colorScheme.secondaryContainer, colorScheme.tertiaryContainer],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: formProvider.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, size: 70, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Únete a ShiftsApp',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: formProvider.selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Rol',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                                DropdownMenuItem(value: 'guardia', child: Text('Guardia de Seguridad')),
                                DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
                              ],
                              onChanged: (val) {
                                formProvider.setRole(val ?? 'admin');
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: formProvider.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre completo',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: formProvider.emailController,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico (Opcional)',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val != null && val.isNotEmpty) {
                                  if (!val.contains('@') || !val.contains('.')) {
                                    return 'Formato de correo inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: formProvider.passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            
                            if (formProvider.selectedRole != 'admin') ...[
                              const SizedBox(height: 16),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: formProvider.selectedOrgId,
                                          decoration: const InputDecoration(
                                            labelText: 'Organización',
                                            prefixIcon: Icon(Icons.business),
                                          ),
                                          items: authProvider.organizations.map((org) {
                                            return DropdownMenuItem<int>(
                                              value: org['id'],
                                              child: Text(
                                                org['name'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            formProvider.setOrgId(val);
                                          },
                                          validator: (val) {
                                            if (formProvider.selectedRole != 'admin' && val == null) {
                                              return 'Selecciona organización';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton.filledTonal(
                                        onPressed: () => _scanOrganizationQr(context, authProvider.organizations, formProvider),
                                        icon: const Icon(Icons.qr_code_scanner),
                                        tooltip: 'Escanear QR',
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 24),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                if (authProvider.isLoading) return const CircularProgressIndicator();
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          if (formProvider.formKey.currentState!.validate()) {
                                            authProvider.registerWithEmail(
                                              name: formProvider.nameController.text.trim(),
                                              email: formProvider.emailController.text.trim(),
                                              password: formProvider.passwordController.text,
                                              role: formProvider.selectedRole,
                                              orgId: formProvider.selectedOrgId,
                                            ).then((_) {
                                              if (authProvider.isAuthenticated) {
                                                Navigator.of(context).popUntil((route) => route.isFirst);
                                              }
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.check),
                                        label: const Text('Registrarse'),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('o'),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          authProvider.signInWithGoogle().then((_) {
                                            if (authProvider.isAuthenticated) {
                                              Navigator.of(context).popUntil((route) => route.isFirst);
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.app_registration_rounded),
                                        label: const Text('Registrarse con Google'),
                                      ),
                                    ),
                                    if (authProvider.errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: TextStyle(color: colorScheme.error, fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
                    ),
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
