import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Pantalla de Login con Google Sign-In.
/// Diseño atractivo con Material 3 usando gradientes y Cards.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
              colorScheme.tertiaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'ShiftsApp',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Control de Accesos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Correo o Nombre de usuario',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 24),
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, _) {
                                if (authVM.isLoading) {
                                  return const CircularProgressIndicator();
                                }

                                if (authVM.errorMessage != null && authVM.errorMessage!.startsWith('NEEDS_REGISTRATION')) {
                                  final parts = authVM.errorMessage!.split('|');
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    authVM.clearError();
                                    Navigator.pushNamed(context, '/register', arguments: {
                                      'email': parts.length > 1 ? parts[1] : '',
                                      'name': parts.length > 2 ? parts[2] : '',
                                    });
                                  });
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: FilledButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            authVM.signInWithEmail(
                                              _emailController.text.trim(),
                                              _passwordController.text,
                                            );
                                          }
                                        },
                                        child: const Text('Iniciar Sesión'),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('o'),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: () => authVM.signInWithGoogle(),
                                        icon: const Icon(Icons.account_circle),
                                        label: const Text('Continuar con Google'),
                                      ),
                                    ),
                                    if (authVM.errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text(
                                          authVM.errorMessage!,
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
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('¿No tienes cuenta? Regístrate aquí'),
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
