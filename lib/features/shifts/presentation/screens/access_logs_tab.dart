import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';
import 'package:app/features/shifts/domain/models/access_log.dart';
import 'package:app/features/visitors/presentation/viewmodels/visitor_viewmodel.dart';

class AccessLogsTab extends StatelessWidget {
  final AuthViewModel authVM;
  final String role;

  const AccessLogsTab({super.key, required this.authVM, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logVM = Provider.of<AccessLogViewModel>(context);
    final visitorVM = Provider.of<VisitorViewModel>(context);

    List<AccessLog> displayedLogs = logVM.logs;
    if (role == 'empleado') {
      final myId = int.tryParse(authVM.user!.id);
      displayedLogs = logVM.logs.where((log) => log.idUser == myId).toList();
    }

    return Column(
      children: [
        if (role == 'guardia')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/access-logs/create').then((_) {
                    logVM.loadLogs();
                    visitorVM.loadVisitors();
                  });
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Escanear / Registrar Acceso'),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await logVM.loadLogs();
              await visitorVM.loadVisitors();
            },
            child: displayedLogs.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(64.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history_rounded, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                role == 'empleado'
                                    ? 'Aún no tienes registros de entrada o salida.'
                                    : 'No se encontraron registros de accesos.',
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayedLogs.length,
                    itemBuilder: (context, index) {
                      final log = displayedLogs[index];
                      final isEntry = log.eventType == 'entry';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isEntry ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            child: Icon(
                              isEntry ? Icons.login_rounded : Icons.logout_rounded,
                              color: isEntry ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            isEntry ? 'ENTRADA' : 'SALIDA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isEntry ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (role != 'empleado' && log.idUser != null)
                                Text('ID Empleado: ${log.idUser}'),
                              if (log.idVisitor != null)
                                Text(
                                  'Invitado: ${visitorVM.getVisitorName(log.idVisitor!)}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              Text(log.notes ?? 'Sin observaciones'),
                            ],
                          ),
                          trailing: Text(
                            '${log.timestampEvent.hour.toString().padLeft(2, '0')}:${log.timestampEvent.minute.toString().padLeft(2, '0')}\n${log.timestampEvent.day}/${log.timestampEvent.month}',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
