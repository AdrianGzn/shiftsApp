import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';
import 'package:app/features/visitors/presentation/viewmodels/visitor_viewmodel.dart';
import 'package:intl/intl.dart';

class AccessLogListScreen extends StatefulWidget {
  const AccessLogListScreen({super.key});

  @override
  State<AccessLogListScreen> createState() => _AccessLogListScreenState();
}

class _AccessLogListScreenState extends State<AccessLogListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessLogViewModel>(context, listen: false).loadLogs();
      Provider.of<VisitorViewModel>(context, listen: false).loadVisitors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitorVM = Provider.of<VisitorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Acceso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/access-logs/create');
              if (!mounted) return;
              Provider.of<AccessLogViewModel>(context, listen: false).loadLogs();
              visitorVM.loadVisitors();
            },
          ),
        ],
      ),
      body: Consumer<AccessLogViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${vm.error}'),
                  ElevatedButton(
                    onPressed: () {
                      vm.loadLogs();
                      visitorVM.loadVisitors();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (vm.logs.isEmpty) {
            return const Center(child: Text('No hay registros de acceso.'));
          }

          return ListView.builder(
            itemCount: vm.logs.length,
            itemBuilder: (context, index) {
              final log = vm.logs[index];
              final isEntry = log.eventType == 'entry';
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isEntry ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    child: Icon(
                      isEntry ? Icons.login : Icons.logout,
                      color: isEntry ? Colors.green : Colors.red,
                    ),
                  ),
                  title: log.idUser != null
                      ? Text('Empleado (ID: ${log.idUser})')
                      : Text('Invitado: ${visitorVM.getVisitorName(log.idVisitor ?? 0)}'),
                  subtitle: Text(
                    '${isEntry ? 'Entrada' : 'Salida'} • ${DateFormat('dd/MM/yyyy HH:mm').format(log.timestampEvent)}',
                  ),
                  trailing: log.idUser != null 
                    ? const Tooltip(message: 'Empleado', child: Icon(Icons.person))
                    : const Tooltip(message: 'Visitante', child: Icon(Icons.badge)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
