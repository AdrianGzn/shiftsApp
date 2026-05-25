import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

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
                              _idController.text = data['id'].toString();
                            });
                          } else {
                            // Si no es JSON, asumimos que es el ID
                            setState(() {
                              _idController.text = code;
                            });
                          }
                        } catch (e) {
                           // Fallback si no es JSON válido
                           setState(() {
                              _idController.text = code;
                           });
                        }
                      }
                      if (mounted) {
                        Navigator.pop(context); // Cierra el scanner
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
      final personId = int.tryParse(_idController.text);

      if (personId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, ingresa un ID válido')),
        );
        return;
      }

      int? idUser;
      int? idVisitor;
      
      if (_personType == 'empleado') {
        idUser = personId;
      } else {
        idVisitor = personId;
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
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'ID / Documento',
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
                  return null;
                },
              ),
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
