import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Harus sudah terinstall setelah flutter pub get

// Import model dan viewmodel Anda
import '../models/device_model.dart';
import '../viewmodels/device_viewmodel.dart';

class DeviceGridView extends StatelessWidget {
  const DeviceGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: Consumer<DeviceViewModel>( // ✅ Consumer untuk listen perubahan data
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.devices.isEmpty) {
            return const Center(child: Text('No devices found. Add one!'));
          }

          return ListView.builder(
            itemCount: viewModel.devices.length,
            itemBuilder: (context, index) {
              final device = viewModel.devices[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => _showDeviceDetails(context, device),
                  onLongPress: () {
                    _showEditDeleteDialog(context, device);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(device.name),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Device',
      ),
    );
  }

  void _showDeviceDetails(BuildContext context, DeviceModel device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(device.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device.data?.containsKey('color') == true)
              Text('Color: ${device.getColor()}'),
            if (device.data?.containsKey('price') == true)
              Text('Price: \$${device.data!['price']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {DeviceModel? device}) {
    final isEdit = device != null;

    final nameController = TextEditingController(text: isEdit ? device!.name : '');
    final priceController = TextEditingController(
      text: isEdit && device.data?.containsKey('price') == true
          ? device.data!['price'].toString()
          : '',
    );
    final colorController = TextEditingController(
      text: isEdit ? device.getColor() ?? '' : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Device' : 'Add New Device'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
                autofocus: true,
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final color = colorController.text.trim();
              final priceText = priceController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }

              final data = <String, dynamic>{};
              if (color.isNotEmpty) data['color'] = color;
              if (priceText.isNotEmpty) {
                final price = double.tryParse(priceText);
                if (price != null) {
                  data['price'] = price;
                }
              }

              final viewModel = Provider.of<DeviceViewModel>(context, listen: false);

              if (isEdit) {
                await viewModel.updateDevice(device!.id, name, data);
              } else {
                await viewModel.addDevice(name, data);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                viewModel.fetchDevices(); // Refresh list
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDeleteDialog(BuildContext context, DeviceModel device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(device.name),
        content: const Text('Choose an action'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            onPressed: () {
              Navigator.pop(ctx);
              _showAddEditDialog(context, device: device);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete'),
            onPressed: () async {
              final viewModel = Provider.of<DeviceViewModel>(context, listen: false);
              final success = await viewModel.deleteDevice(device.id);

              if (ctx.mounted) {
                Navigator.pop(ctx);
              }

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device deleted')),
                );
                viewModel.fetchDevices(); // Refresh list
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}