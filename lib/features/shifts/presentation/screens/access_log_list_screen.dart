import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/shifts/presentation/viewmodels/access_log_viewmodel.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Acceso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/access-logs/create'),
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
                    onPressed: () => vm.loadLogs(),
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
                  title: Text(isEntry ? 'Entrada' : 'Salida'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(log.timestampEvent),
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
