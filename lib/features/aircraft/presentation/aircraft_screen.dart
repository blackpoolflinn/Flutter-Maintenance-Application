import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/aircraft_provider.dart';

class AircraftScreen extends StatefulWidget {
  const AircraftScreen({super.key});

  @override
  State<AircraftScreen> createState() => _AircraftScreenState();
}

class _AircraftScreenState extends State<AircraftScreen> {
  final _registrationController = TextEditingController();
  final _modelController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AircraftProvider>().loadAircraft();
    });
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'maintenance':
        return 'Maintenance';
      case 'retired':
        return 'Retired';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'retired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _createAircraft() {
    if (_registrationController.text.isNotEmpty &&
        _modelController.text.isNotEmpty &&
        _manufacturerController.text.isNotEmpty &&
        _yearController.text.isNotEmpty) {
      final year = int.tryParse(_yearController.text);
      if (year != null) {
        context.read<AircraftProvider>().createAircraft(
              registrationNumber: _registrationController.text,
              model: _modelController.text,
              manufacturer: _manufacturerController.text,
              yearOfManufacture: year,
            );
        _registrationController.clear();
        _modelController.clear();
        _manufacturerController.clear();
        _yearController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.airplanemode_active, color: Colors.grey[800], size: 28),
                      const SizedBox(width: 10),
                      Text(
                        "Aircraft",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
            ],
            // Create Aircraft Form
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Aircraft',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _registrationController,
                    decoration: InputDecoration(
                      hintText: 'Registration Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      hintText: 'Model',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _manufacturerController,
                    decoration: InputDecoration(
                      hintText: 'Manufacturer',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      hintText: 'Year of Manufacture',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _createAircraft,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amberAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Add Aircraft'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aircraft Fleet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<AircraftProvider>(
              builder: (context, aircraftProvider, _) {
                if (aircraftProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (aircraftProvider.aircraft.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No aircraft registered yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: aircraftProvider.aircraft.length,
                  itemBuilder: (context, index) {
                    final aircraft = aircraftProvider.aircraft[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: PopupMenuButton<String>(
                          initialValue: aircraft.status,
                          onSelected: (String status) {
                            aircraftProvider.updateAircraftStatus(aircraft, status);
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'active',
                              child: Text('Active'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'maintenance',
                              child: Text('Maintenance'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'retired',
                              child: Text('Retired'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(aircraft.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusLabel(aircraft.status),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                        title: Text(
                          aircraft.registrationNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${aircraft.manufacturer} ${aircraft.model}'),
                            Text('Year: ${aircraft.yearOfManufacture}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            aircraftProvider.deleteAircraft(aircraft.id!);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

