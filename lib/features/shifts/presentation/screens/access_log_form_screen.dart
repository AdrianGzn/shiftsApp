import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/shifts/presentation/providers/access_log_provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/visitors/presentation/providers/visitor_provider.dart';
import 'package:app/features/visitors/domain/models/visitor.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:app/features/visitors/presentation/screens/visitor_registration_dialog.dart';

class AccessLogFormProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  String personType = 'empleado';
  final idController = TextEditingController();
  final notesController = TextEditingController();

  TextEditingController? visitorNameController;
  Visitor? selectedVisitor;

  void setPersonType(String type) {
    personType = type;
    notifyListeners();
  }

  void setPersonId(String id) {
    idController.text = id;
    notifyListeners();
  }

  void setSelectedVisitor(Visitor visitor, String name) {
    selectedVisitor = visitor;
    visitorNameController?.text = name;
    notifyListeners();
  }

  @override
  void dispose() {
    idController.dispose();
    notesController.dispose();
    super.dispose();
  }
}

class AccessLogFormScreen extends StatelessWidget {
  const AccessLogFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccessLogFormProvider(),
      child: const _AccessLogFormScreenView(),
    );
  }
}

class _AccessLogFormScreenView extends StatelessWidget {
  const _AccessLogFormScreenView();

  void _scanQR(BuildContext context, AccessLogFormProvider formProvider) {
    bool isProcessing = false;
    final MobileScannerController cameraController = MobileScannerController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return SizedBox(
          height: MediaQuery.of(modalContext).size.height * 0.6,
          child: Column(
            children: [
              AppBar(
                title: const Text('Escanear QR'),
                leading: CloseButton(onPressed: () {
                  cameraController.stop();
                  Navigator.pop(modalContext);
                }),
              ),
              Expanded(
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) async {
                    if (isProcessing) return;
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      isProcessing = true;
                      await cameraController.stop();

                      final code = barcodes.first.rawValue;
                      if (code != null) {
                        try {
                          final data = jsonDecode(code);
                          if (data['type'] != null && data['id'] != null) {
                            final type = data['type'] == 'visitor' ? 'visitante' : 'empleado';
                            formProvider.setPersonType(type);
                            
                            if (type == 'empleado') {
                              formProvider.setPersonId(data['id'].toString());
                            } else {
                              final visitorVM = Provider.of<VisitorProvider>(context, listen: false);
                              final visitorId = int.tryParse(data['id'].toString()) ?? 0;
                              final visitorObj = visitorVM.visitorMap[visitorId];
                              if (visitorObj != null) {
                                formProvider.setSelectedVisitor(visitorObj, visitorObj.fullName);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Visitante con ID $visitorId no encontrado localmente.')),
                                  );
                                }
                              }
                            }
                          } else {
                            formProvider.setPersonType('empleado');
                            formProvider.setPersonId(code);
                          }
                        } catch (e) {
                          formProvider.setPersonType('empleado');
                          formProvider.setPersonId(code);
                        }
                      }
                      if (modalContext.mounted) {
                        Navigator.pop(modalContext);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      cameraController.dispose();
    });
  }

  void _submit(BuildContext context, AccessLogFormProvider formProvider) async {
    if (formProvider.formKey.currentState!.validate()) {
      final authVM = Provider.of<AuthProvider>(context, listen: false);
      final logVM = Provider.of<AccessLogProvider>(context, listen: false);

      final idGuard = int.tryParse(authVM.user?.id ?? '0') ?? 0;

      int? idUser;
      int? idVisitor;
      
      if (formProvider.personType == 'empleado') {
        final personId = int.tryParse(formProvider.idController.text);
        if (personId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un ID válido')),
          );
          return;
        }
        idUser = personId;
      } else {
        if (formProvider.selectedVisitor == null || formProvider.visitorNameController?.text != formProvider.selectedVisitor!.fullName) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecciona un visitante válido de la lista o regístralo')),
          );
          return;
        }
        idVisitor = formProvider.selectedVisitor!.id;
      }

      final success = await logVM.registerAccess(
        idUser: idUser,
        idVisitor: idVisitor,
        idGuard: idGuard,
        notes: formProvider.notesController.text.isNotEmpty ? formProvider.notesController.text : null,
      );

      if (success && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro procesado exitosamente')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${logVM.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccessLogProvider>().isLoading;
    final formProvider = Provider.of<AccessLogFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Acceso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scanQR(context, formProvider),
            tooltip: 'Escanear QR',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formProvider.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: formProvider.personType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Persona',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
                  DropdownMenuItem(value: 'visitante', child: Text('Visitante')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    formProvider.setPersonType(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (formProvider.personType == 'empleado') ...[
                TextFormField(
                  controller: formProvider.idController,
                  decoration: InputDecoration(
                    labelText: 'ID / Documento del Empleado',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () => _scanQR(context, formProvider),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    if (int.tryParse(value) == null) {
                      return 'ID debe ser un número entero';
                    }
                    return null;
                  },
                ),
              ] else ...[
                Consumer<VisitorProvider>(
                  builder: (context, visitorVM, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Autocomplete<Visitor>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<Visitor>.empty();
                              }
                              return visitorVM.visitors.where((Visitor option) {
                                return option.fullName
                                    .toLowerCase()
                                    .contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption: (Visitor option) => option.fullName,
                            onSelected: (Visitor selection) {
                              formProvider.setSelectedVisitor(selection, selection.fullName);
                            },
                            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                              formProvider.visitorNameController = textEditingController;
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Buscar por Nombre del Visitante',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requerido';
                                  }
                                  if (formProvider.selectedVisitor == null || formProvider.selectedVisitor!.fullName != value) {
                                    return 'Selecciona un visitante de las sugerencias o créalo';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: IconButton.filledTonal(
                              onPressed: () async {
                                final newVisitor = await showDialog<Visitor>(
                                  context: context,
                                  builder: (context) => const VisitorRegistrationDialog(),
                                );
                                if (newVisitor != null) {
                                  formProvider.setSelectedVisitor(newVisitor, newVisitor.fullName);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Visitante registrado y seleccionado correctamente'),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.person_add_rounded),
                              tooltip: 'Registrar Nuevo Visitante',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: formProvider.notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : () => _submit(context, formProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Procesar Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
