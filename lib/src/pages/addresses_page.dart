import 'package:flutter/material.dart';
import '../model/data.dart';
import '../model/address.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  late List<Address> addresses;

  @override
  void initState() {
    super.initState();
    addresses = List.from(AppData.addressList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delivery Addresses')),
      body: ListView.builder(
        padding: AppTheme.padding,
        itemCount: addresses.length + 1,
        itemBuilder: (context, index) {
          if (index == addresses.length) {
            return Padding(
              padding: EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: () => _showAddressForm(context),
                icon: Icon(Icons.add),
                label: Text('Add New Address'),
              ),
            );
          }

          final address = addresses[index];
          return _buildAddressCard(context, address, index);
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        address.street,
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${address.city}, ${address.state} ${address.zipCode}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: LightColor.skyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: LightColor.skyBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              address.phone,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => _setDefault(index),
                    child: Text('Set Default'),
                  ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () => _editAddress(context, index),
                  child: Text('Edit'),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () => _deleteAddress(index),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setDefault(int index) {
    setState(() {
      for (var addr in addresses) {
        addr.isDefault = false;
      }
      addresses[index].isDefault = true;
    });
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Address?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                addresses.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Address deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editAddress(BuildContext context, int index) {
    _showAddressForm(context, address: addresses[index], index: index);
  }

  void _showAddressForm(BuildContext context, {Address? address, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AddressFormDialog(
        address: address,
        onSave: (newAddress) {
          setState(() {
            if (index != null) {
              addresses[index] = newAddress;
            } else {
              addresses.add(newAddress);
            }
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Address saved successfully')));
        },
      ),
    );
  }
}

class AddressFormDialog extends StatefulWidget {
  final Address? address;
  final Function(Address) onSave;

  const AddressFormDialog({super.key, this.address, required this.onSave});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipController;
  late TextEditingController countryController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.address?.name ?? '');
    phoneController = TextEditingController(text: widget.address?.phone ?? '');
    streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    cityController = TextEditingController(text: widget.address?.city ?? '');
    stateController = TextEditingController(text: widget.address?.state ?? '');
    zipController = TextEditingController(text: widget.address?.zipCode ?? '');
    countryController = TextEditingController(
      text: widget.address?.country ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Home',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: streetController,
              decoration: InputDecoration(labelText: 'Street Address'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: stateController,
              decoration: InputDecoration(labelText: 'State'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: zipController,
              decoration: InputDecoration(labelText: 'Zip Code'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: countryController,
              decoration: InputDecoration(labelText: 'Country'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveAddress, child: Text('Save')),
      ],
    );
  }

  void _saveAddress() {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        streetController.text.isEmpty ||
        cityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final newAddress = Address(
      id: widget.address?.id ?? DateTime.now().toString(),
      name: nameController.text,
      phone: phoneController.text,
      street: streetController.text,
      city: cityController.text,
      state: stateController.text,
      zipCode: zipController.text,
      country: countryController.text,
      isDefault: widget.address?.isDefault ?? false,
    );

    widget.onSave(newAddress);
  }
}
