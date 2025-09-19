import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/service_model.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carPlateNoController = TextEditingController();
  final TextEditingController _serviceDescController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  DateTime? _serviceDate;
  DateTime? _completedDate;
  ServiceStatus _selectedStatus = ServiceStatus.pending;
  bool _isLoading = false;

  // 获取当前用户ID（根据您的认证系统实现）
  String getCurrentUserId() {
    // 示例：return FirebaseAuth.instance.currentUser?.uid ?? '';
    return 'user_123';
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _carNameController.dispose();
    _carModelController.dispose();
    _carPlateNoController.dispose();
    _serviceDescController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isServiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isServiceDate) {
          _serviceDate = picked;
        } else {
          _completedDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_serviceDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select service date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 创建新的服务文档引用（自动生成ID）
      final docRef = FirebaseFirestore.instance.collection('carServices').doc();

      // 创建 ServiceModel 对象
      final service = ServiceModel(
        id: docRef.id, // 使用Firestore生成的文档ID
        serviceType: _serviceTypeController.text.trim(),
        carName: _carNameController.text.trim(),
        carModel: _carModelController.text.trim(),
        carPlateNo: _carPlateNoController.text.trim(),
        serviceDesc: _serviceDescController.text.trim(),
        serviceDate: _serviceDate!,
        completedDate: _completedDate ?? _serviceDate!,
        totalCost: double.parse(_totalCostController.text),
        status: _selectedStatus,
        imageUrl: null,
        hasFeedback: false,
      );

      // 插入到Firestore
      await docRef.set(service.toJson());

      // 成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service added successfully!')),
      );

      // 清空表单
      _formKey.currentState!.reset();
      setState(() {
        _serviceDate = null;
        _completedDate = null;
        _selectedStatus = ServiceStatus.pending;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding service: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Service Type
              TextFormField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Service Type*',
                  hintText: 'e.g., Oil Change, Brake Service',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Car Name
              TextFormField(
                controller: _carNameController,
                decoration: const InputDecoration(
                  labelText: 'Car Name*',
                  hintText: 'e.g., Toyota, Honda',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter car name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Car Model
              TextFormField(
                controller: _carModelController,
                decoration: const InputDecoration(
                  labelText: 'Car Model*',
                  hintText: 'e.g., Camry, Civic',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter car model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Car Plate Number
              TextFormField(
                controller: _carPlateNoController,
                decoration: const InputDecoration(
                  labelText: 'Car Plate Number*',
                  hintText: 'e.g., ABC123',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter plate number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Description
              TextFormField(
                controller: _serviceDescController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Service Description*',
                  hintText: 'Describe the service details...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Date
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Service Date*',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _serviceDate == null
                          ? 'Select date'
                          : DateFormat('yyyy-MM-dd').format(_serviceDate!),
                      style: TextStyle(
                        color: _serviceDate == null
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Completed Date (Optional)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Completed Date (Optional)',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _completedDate == null
                          ? 'Select date'
                          : DateFormat('yyyy-MM-dd').format(_completedDate!),
                      style: TextStyle(
                        color: _completedDate == null
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total Cost
              TextFormField(
                controller: _totalCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Cost (RM)*',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: 'RM ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<ServiceStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status*',
                  border: OutlineInputBorder(),
                ),
                items: ServiceStatus.values.map((status) {
                  return DropdownMenuItem<ServiceStatus>(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}