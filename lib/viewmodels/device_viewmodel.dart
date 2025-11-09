import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/device_model.dart';

class DeviceViewModel extends ChangeNotifier {
  List<DeviceModel> _devices = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<DeviceModel> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // API endpoint (tanpa spasi di akhir!)
  static const String apiUrl = 'https://api.restful-api.dev/objects';

  // Fetch devices from API
  Future<void> fetchDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _devices = jsonData.map((json) => DeviceModel.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load devices. Status code: ${response.statusCode}';
        _devices = [];
      }
    } catch (e) {
      _errorMessage = 'Error fetching devices: $e';
      _devices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh devices
  Future<void> refreshDevices() async {
    await fetchDevices();
  }

  // ADD NEW DEVICE
  Future<DeviceModel?> addDevice(String name, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final newDevice = DeviceModel.fromJson(jsonData);
        _devices.add(newDevice);
        notifyListeners();
        return newDevice;
      } else {
        _errorMessage = 'Failed to add device: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error adding device: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // UPDATE EXISTING DEVICE
  Future<DeviceModel?> updateDevice(String id, String name, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedDevice = DeviceModel.fromJson(jsonData);
        final index = _devices.indexWhere((d) => d.id == id);
        if (index != -1) {
          _devices[index] = updatedDevice;
        }
        notifyListeners();
        return updatedDevice;
      } else {
        _errorMessage = 'Failed to update device: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error updating device: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // DELETE DEVICE
  Future<bool> deleteDevice(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200) {
        _devices.removeWhere((d) => d.id == id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete device: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error deleting device: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}