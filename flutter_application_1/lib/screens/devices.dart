import 'package:flutter/material.dart';
import '../services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DevicePage(),
    );
  }
}

// screen for managing linked devices
class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  // list of linked devices
  List<Map<String, String>> devices = [];
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();

  // show dialog for linking and editing a device
  void showLinkOrEditDialog(BuildContext context, {required bool isUpdate, int? deviceIndex}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // title
                Text(
                  isUpdate ? 'Update Device' : 'Link Device',
                  style: TextStyle(color: Colors.blue[900], fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Align(alignment: Alignment.centerLeft, child: Text("Device Name:")),
                const SizedBox(height: 4),
                // device name text field
                TextField(
                  controller: _deviceNameController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft, child: Text("Serial Number:")),
                const SizedBox(height: 4),
                // serial number text field
                TextField(
                  controller: _serialController,
                  readOnly: isUpdate, // readonly id updating
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: isUpdate ? _serialController.text : "Enter 5-digit number",
                    helperText: isUpdate ? null : "(will be prefixed with PPSC-)",
                    fillColor: isUpdate ? Colors.grey.shade200 : null,
                    filled: isUpdate,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(backgroundColor: Colors.grey),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showConfirmationDialog(context, isUpdate: isUpdate, deviceIndex: deviceIndex);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // show confirmation before saving
  void showConfirmationDialog(BuildContext context, {required bool isUpdate, int? deviceIndex}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Do you want to save this device?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              // confirmation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final serial = _serialController.text.trim();
                      if (serial.isEmpty) {
                        _showErrorDialog(context, 'Serial number is required.');
                        return;
                      }
                      // check if device is available
                      final checkResult = await ApiService.checkDeviceAvailable('PPSC-$serial');
                      if (checkResult['success'] != true) {
                        _showErrorDialog(context, checkResult['message'] ?? 'Device not available.');
                        return;
                      }
                      // update or add device to the list
                      setState(() {
                        if (isUpdate && deviceIndex != null) {
                          // update existing device
                          devices[deviceIndex] = {
                            'name': _deviceNameController.text,
                            'serial': 'PPSC-${_serialController.text}',
                          };
                        } else {
                          // add new device
                          devices.add({
                            'name': _deviceNameController.text,
                            'serial': 'PPSC-${_serialController.text}',
                          });
                        }
                        // clear controllers after saving
                        _deviceNameController.clear();
                        _serialController.clear();
                      });
                      // show success message
                      showSuccessDialog(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // show error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // show confirmation before unlinking a device
  void showUnlinkConfirmationDialog(BuildContext context, int deviceIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Do you really want to unlink this device?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              // confirmation buttons for unlinking
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // remove device from the list
                      setState(() {
                        devices.removeAt(deviceIndex);
                      });
                      // show success message
                      showSuccessDialog(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show success 
  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 36),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Success', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Action completed successfully.', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // clean up controllers
    _deviceNameController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[900]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Devices', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Linked Devices', style: TextStyle(fontSize: 14, color: Colors.black)),
                // button to link a new device
                ElevatedButton.icon(
                  onPressed: () => showLinkOrEditDialog(context, isUpdate: false),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Link Device', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // show message if no devices are linked
            devices.isEmpty
                ? const Text('No devices linked yet.', style: TextStyle(color: Colors.black54, fontSize: 16))
                : Expanded(
                    // list of linked devices
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // device name and serial number
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(device['name'] ?? '', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(device['serial'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                ],
                              ),
                              // edit and unlink buttons
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _deviceNameController.text = device['name'] ?? '';
                                      _serialController.text = (device['serial'] ?? '').replaceFirst('PPSC-', '');
                                      showLinkOrEditDialog(context, isUpdate: true, deviceIndex: index);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                                    child: const Text('Edit', style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => showUnlinkConfirmationDialog(context, index),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Unlink', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}