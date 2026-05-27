import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app/features/visitors/presentation/viewmodels/visitor_viewmodel.dart';
import 'package:app/features/visitors/domain/models/visitor.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:app/features/visitors/presentation/screens/visitor_registration_dialog.dart';

class AccessLogFormScreen extends StatefulWidget {
  const AccessLogFormScreen({super.key});

  @override
  State<AccessLogFormScreen> createState() => _AccessLogFormScreenState();
}

class _AccessLogFormScreenState extends State<AccessLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _personType = 'empleado';
  final _idController = TextEditingController();
  final _notesController = TextEditingController();

  TextEditingController? _visitorNameController;
  Visitor? _selectedVisitor;

  @override
  void dispose() {
    _idController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _scanQR() {
    bool isProcessing = false;
    final MobileScannerController cameraController = MobileScannerController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              AppBar(
                title: const Text('Escanear QR'),
                leading: CloseButton(onPressed: () {
                  cameraController.stop();
                  Navigator.pop(context);
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
                            setState(() {
                              _personType = data['type'] == 'visitor' ? 'visitante' : 'empleado';
                              if (_personType == 'empleado') {
                                _idController.text = data['id'].toString();
                              } else {
                                final visitorVM = Provider.of<VisitorViewModel>(context, listen: false);
                                final visitorId = int.tryParse(data['id'].toString()) ?? 0;
                                final visitorObj = visitorVM.visitorMap[visitorId];
                                if (visitorObj != null) {
                                  _selectedVisitor = visitorObj;
                                  _visitorNameController?.text = visitorObj.fullName;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Visitante con ID $visitorId no encontrado localmente.')),
                                  );
                                }
                              }
                            });
                          } else {
                            setState(() {
                              _personType = 'empleado';
                              _idController.text = code;
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _personType = 'empleado';
                            _idController.text = code;
                          });
                        }
                      }
                      if (mounted) {
                        Navigator.pop(context);
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



  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final logVM = Provider.of<AccessLogViewModel>(context, listen: false);

      final idGuard = int.tryParse(authVM.user?.id ?? '0') ?? 0;

      int? idUser;
      int? idVisitor;
      
      if (_personType == 'empleado') {
        final personId = int.tryParse(_idController.text);
        if (personId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un ID válido')),
          );
          return;
        }
        idUser = personId;
      } else {
        if (_selectedVisitor == null || _visitorNameController?.text != _selectedVisitor!.fullName) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecciona un visitante válido de la lista o regístralo')),
          );
          return;
        }
        idVisitor = _selectedVisitor!.id;
      }

      final success = await logVM.registerAccess(
        idUser: idUser,
        idVisitor: idVisitor,
        idGuard: idGuard,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro procesado exitosamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${logVM.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccessLogViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Acceso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQR,
            tooltip: 'Escanear QR',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _personType,
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
                    setState(() {
                      _personType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_personType == 'empleado') ...[
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'ID / Documento del Empleado',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQR,
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
                Consumer<VisitorViewModel>(
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
                              setState(() {
                                _selectedVisitor = selection;
                              });
                            },
                            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                              _visitorNameController = textEditingController;
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
                                  if (_selectedVisitor == null || _selectedVisitor!.fullName != value) {
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
                                  setState(() {
                                    _selectedVisitor = newVisitor;
                                    _visitorNameController?.text = newVisitor.fullName;
                                  });
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
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
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
