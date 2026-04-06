import 'package:flutter/material.dart';

import '../../model/address_model.dart';

class AddEditAddressScreen extends StatefulWidget {
  final String username;
  final AddressModel? initialAddress;

  const AddEditAddressScreen({
    required this.username,
    this.initialAddress,
    super.key,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _zipCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final address = widget.initialAddress;
    _labelController = TextEditingController(text: address?.label ?? '');
    _streetController = TextEditingController(
      text: address?.streetAddress ?? '',
    );
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _countryController = TextEditingController(
      text: address?.country ?? 'Pakistan',
    );
    _zipCodeController = TextEditingController(text: address?.zipCode ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _latitudeController = TextEditingController(
      text: address?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: address?.longitude?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAddress != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Label
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  label: Text('Label (e.g., Home, Office, Other)'),
                  hintText: 'e.g., Home',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter a label';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Street Address
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  label: Text('Street Address'),
                  hintText: 'e.g., 123 Main Street',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  label: Text('City'),
                  hintText: 'e.g., Lahore',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // State
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  label: Text('State/Province'),
                  hintText: 'e.g., Punjab',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter state/province';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Country
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  label: Text('Country'),
                  hintText: 'e.g., Pakistan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Zip Code
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(
                  label: Text('Zip/Postal Code'),
                  hintText: 'e.g., 54000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter zip/postal code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  label: Text('Phone Number'),
                  hintText: 'e.g., +923001234567',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter phone number';
                  }
                  if ((value?.length ?? 0) < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Latitude (optional)
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  label: Text('Latitude (Optional)'),
                  hintText: 'e.g., 31.5204',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) {
                  if ((value?.isEmpty ?? true)) return null;
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid latitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Longitude (optional)
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  label: Text('Longitude (Optional)'),
                  hintText: 'e.g., 74.3587',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) {
                  if ((value?.isEmpty ?? true)) return null;
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    isEditing ? 'Update Address' : 'Add Address',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = AddressModel(
        addressId: widget.initialAddress?.addressId,
        username: widget.username,
        label: _labelController.text.trim(),
        streetAddress: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        phone: _phoneController.text.trim(),
        latitude: _latitudeController.text.isNotEmpty
            ? double.tryParse(_latitudeController.text)
            : null,
        longitude: _longitudeController.text.isNotEmpty
            ? double.tryParse(_longitudeController.text)
            : null,
        isDefault: widget.initialAddress?.isDefault ?? 0,
      );

      Navigator.pop(context, address);
    }
  }
}
