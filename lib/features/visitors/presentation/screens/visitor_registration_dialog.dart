import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/visitors/presentation/viewmodels/visitor_viewmodel.dart';


class VisitorRegistrationDialog extends StatefulWidget {
  const VisitorRegistrationDialog({super.key});

  @override
  State<VisitorRegistrationDialog> createState() => _VisitorRegistrationDialogState();
}

class _VisitorRegistrationDialogState extends State<VisitorRegistrationDialog> {
  final _dialogFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _documentIdController = TextEditingController();
  final _companyController = TextEditingController();
  final _reasonController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentIdController.dispose();
    _companyController.dispose();
    _reasonController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitorVM = Provider.of<VisitorViewModel>(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_rounded, color: Colors.blue),
          SizedBox(width: 8),
          Text('Nuevo Visitante'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _documentIdController,
                decoration: const InputDecoration(
                  labelText: 'ID / Documento (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Empresa / Procedencia (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo de Visita *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (Opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: visitorVM.isLoading
              ? null
              : () async {
                  if (_dialogFormKey.currentState!.validate()) {
                    final newVisitor = await visitorVM.addVisitor(
                      fullName: _fullNameController.text.trim(),
                      documentId: _documentIdController.text.isNotEmpty
                          ? _documentIdController.text.trim()
                          : null,
                      company: _companyController.text.isNotEmpty
                          ? _companyController.text.trim()
                          : null,
                      reason: _reasonController.text.trim(),
                      phone: _phoneController.text.isNotEmpty
                          ? _phoneController.text.trim()
                          : null,
                    );

                    if (newVisitor != null) {
                      if (context.mounted) {
                        Navigator.pop(context, newVisitor);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(visitorVM.error ?? 'No se ha podido registrar el visitante.'),
                          ),
                        );
                      }
                    }
                  }
                },
          child: visitorVM.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
