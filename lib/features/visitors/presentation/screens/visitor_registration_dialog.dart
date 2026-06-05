import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/visitors/presentation/providers/visitor_provider.dart';

class _VisitorRegistrationFormProvider extends ChangeNotifier {
  final dialogFormKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final documentIdController = TextEditingController();
  final companyController = TextEditingController();
  final reasonController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    documentIdController.dispose();
    companyController.dispose();
    reasonController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

class VisitorRegistrationDialog extends StatelessWidget {
  const VisitorRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _VisitorRegistrationFormProvider(),
      child: const _VisitorRegistrationDialogView(),
    );
  }
}

class _VisitorRegistrationDialogView extends StatelessWidget {
  const _VisitorRegistrationDialogView();

  @override
  Widget build(BuildContext context) {
    final visitorVM = Provider.of<VisitorProvider>(context);
    final formProvider = Provider.of<_VisitorRegistrationFormProvider>(context);

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
          key: formProvider.dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: formProvider.fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: formProvider.documentIdController,
                decoration: const InputDecoration(
                  labelText: 'ID / Documento (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: formProvider.companyController,
                decoration: const InputDecoration(
                  labelText: 'Empresa / Procedencia (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: formProvider.reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo de Visita *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: formProvider.phoneController,
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
                  if (formProvider.dialogFormKey.currentState!.validate()) {
                    final newVisitor = await visitorVM.addVisitor(
                      fullName: formProvider.fullNameController.text.trim(),
                      documentId: formProvider.documentIdController.text.isNotEmpty
                          ? formProvider.documentIdController.text.trim()
                          : null,
                      company: formProvider.companyController.text.isNotEmpty
                          ? formProvider.companyController.text.trim()
                          : null,
                      reason: formProvider.reasonController.text.trim(),
                      phone: formProvider.phoneController.text.isNotEmpty
                          ? formProvider.phoneController.text.trim()
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
